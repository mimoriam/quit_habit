import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

// Enum to manage the day's status
enum DayStatus { clean, relapse, none }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // --- State Variables ---

  // Controls the visible month
  DateTime _focusedDay = DateTime(2022, 9, 13);
  // Controls the tapped/selected day
  DateTime _selectedDay = DateTime(2022, 9, 13);

  // Hardcoded data to match the provided image
  final Set<DateTime> _relapseDays = {
    DateUtils.dateOnly(DateTime(2022, 9, 13)),
  };

  final Set<DateTime> _cleanDays = {
    DateUtils.dateOnly(DateTime(2022, 9, 14)),
    DateUtils.dateOnly(DateTime(2022, 9, 15)),
    DateUtils.dateOnly(DateTime(2022, 9, 16)),
    DateUtils.dateOnly(DateTime(2022, 9, 17)),
    DateUtils.dateOnly(DateTime(2022, 9, 18)),
    DateUtils.dateOnly(DateTime(2022, 9, 19)),
    DateUtils.dateOnly(DateTime(2022, 9, 20)),
    DateUtils.dateOnly(DateTime(2022, 9, 21)),
  };

  /// Checks the status of a given day
  DayStatus _getDayStatus(DateTime day) {
    if (_relapseDays.contains(DateUtils.dateOnly(day))) {
      return DayStatus.relapse;
    }
    if (_cleanDays.contains(DateUtils.dateOnly(day))) {
      return DayStatus.clean;
    }
    return DayStatus.none;
  }

  /// Adds or removes a relapse for the selected day
  void _toggleRelapse() {
    setState(() {
      final day = DateUtils.dateOnly(_selectedDay);
      if (_relapseDays.contains(day)) {
        _relapseDays.remove(day);
      } else {
        _relapseDays.add(day);
        _cleanDays.remove(day); // A day can't be both
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DayStatus selectedDayStatus = _getDayStatus(_selectedDay);

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
          'Calendar',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildLegend(theme),
              const SizedBox(height: 16),
              _buildCalendar(theme),
              const SizedBox(height: 24),
              _buildSelectedDayInfo(theme, selectedDayStatus),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _toggleRelapse,
                  style: selectedDayStatus == DayStatus.relapse
                      ? ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.lightError.withOpacity(0.1),
                          foregroundColor: AppColors.lightError,
                          elevation: 0,
                          side: const BorderSide(
                              color: AppColors.lightError, width: 1.5),
                        )
                      : null,
                  child: Text(
                    selectedDayStatus == DayStatus.relapse
                        ? 'Remove Relapse'
                        : 'Add Relapse',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedDayStatus == DayStatus.relapse
                          ? AppColors.lightError
                          : AppColors.white,
                    ),
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
  Widget _buildCalendar(ThemeData theme) {
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
          _focusedDay = focusedDay;
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
            final status = _getDayStatus(day);
            final isSelected = isSameDay(day, _selectedDay);
            final isOutside = day.month != focusedDay.month;

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
            }

            if (isSelected) {
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
              child: Center(
                child: Text(
                  '${day.day}',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the bottom card showing selected day's info
  Widget _buildSelectedDayInfo(ThemeData theme, DayStatus status) {
    IconData icon;
    Color iconColor;
    String text;

    switch (status) {
      case DayStatus.relapse:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.lightError;
        text = 'Relapse on this day';
        break;
      case DayStatus.clean:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.lightPrimary;
        text = 'Clean day';
        break;
      case DayStatus.none:
      default:
        icon = Icons.check_circle_outline_rounded;
        iconColor = AppColors.lightSuccess;
        text = 'No relapses on this day';
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
              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: iconColor,
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