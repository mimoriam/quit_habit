import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionType { free, monthly, lifetime }

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isEntitled = false;
  SubscriptionType _type = SubscriptionType.free;
  List<ProductDetails> _products = [];
  Set<String> _notFoundIDs = {};
  bool _isLoading = false;

  bool get isEntitled => _isEntitled;
  SubscriptionType get type => _type;
  List<ProductDetails> get products => _products;
  Set<String> get notFoundIDs => _notFoundIDs;
  bool get isLoading => _isLoading;

  static const String _kEntitledKey = 'is_entitled';
  static const String _kTypeKey = 'subscription_type';

  // Product IDs from functions/index.js
  static const String idMonthly = 'monthly_subs';
  static const String idLifetime = 'lifetime_activation';

  Future<void> initialize() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase Stream Error: $error'),
    );

    await _loadCachedStatus();
    await fetchProducts();
    await refreshStatus(); // Initial check
  }

  Future<void> _loadCachedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isEntitled = prefs.getBool(_kEntitledKey) ?? false;
    final typeIndex = prefs.getInt(_kTypeKey) ?? 0;
    if (typeIndex >= 0 && typeIndex < SubscriptionType.values.length) {
      _type = SubscriptionType.values[typeIndex];
    } else {
      _type = SubscriptionType.free;
    }
    notifyListeners();
  }
  Future<void> _saveCachedStatus(bool entitled, SubscriptionType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEntitledKey, entitled);
    await prefs.setInt(_kTypeKey, type.index);
    _isEntitled = entitled;
    _type = type;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _setLoading(true);
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('SubscriptionService: IAP not available');
        return;
      }

      const Set<String> ids = {idMonthly, idLifetime};
      debugPrint('SubscriptionService: Querying products: $ids');
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);

      if (response.error != null) {
        debugPrint('SubscriptionService: Query Error: ${response.error}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('SubscriptionService: Products not found: ${response.notFoundIDs}');
        _notFoundIDs = response.notFoundIDs.toSet();
      } else {
        _notFoundIDs = {};
      }

      debugPrint('SubscriptionService: Found ${response.productDetails.length} products');
      for (var product in response.productDetails) {
        debugPrint('SubscriptionService: Product found: ${product.id} - ${product.title} - ${product.price}');
      }

      _products = response.productDetails;
    } catch (e) {
      debugPrint('SubscriptionService: Exception in fetchProducts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('SubscriptionService: Skipping refreshStatus, no user logged in.');
      return;
    }

    _setLoading(true);
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('checkSubscriptionStatus').call();
      _handleStatusResult(result.data);
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> forceRefreshPlayStore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('SubscriptionService: Skipping forceRefreshPlayStore, no user logged in.');
      return;
    }

    _setLoading(true);
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('refreshPlayPurchase').call();
      _handleStatusResult(result.data);
    } catch (e) {
      debugPrint('Error refreshing play purchase: $e');
    } finally {
      _setLoading(false);
    }
  }
  void _handleStatusResult(dynamic data) {
    final bool entitled = data['isEntitled'] ?? false;
    final String? prodId = data['productId'];
    
    SubscriptionType type = SubscriptionType.free;
    if (entitled) {
      if (prodId == idLifetime) {
        type = SubscriptionType.lifetime;
      } else if (prodId == idMonthly) {
        type = SubscriptionType.monthly;
      }
    }

    _saveCachedStatus(entitled, type);
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    if (product.id == idLifetime) {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    _setLoading(true);
    try {
      for (var purchaseDetails in purchaseDetailsList) {
        try {
          if (purchaseDetails.status == PurchaseStatus.error) {
            debugPrint('Purchase Error: ${purchaseDetails.error}');
          } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                     purchaseDetails.status == PurchaseStatus.restored) {
            await _verifyPurchase(purchaseDetails);
          }

          if (purchaseDetails.pendingCompletePurchase) {
            try {
              await _inAppPurchase.completePurchase(purchaseDetails);
            } catch (e) {
              debugPrint('Error completing purchase: $e');
            }
          }
        } catch (e) {
          debugPrint('Error processing individual purchase: $e');
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('verifyPlayPurchase').call({
        'productId': purchase.productID,
        'purchaseToken': purchase.verificationData.serverVerificationData,
      });
      _handleStatusResult(result.data);
    } catch (e) {
      debugPrint('Verification failed: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
