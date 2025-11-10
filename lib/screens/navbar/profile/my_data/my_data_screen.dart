import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

class MyDataScreen extends StatefulWidget {
  const MyDataScreen({super.key});

  @override
  State<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends State<MyDataScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0, // Adjust spacing to match screenshot
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Data',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your smoking information',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 1. Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.lightPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This information helps calculate your savings and health improvements accurately.',
                        // *** CHANGED: Removed custom color styling ***
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Data Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildDataRow(
                      theme,
                      icon: Icons.calendar_today_outlined,
                      title: 'Quit Date',
                      value: 'January 15, 2025',
                    ),
                    const Divider(
                      height: 1.5,
                      color: AppColors.lightBorder,
                      indent: 68, // 16 (pad) + 24 (icon) + 28 (pad)
                    ),
                    _buildDataRow(
                      theme,
                      icon: Icons.smoking_rooms_outlined,
                      title: 'Cigarettes per Day',
                      value: '20 cigarettes',
                    ),
                    const Divider(
                      height: 1.5,
                      color: AppColors.lightBorder,
                      indent: 68,
                    ),
                    _buildDataRow(
                      theme,
                      icon: Icons.trending_up_outlined,
                      title: 'Price',
                      value: '\$5.00',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle update logic
                  },
                  style: theme.elevatedButtonTheme.style,
                  child: Text(
                    'Update Information',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 4. "YOUR IMPACT" Header
              Text(
                'YOUR IMPACT',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),

              // 5. Impact Cards
              Row(
                children: [
                  Expanded(
                    child: _buildImpactCard(
                      theme,
                      value: '300',
                      label: 'Not Smoked',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImpactCard(
                      theme,
                      value: '\$75',
                      label: 'Money Saved',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a row for the data card (e.g., "Quit Date")
  Widget _buildDataRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightPrimary, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds one of the "Impact" cards
  Widget _buildImpactCard(
    ThemeData theme, {
    required String value,
    required String label,
  }) {
    return Container(
      // *** CHANGED: Reduced padding for a more compact size ***
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        // *** CHANGED: Centered content ***
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
