import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/screens/navbar/profile/subscription_status/subscription_status_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quit_habit/services/subscription_service.dart';

class SelectPlanScreen extends StatefulWidget {
  const SelectPlanScreen({super.key});

  @override
  State<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends State<SelectPlanScreen> {
  // 0: Monthly, 1: Lifetime
  int _selectedPlanIndex = 0;
  late SubscriptionService _subService;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    // Listen for subscription entitlement to auto-redirect
    _subService = context.read<SubscriptionService>();
    _subService.addListener(_checkEntitlement);
  }

  @override
  void dispose() {
    _subService.removeListener(_checkEntitlement);
    super.dispose();
  }

  void _checkEntitlement() {
    if (_subService.isEntitled) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionStatusScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subService = context.watch<SubscriptionService>();
    final products = subService.products;
    
    debugPrint('SelectPlanScreen: Building with ${products.length} products');
    for (var p in products) {
      debugPrint('SelectPlanScreen: Available ID: ${p.id}');
    }
    
    // Find specific products
    ProductDetails? monthlyProduct;
    ProductDetails? lifetimeProduct;

    for (var p in products) {
      if (p.id == SubscriptionService.idMonthly) monthlyProduct = p;
      if (p.id == SubscriptionService.idLifetime) lifetimeProduct = p;
    }

    final bool isLoading = subService.isLoading;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lightWarning,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33F59E0B),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'images/icons/pro_crown.png',
                              width: 36,
                              height: 36,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Choose Your Plan",
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Invest in your health and freedom today",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.lightTextSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        
                        // Monthly Plan
                        if (monthlyProduct != null)
                          _buildPlanCard(
                            theme,
                            index: 0,
                            title: "Monthly Plan",
                            price: monthlyProduct.price,
                            period: "per month",
                            dailyPrice: "Recurring subscription",
                            badgeText: "Most Popular",
                            badgeColor: AppColors.lightSecondary,
                          )
                        else if (!isLoading)
                          const Text("Monthly plan currently unavailable"),

                        const SizedBox(height: 12),

                        // Lifetime Plan
                        if (lifetimeProduct != null)
                          _buildPlanCard(
                            theme,
                            index: 1,
                            title: "Lifetime Access",
                            price: lifetimeProduct.price,
                            period: "one-time",
                            dailyPrice: "Full access forever",
                            badgeText: "Best Value",
                            badgeColor: AppColors.lightPrimary,
                          )
                        else if (!isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                Text(
                                  "Lifetime access currently unavailable",
                                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightError),
                                ),
                                if (subService.notFoundIDs.contains(SubscriptionService.idLifetime))
                                  Text(
                                    "ID: ${SubscriptionService.idLifetime} not found in Play Store",
                                    style: theme.textTheme.labelSmall?.copyWith(color: AppColors.lightTextSecondary),
                                  ),
                                TextButton(
                                  onPressed: () => subService.fetchProducts(),
                                  child: const Text("Tap to retry"),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Everything included:",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightTextPrimary,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(theme, "Personalized 90-day quit plan"),
                        _buildFeatureItem(theme, "Daily progress tracking & insights"),
                        _buildFeatureItem(theme, "Craving management tools"),
                        _buildFeatureItem(theme, "Health improvement timeline"),
                        _buildFeatureItem(theme, "Expert video guidance"),
                        _buildFeatureItem(theme, "Community support access"),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.lightSuccess.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.lightSuccess, width: 1.5),
                                  color: AppColors.white,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.lightSuccess,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Save your health and money",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF064E3B),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Average smoker spends ~\$2,500 per\nyear on cigarettes",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF065F46),
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.lightBackground.withOpacity(0),
                        AppColors.lightBackground,
                      ],
                      stops: const [0.0, 0.2],
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (isLoading || _isBusy)
                          ? null
                          : () async {
                              final targetProduct = _selectedPlanIndex == 0 
                                  ? monthlyProduct 
                                  : lifetimeProduct;
                              
                              if (targetProduct != null) {
                                try {
                                  setState(() => _isBusy = true);
                                  await subService.buyProduct(targetProduct);
                                } catch (e) {
                                  debugPrint('Purchase error: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text("Purchase failed. Please try again."),
                                        backgroundColor: AppColors.lightError,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isBusy = false);
                                  }
                                }                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Selected product is unavailable")),
                                );
                              }
                            },
                      child: (isLoading || _isBusy)
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Subscribe Now",
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    ThemeData theme, {
    required int index,
    required String title,
    required String price,
    required String period,
    required String dailyPrice,
    String? badgeText,
    Color? badgeColor,
    String? saveAmount,
  }) {
    final bool isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.lightPrimary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              period,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            dailyPrice,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                          if (saveAmount != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightSuccess.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                saveAmount,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.lightSuccess,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Selection Indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.lightPrimary : AppColors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.lightPrimary
                          : AppColors.lightBorder,
                      width: isSelected ? 0 : 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
          
          // Badge (Positioned on top right)
          if (badgeText != null)
            Positioned(
              top: -12,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.lightPrimary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF374151), // Dark grey
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}