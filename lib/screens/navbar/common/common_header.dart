import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/services/plan_service.dart';
import 'package:quit_habit/services/ads_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final habitService = HabitService();
    final adsService = AdsService();

    // This is the _buildHeader implementation from home_screen.dart
    return Row(
      children: [
        Builder(
          builder: (context) {
            if (user == null) {
              return _buildStatBadge(
                theme,
                image: "images/icons/header_shield.png",
                label: '0%',
                bgColor: AppColors.badgeGreen,
                iconColor: AppColors.lightSuccess,
                textColor: AppColors.lightSuccess,
              );
            }

            return StreamBuilder<HabitDataWithRelapses?>(
              stream: habitService.getHabitDataStream(user.uid),
              builder: (context, snapshot) {
                final dataWithRelapses = snapshot.data;
                final habitData = dataWithRelapses?.habitData;
                final relapsePeriods = dataWithRelapses?.relapsePeriods ?? [];
                
                final successRate = habitData != null && habitData.hasStartDate
                    ? habitService.getSuccessRate(habitData, relapsePeriods)
                    : 0.0;

                return _buildStatBadge(
                  theme,
                  image: "images/icons/header_shield.png",
                  label: '${successRate.toStringAsFixed(successRate.truncateToDouble() == successRate ? 0 : 1)}%',
                  bgColor: AppColors.badgeGreen,
                  iconColor: AppColors.lightSuccess,
                  textColor: AppColors.lightSuccess,
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),
        // Coins Badge with Ad
        if (user != null)
          StreamBuilder<int>(
            stream: adsService.getCoinsStream(user.uid),
            initialData: 0,
            builder: (context, snapshot) {
              final coins = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () async {
                  debugPrint('Ad coin tapped');
                  try {
                    final newCoins = await adsService.showRewardedAd(user.uid);
                    if (context.mounted) {
                      if (newCoins != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You earned 10 coins! Total: $newCoins'),
                            backgroundColor: AppColors.lightSuccess,
                          ),
                        );
                      } else {
                         // Ad closed without reward or failed to show gracefully
                         debugPrint('Ad returned null coins');
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No reward earned.'),
                              backgroundColor: AppColors.lightTextSecondary,
                              duration: Duration(seconds: 1),
                            ),
                         );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error showing ad: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: AppColors.lightError,
                        ),
                      );
                    }
                  }
                },
                child: _buildStatBadge(
                  theme,
                  image: "images/icons/header_coin.png",
                  label: '$coins',
                  bgColor: AppColors.badgeOrange,
                  iconColor: AppColors.lightWarning,
                  textColor: AppColors.lightWarning,
                ),
              );
            },
          )
        else
          _buildStatBadge(
            theme,
            image: "images/icons/header_coin.png",
            label: '0',
            bgColor: AppColors.badgeOrange,
            iconColor: AppColors.lightWarning,
            textColor: AppColors.lightWarning,
          ),
        const Spacer(),
        // Pro Badge - only shown for Pro users
        if (user != null)
          StreamBuilder<({bool isPro, bool hasStarted, DateTime? planStartedAt})>(
            stream: PlanService.instance.getUserPlanStatusStream(user.uid),
            builder: (context, snapshot) {
              // Handle loading state - show placeholder
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightTextTertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 60, // Approximate width of "Pro" badge
                    height: 18,
                  ),
                );
              }
              
              // Handle error state - log and show optimistic fallback
              if (snapshot.hasError) {
                debugPrint('❌ Error loading Pro status in header: ${snapshot.error}');
                // Optimistically keep badge visible on error to avoid jarring UX
                // User data streams are usually cached, so errors are rare
                // Fall through to render badge based on last known state or default to hidden
                // For now, hide on error but consider showing last known state in future
                return const SizedBox.shrink();
              }              
              // Get Pro status from data
              final isPro = snapshot.data?.isPro ?? false;
              
              if (!isPro) {
                return const SizedBox.shrink(); // Hide for free users
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightSuccess, // Green for Pro users
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "images/icons/pro_crown.png",
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pro',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // This is the _buildStatBadge implementation from home_screen.dart
  Widget _buildStatBadge(
    ThemeData theme, {
    // required IconData icon,
    required String image,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon(icon, color: iconColor, size: 16),
          Image.asset(image, width: 18, height: 18,),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}