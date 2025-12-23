import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/constants.dart';
import 'package:quit_habit/firebase_options.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/providers/theme_provider.dart';
import 'package:quit_habit/utils/app_theme.dart';
import 'package:quit_habit/widgets/auth_gate.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:quit_habit/services/subscription_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Gemini.init(apiKey: 'AIzaSyCWTlL7wv6tIFUapTTzzxinu3hxR6CJLzA');
  Gemini.init(apiKey: geminiAPIKey);
  await MobileAds.instance.initialize();
  
  // Add test device ID as per logs
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ['1DFFDB7EBD57CEB5C20417F0173E537B'],
    ),
  );
  
  
  final subscriptionService = SubscriptionService();
  await subscriptionService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: subscriptionService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh subscription status when app is resumed
      // to handle cases where user cancels from Play Store
      if (mounted) {
        try {
          context.read<SubscriptionService>().refreshStatus();
        } catch (e) {
          debugPrint('Failed to refresh subscription status: $e');
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const AuthGate(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: Text('Welcome')));
  }
}
