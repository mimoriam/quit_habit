import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/after_login_questionnaire/questionnaire1_screen.dart';
import 'package:quit_habit/screens/auth/login/login_screen.dart';
import 'package:quit_habit/screens/navbar/navbar.dart';
import 'package:quit_habit/utils/app_colors.dart';

import 'package:quit_habit/services/subscription_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastUid;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Trigger subscription check when user becomes authenticated or changes
        if (authProvider.isAuthenticated) {
          if (authProvider.user?.uid != _lastUid) {
            _lastUid = authProvider.user?.uid;
            // Run check in next frame to avoid build context issues
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<SubscriptionService>().refreshStatus();
              }
            });
          }
        } else {
          // Reset _lastUid when unauthenticated to allow refresh if same user logs back in
          _lastUid = null;
        }

        Widget currentScreen;
        String screenKey;

        // Determine which screen to show
        if (authProvider.isLoading) {
          // Initial load - show loading screen while checking auth state
          currentScreen = const _LoadingScreen();
          screenKey = 'loading';
        } else if (!authProvider.isAuthenticated) {
          // Not authenticated - show login screen
          currentScreen = const LoginScreen();
          screenKey = 'login';
        } else if (!authProvider.hasCompletedQuestionnaire) {
          // Authenticated but hasn't completed questionnaire - show questionnaire
          currentScreen = const Questionnaire1Screen();
          screenKey = 'questionnaire';
        } else {
          // Authenticated and completed questionnaire - show main app
          currentScreen = const NavBar();
          screenKey = 'navbar';
        }

        // Use AnimatedSwitcher for seamless transitions between screens
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(screenKey),
            child: currentScreen,
          ),
        );
      },
    );
  }
}

/// Loading screen shown during initial auth state check
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.lightPrimary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

