import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quit_habit/screens/after_login_questionnaire/questionnaire4_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:quit_habit/utils/navigation_utils.dart';

class Questionnaire2Screen extends StatefulWidget {
  final String? smokingDuration;

  const Questionnaire2Screen({
    super.key,
    this.smokingDuration,
  });

  @override
  State<Questionnaire2Screen> createState() => _Questionnaire2ScreenState();
}

class _Questionnaire2ScreenState extends State<Questionnaire2Screen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _currentInput = "";

  @override
  void initState() {
    super.initState();
    // Request focus for the text field when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Handles navigation to the next screen
  void _onNext() {
    final cigarettesPerDay = int.tryParse(_currentInput);
    if (cigarettesPerDay == null || cigarettesPerDay <= 0) {
      return; // Should not happen due to validation, but safety check
    }

    Navigator.push(
      context,
      createRightToLeftRoute(
        Questionnaire4Screen(
          smokingDuration: widget.smokingDuration,
          cigarettesPerDay: cigarettesPerDay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isInputEmpty = _currentInput.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // --- WRAPPED IN SingleChildScrollView ---
      body: SingleChildScrollView(
        child: SafeArea(
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
                      'Question 2 of 5', // Changed
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '40%', // Changed
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
                    color: AppColors.lightBorder.withAlpha(77), // ~30%
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Stack(
                    children: [
                      // Animated progress with gradient
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: 8,
                        width: screenWidth * 0.4 - 48, // 40% minus padding
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

                // --- REDUCED SPACING ---
                const SizedBox(height: 32),

                // Icon (Changed to cigarette pack)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.lightPrimary.withAlpha(20), // ~8%
                          AppColors.lightPrimary.withAlpha(5), // ~2%
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
                              color: AppColors.lightPrimary.withAlpha(
                                25,
                              ), // 10%
                              blurRadius: 24,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'images/icons/cig_2.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- REDUCED SPACING ---
                const SizedBox(height: 24),

                // Question
                Center(
                  child: Text(
                    'How many cigarettes do you smoke per day?', // Changed
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

                // --- REDUCED SPACING ---
                const SizedBox(height: 16),

                // Input Field
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  // Use standard number keyboard
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(3), // Limit to 3 digits
                  ],
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: '0',
                    hintStyle: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                      color: AppColors.lightTextTertiary.withAlpha(128), // 50%
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentInput = value;
                    });
                  },
                ),

                // --- REDUCED SPACING ---
                const SizedBox(height: 16),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isInputEmpty ? null : _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.lightPrimary.withAlpha(
                        128,
                      ), // 50%
                    ),
                    child: Text(
                      'Next',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // --- REMOVED Spacer ---

                // --- ADDED Bottom Padding ---
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
