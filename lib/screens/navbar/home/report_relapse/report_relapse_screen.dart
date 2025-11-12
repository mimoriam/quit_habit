import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

class ReportRelapseScreen extends StatefulWidget {
  const ReportRelapseScreen({super.key});

  @override
  State<ReportRelapseScreen> createState() => _ReportRelapseScreenState();
}

class _ReportRelapseScreenState extends State<ReportRelapseScreen> {
  String? _selectedTrigger;

  final List<Map<String, dynamic>> _triggers = [
    {
      'icon': Icons.sentiment_dissatisfied_outlined,
      'label': 'Stress or anxiety',
    },
    {'icon': Icons.people_outline, 'label': 'Social pressure'},
    {'icon': Icons.sentiment_neutral_outlined, 'label': 'Boredom'},
    {'icon': Icons.celebration_outlined, 'label': 'Celebration/Party'},
    {'icon': Icons.replay_outlined, 'label': 'Old habits/routine'},
    {'icon': Icons.help_outline, 'label': 'Other reason'},
  ];

  void _handleConfirm() {
    // TODO: Implement relapse logic (e.g., reset streak, log trigger)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Error Banner
            _buildTopBanner(context, theme),

            // 2. Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headers
                      Text(
                        'What triggered this relapse?',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Understanding triggers helps prevent future relapses',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),

                      // Triggers Grid
                      _buildTriggersGrid(theme),
                      const SizedBox(height: 12),

                      // Warning Box
                      _buildWarningBox(theme),
                      const SizedBox(height: 12),

                      // Action Buttons
                      _buildActionButtons(theme),
                      const SizedBox(height: 12),

                      // Footer Box
                      _buildFooterBox(theme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      decoration: BoxDecoration(
        // --- UPDATED: .withValues instead of .withOpacity ---
        color: AppColors.lightError.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            // --- UPDATED: .withValues instead of .withOpacity ---
            color: AppColors.lightError.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.lightError,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "It's okay, setbacks happen. Let's learn from this.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightError.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.lightTextSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggersGrid(ThemeData theme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _triggers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final trigger = _triggers[index];
        final isSelected = _selectedTrigger == trigger['label'];
        return _TriggerOptionCard(
          icon: trigger['icon'],
          label: trigger['label'],
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedTrigger = trigger['label'];
            });
          },
        );
      },
    );
  }

  Widget _buildWarningBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // --- UPDATED: .withValues instead of .withOpacity ---
        color: AppColors.lightWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // --- UPDATED: .withValues instead of .withOpacity ---
          color: AppColors.lightWarning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.lightWarning.withValues(alpha: 0.9),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This will reset your current streak, but your achievements remain!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightWarning.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(
                  color: AppColors.lightBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Confirm Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedTrigger == null ? null : _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightError,
                // --- UPDATED: .withValues instead of .withOpacity ---
                disabledBackgroundColor: AppColors.lightError.withValues(
                  alpha: 0.4,
                ),
              ),
              child: Text(
                'Confirm',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // --- UPDATED: .withValues instead of .withOpacity ---
        color: AppColors.lightPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // --- UPDATED: .withValues instead of .withOpacity ---
          color: AppColors.lightPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          "Remember: You're stronger than you think. This is just a temporary setback, not a failure. Start fresh today!",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Helper widget for the trigger option cards
class _TriggerOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TriggerOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? AppColors.lightPrimary
        : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          // --- UPDATED: .withValues instead of .withOpacity ---
          color: isSelected
              ? AppColors.lightPrimary.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    // --- UPDATED: .withValues instead of .withOpacity ---
                    color: AppColors.lightPrimary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    // --- UPDATED: .withValues instead of .withOpacity ---
                    color: AppColors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
