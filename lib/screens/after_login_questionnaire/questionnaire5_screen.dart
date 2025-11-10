import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:quit_habit/utils/navigation_utils.dart';
import 'package:quit_habit/screens/navbar/home/home_screen.dart';

class Questionnaire5Screen extends StatefulWidget {
  const Questionnaire5Screen({super.key});

  @override
  State<Questionnaire5Screen> createState() => _Questionnaire5ScreenState();
}

class _Questionnaire5ScreenState extends State<Questionnaire5Screen> {
  String? _selectedOption;

  final List<String> _options = [
    'In the morning',
    'During work breaks',
    'Social situations',
    'When stressed',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question 5 of 5',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '100%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Gradient Progress Bar
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  children: [
                    // Animated progress with gradient
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      height: 8,
                      width: screenWidth * 1.0 - 48, // 100% minus padding
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF2B7FFF), // Blue
                            Color(0xFF9B6CF6), // Purple
                            Color(0xFFAD46FF), // Violet
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Clock Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.lightPrimary.withValues(alpha: 0.08),
                        AppColors.lightPrimary.withValues(alpha: 0.02),
                        AppColors.lightBackground,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightPrimary.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 24,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.access_time_filled_rounded,
                          size: 40,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Question
              Center(
                child: Text(
                  'When do you smoke\nthe most?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Options
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = _selectedOption == option;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOption = option;
                        });

                        // Navigator.pushReplacement(
                        //   context,
                        //   createRightToLeftRoute(const HomeScreen()),
                        // );

                        Navigator.pushReplacement(
                          context,
                          createRightToLeftRoute(const HomeScreen()),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.lightPrimary.withValues(alpha: 0.08)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.lightPrimary
                                : AppColors.lightBorder,
                            width: isSelected ? 2 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.lightPrimary.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            // Custom Radio Button
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.lightPrimary
                                      : AppColors.lightBorder,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? AppColors.lightPrimary
                                    : AppColors.transparent,
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 16),

                            // Option Text
                            Expanded(
                              child: Text(
                                option,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.lightPrimary
                                      : AppColors.lightTextPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Helper Text
              Center(
                child: Text(
                  'Select an option to continue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.lightTextTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
