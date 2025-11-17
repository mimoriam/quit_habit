import 'package:flutter/material.dart';
import 'package:quit_habit/screens/paywall/select_plan_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // 2. Calendar Icon
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
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: AppColors.white,
                            size: 36,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 3. Title & Subtitle
                        Text(
                          "90-Day Program",
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "See exactly what happens to your body during recovery",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.lightTextSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // 4. Timeline Items
                        _buildTimelineItem(
                          theme,
                          color: AppColors.lightPrimary,
                          bgColor: const Color(0xFFEBF5FF), // Light Blue
                          icon: Icons.track_changes_rounded,
                          tag: "Week 1-2",
                          title: "Breaking the Pattern",
                          description:
                              "Learn to recognize triggers and build new routines",
                          isFirst: true,
                        ),
                        _buildTimelineItem(
                          theme,
                          color: const Color(0xFFAD46FF), // Purple
                          bgColor: const Color(0xFFF3E8FF), // Light Purple
                          icon: Icons.show_chart_rounded,
                          tag: "Week 3-6",
                          title: "Building Resilience",
                          description:
                              "Strengthen your willpower with daily exercises",
                        ),
                        _buildTimelineItem(
                          theme,
                          color: const Color(0xFF00B894), // Teal/Green
                          bgColor: const Color(0xFFE0F2F1), // Light Teal
                          icon: Icons.auto_awesome_rounded,
                          tag: "Week 7-12",
                          title: "Creating New Habits",
                          description:
                              "Replace old habits with healthy alternatives",
                        ),
                        _buildTimelineItem(
                          theme,
                          color: AppColors.lightWarning, // Orange
                          bgColor: const Color(0xFFFFF3E0), // Light Orange
                          icon: Icons.check_circle_outline_rounded,
                          tag: "Day 90",
                          title: "Freedom Achieved",
                          description:
                              "Celebrate your transformation and new lifestyle",
                          isLast: true,
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                
                // 5. Sticky Continue Button
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.lightBackground.withOpacity(0),
                        AppColors.lightBackground,
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectPlanScreen(),
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
                        "Continue",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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

  Widget _buildTimelineItem(
    ThemeData theme, {
    required Color color,
    required Color bgColor,
    required IconData icon,
    required String tag,
    required String title,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column (Icon + Line)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top Line (connects to previous item)
                Expanded(
                  flex: 0,
                  child: isFirst
                      ? const SizedBox(height: 8) // Spacing for first item
                      : Container(
                          width: 2,
                          color: AppColors.lightBorder,
                        ),
                ),
                // Icon Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 32, // Inner circle fill
                      height: 32,
                      decoration: BoxDecoration(
                         color: AppColors.white,
                         shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Bottom Line (connects to next item)
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : Container(
                          width: 2,
                          color: AppColors.lightBorder,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}