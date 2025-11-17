import 'package:flutter/material.dart';
import 'package:quit_habit/screens/paywall/roadmap_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class SuccessRateScreen extends StatelessWidget {
  const SuccessRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // 1. Decorative Background Shape (Top Left)
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // 2. Heart Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6366F1), // Indigo/Blue
                            Color(0xFF8B5CF6), // Purple
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Title & Subtitle
                    Text(
                      "You're Not Alone",
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Join thousands who've successfully quit smoking with our proven program",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // 4. Success Rate Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "98%",
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Success Rate",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.lightBorder, height: 1),
                          const SizedBox(height: 12),
                          Text(
                            "Our users quit within 90 days",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. Benefits List
                    _buildBenefitCard(
                      theme,
                      color: AppColors.lightPrimary,
                      title: "Evidence-Based Program",
                      subtitle: "Scientifically proven methods backed by medical research",
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitCard(
                      theme,
                      color: AppColors.lightSecondary,
                      title: "Personalized Support",
                      subtitle: "Tailored guidance based on your smoking habits and triggers",
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitCard(
                      theme,
                      color: const Color(0xFF00B894), // Teal
                      title: "Community Driven",
                      subtitle: "Connect with others on the same journey to freedom",
                    ),

                    const SizedBox(height: 16),

                    // 6. Guarantee Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.lightSuccess.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.lightSuccess.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.lightSuccess, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.lightSuccess,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "90-Day Guarantee",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF064E3B), // Dark Green
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Follow our proven method and achieve lasting freedom from your habit",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF065F46), // Medium Green
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 7. CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoadmapScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: AppColors.white,
                          elevation: 4,
                          shadowColor: AppColors.lightPrimary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "See Your Roadmap",
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(
    ThemeData theme, {
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}