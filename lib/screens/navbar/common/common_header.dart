import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final habitService = HabitService();

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
                  label: '${successRate.toStringAsFixed(1)}%',
                  bgColor: AppColors.badgeGreen,
                  iconColor: AppColors.lightSuccess,
                  textColor: AppColors.lightSuccess,
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),
        // _buildStatBadge(
        //   theme,
        //   // icon: Icons.diamond_outlined,
        //   image: "images/icons/header_diamond.png",
        //   label: '1',
        //   bgColor: AppColors.badgeBlue,
        //   iconColor: AppColors.lightPrimary,
        //   textColor: AppColors.lightPrimary,
        // ),
        // const SizedBox(width: 8),
        _buildStatBadge(
          theme,
          // icon: Icons.monetization_on_outlined,
          image: "images/icons/header_coin.png",
          label: '0',
          bgColor: AppColors.badgeOrange,
          iconColor: AppColors.lightWarning,
          textColor: AppColors.lightWarning,
        ),
        const Spacer(),
        // Pro Button from home_screen.dart
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.proColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // const Icon(
              //   FontAwesome.crown_solid,
              //   color: AppColors.white,
              //   size: 16,
              // ),
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