import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:quit_habit/utils/app_colors.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This is the _buildHeader implementation from home_screen.dart
    return Row(
      children: [
        _buildStatBadge(
          theme,
          // icon: Icons.health_and_safety_outlined,
          image: "images/icons/header_shield.png",
          label: '0%',
          bgColor: AppColors.badgeGreen,
          iconColor: AppColors.lightSuccess,
          textColor: AppColors.lightSuccess,
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