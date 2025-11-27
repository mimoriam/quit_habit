import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/habit_data.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

// Enum to manage the day's status
enum DayStatus { clean, relapse, none, notStarted }

class CalendarScreen extends StatefulWidget {
  final bool? isStartDateSelection;
  final DateTime? initialDate;
  final bool allowAddRelapse;

  const CalendarScreen({
    super.key,
    this.isStartDateSelection,
    this.initialDate,
    this.allowAddRelapse = false,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // --- State Variables ---
  final HabitService _habitService = HabitService();
  bool _isLoading = false;
  String? _errorMessage;

  // Controls the visible month
  late DateTime _focusedDay;
  // Controls the tapped/selected day
  late DateTime _selectedDay;

  // Check if this is start date selection mode
  bool get _isStartDateSelection =>
      widget.isStartDateSelection ?? false;
  
  // Check if Add Relapse button should be shown
  bool get _shouldShowAddRelapse => widget.allowAddRelapse;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = widget.initialDate ?? now;
    _selectedDay = widget.initialDate ?? now;
  }

  /// Checks the status of a given day from habit data
  DayStatus _getDayStatus(HabitData? habitData, List<RelapsePeriod> relapsePeriods, DateTime day) {
    if (habitData == null) {
      return DayStatus.notStarted;
    }

    final status = _habitService.getDayStatus(habitData, relapsePeriods, day);
    switch (status) {
      case 'not_started':
        return DayStatus.notStarted;
      case 'relapse':
        return DayStatus.relapse;
      case 'clean':
        return DayStatus.clean;
      default:
        return DayStatus.none;
    }
  }

  /// Check if a date can be edited (current or past dates only, not future)
  bool _canEditDate(DateTime date) {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final dateNormalized = DateTime(date.year, date.month, date.day);
    return !dateNormalized.isAfter(todayNormalized);
  }

  /// Check if today is relapsed
  bool _isTodayRelapsed(HabitData? habitData, List<RelapsePeriod> relapsePeriods) {
    if (habitData == null) return false;
    final today = DateTime.now();
    return _habitService.getDayStatus(habitData, relapsePeriods, today) == 'relapse';
  }

  /// Handle start date selection
  Future<void> _handleStartDateSelection() async {
    if (!_canEditDate(_selectedDay)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be in the future'),
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _habitService.setStartDate(user.uid, _selectedDay);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start date set successfully'),
            backgroundColor: AppColors.lightSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } on HabitServiceException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to set start date: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set start date: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Adds or removes a relapse for the selected day
  Future<void> _toggleRelapse(HabitData? habitData, List<RelapsePeriod> relapsePeriods) async {
    if (habitData == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    // Check if date can be edited
    if (!_canEditDate(_selectedDay)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit future dates'),
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    // Check if today is relapsed and trying to edit today
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final selectedNormalized = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final isToday = selectedNormalized == todayNormalized;
    final todayRelapsed = _isTodayRelapsed(habitData, relapsePeriods);

    if (isToday && todayRelapsed) {
      // Can't remove today's relapse from calendar (must use report relapse screen)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot modify today\'s relapse from calendar'),
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentStatus = _getDayStatus(habitData, relapsePeriods, _selectedDay);
      if (currentStatus == DayStatus.relapse) {
        // Remove relapse
        await _habitService.removeRelapse(user.uid, _selectedDay);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Relapse removed'),
              backgroundColor: AppColors.lightSuccess,
            ),
          );
        }
      } else {
        // Need trigger to add relapse - navigate to report relapse screen
        // But first check if we can add it
        if (habitData.startDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please set start date first'),
              backgroundColor: AppColors.lightError,
            ),
          );
          return;
        }

        // Navigate to report relapse screen with pre-selected date
        if (mounted) {
          Navigator.pop(context);
          // The parent screen should handle navigation to report relapse
          // For now, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please use Report Relapse to add a relapse'),
              backgroundColor: AppColors.lightWarning,
            ),
          );
        }
      }
    } on HabitServiceException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update relapse: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update relapse: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.lightTextPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isStartDateSelection ? 'Select Start Date' : 'Calendar',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: const Center(
          child: Text('Please log in to view calendar'),
        ),
      );
    }

    return StreamBuilder<HabitDataWithRelapses?>(
      stream: _habitService.getHabitDataStream(user.uid),
      builder: (context, snapshot) {
        final dataWithRelapses = snapshot.data;
        final habitData = dataWithRelapses?.habitData ?? HabitData.empty();
        final relapsePeriods = dataWithRelapses?.relapsePeriods ?? [];
        final selectedDayStatus = _getDayStatus(habitData, relapsePeriods, _selectedDay);

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: AppColors.lightBackground,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.lightTextPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _isStartDateSelection ? 'Select Start Date' : 'Calendar',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildLegend(theme),
                        const SizedBox(height: 16),
                        _buildCalendar(theme, habitData, relapsePeriods),
                        const SizedBox(height: 24),
                        _buildSelectedDayInfo(theme, selectedDayStatus, habitData, relapsePeriods),
                        const SizedBox(height: 16),
                        if (_isStartDateSelection)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleStartDateSelection,
                              child: Text(
                                'Set Start Date',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else if (selectedDayStatus == DayStatus.relapse && _canEditDate(_selectedDay))
                          // Show "Remove Relapse" button when day has relapse, regardless of allowAddRelapse
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _toggleRelapse(habitData, relapsePeriods),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.lightError.withOpacity(0.1),
                                foregroundColor: AppColors.lightError,
                                elevation: 0,
                                side: const BorderSide(
                                    color: AppColors.lightError, width: 1.5),
                              ),
                              child: Text(
                                'Remove Relapse',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightError,
                                ),
                              ),
                            ),
                          )
                        else if (_shouldShowAddRelapse && _canEditDate(_selectedDay) && selectedDayStatus != DayStatus.relapse)
                          // Show "Add Relapse" button only when allowAddRelapse is true and day doesn't have relapse
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _toggleRelapse(habitData, relapsePeriods),
                              child: Text(
                                'Add Relapse',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightError.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.lightError.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.lightError,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// Builds the legend at the top
  Widget _buildLegend(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LegendItem(
            color: AppColors.lightPrimary,
            label: 'Clean Day',
            theme: theme,
          ),
          _LegendItem(
            color: AppColors.lightError,
            label: 'Relapse',
            theme: theme,
          ),
          _LegendItem(
            color: AppColors.lightTextTertiary.withOpacity(0.8),
            label: 'Selected',
            theme: theme,
          ),
        ],
      ),
    );
  }

  /// Builds the main TableCalendar widget
  Widget _buildCalendar(ThemeData theme, HabitData habitData, List<RelapsePeriod> relapsePeriods) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: TableCalendar(
        locale: 'en_US',
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2040, 12, 31),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // update focused day on selection
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        // --- STYLING ---
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.headlineSmall!
              .copyWith(fontWeight: FontWeight.w600),
          leftChevronIcon:
              const Icon(Icons.chevron_left, color: AppColors.lightTextPrimary),
          rightChevronIcon: const Icon(Icons.chevron_right,
              color: AppColors.lightTextPrimary),
          headerPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (date, locale) =>
              DateFormat.E(locale).format(date)[0],
          weekdayStyle: theme.textTheme.bodyMedium!
              .copyWith(color: AppColors.lightTextSecondary),
          weekendStyle: theme.textTheme.bodyMedium!
              .copyWith(color: AppColors.lightTextSecondary),
        ),
        calendarBuilders: CalendarBuilders(
          // Custom builder for the day cells
          prioritizedBuilder: (context, day, focusedDay) {
            final status = _getDayStatus(habitData, relapsePeriods, day);
            final isSelected = isSameDay(day, _selectedDay);
            final isOutside = day.month != focusedDay.month;
            final today = DateTime.now();
            final todayNormalized = DateTime(today.year, today.month, today.day);
            final dayNormalized = DateTime(day.year, day.month, day.day);
            final isToday = dayNormalized == todayNormalized;
            final isTodayRelapsed = isToday && _isTodayRelapsed(habitData, relapsePeriods);

            // Check if this is the start date
            bool isStartDate = false;
            if (habitData.startDate != null) {
              final startDate = habitData.startDate!;
              final startDateNormalized = DateTime(
                startDate.year,
                startDate.month,
                startDate.day,
              );
              isStartDate = dayNormalized == startDateNormalized;
            }

            Color bgColor = AppColors.transparent;
            Color textColor = AppColors.lightTextPrimary;
            FontWeight fontWeight = FontWeight.w400;
            BoxBorder? border;

            if (isOutside) {
              textColor = AppColors.lightTextTertiary;
            } else if (status == DayStatus.relapse) {
              bgColor = AppColors.lightError;
              textColor = AppColors.white;
              fontWeight = FontWeight.w600;
            } else if (status == DayStatus.clean) {
              bgColor = AppColors.lightPrimary;
              textColor = AppColors.white;
              fontWeight = FontWeight.w600;
            } else if (status == DayStatus.notStarted) {
              textColor = AppColors.lightTextTertiary;
            }

            // Add green border for start date
            if (isStartDate) {
              border = Border.all(
                color: AppColors.lightSuccess,
                width: 2,
              );
            } else if (isSelected) {
              // Add a border for selection
              border = Border.all(
                color: AppColors.lightTextTertiary.withOpacity(0.8),
                width: 2,
              );
            }

            return Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: border,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      '${day.day}',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: textColor,
                        fontWeight: fontWeight,
                      ),
                    ),
                  ),
                  if (isTodayRelapsed)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.lightWarning,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the bottom card showing selected day's info
  Widget _buildSelectedDayInfo(
    ThemeData theme,
    DayStatus status,
    HabitData habitData,
    List<RelapsePeriod> relapsePeriods,
  ) {
    IconData icon;
    Color iconColor;
    String text;

    switch (status) {
      case DayStatus.relapse:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.lightError;
        // Find the trigger for this relapse
        final relapse = relapsePeriods.firstWhere(
          (r) {
            final relapseDate = DateTime(
              r.date.year,
              r.date.month,
              r.date.day,
            );
            final selectedDate = DateTime(
              _selectedDay.year,
              _selectedDay.month,
              _selectedDay.day,
            );
            return relapseDate == selectedDate;
          },
          orElse: () => RelapsePeriod(date: _selectedDay, trigger: 'Unknown'),
        );
        text = 'Relapse on this day\nTrigger: ${relapse.trigger}';
        break;
      case DayStatus.clean:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.lightPrimary;
        text = 'Clean day';
        break;
      case DayStatus.notStarted:
        icon = Icons.calendar_today_outlined;
        iconColor = AppColors.lightTextTertiary;
        text = 'Not started yet';
        break;
      case DayStatus.none:
        icon = Icons.check_circle_outline_rounded;
        iconColor = AppColors.lightSuccess;
        text = 'No relapses on this day';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.lightTextPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Selected Date',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, yyyy').format(_selectedDay),
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.lightBorder),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper widget for a single item in the legend
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
  });

  final Color color;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.lightTextPrimary),
        ),
      ],
    );
  }
}