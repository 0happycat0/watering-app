import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';

class ScheduleListItem extends StatelessWidget {
  const ScheduleListItem({
    super.key,
    required this.schedule,
    required this.onToggle,
    required this.onSelectEdit,
    required this.onSelectDelete,
  });

  final Schedule schedule;
  final void Function(bool) onToggle;
  final void Function() onSelectEdit;
  final void Function() onSelectDelete;

  // Helper để hiển thị text cho RepeatType
  String _getRepeatText(RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.EVERYDAY:
        return 'Mỗi ngày';
      case RepeatType.DAYS:
        return 'Các ngày đã chọn';
      case RepeatType.ONE_TIME:
        return 'Một lần';
      // ignore: unreachable_switch_default
      default:
        return '';
    }
  }

  String _formatDisplayTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  static const Map<String, DaysOfWeek> dayMap = {
    'T2': DaysOfWeek.MON,
    'T3': DaysOfWeek.TUE,
    'T4': DaysOfWeek.WED,
    'T5': DaysOfWeek.THU,
    'T6': DaysOfWeek.FRI,
    'T7': DaysOfWeek.SAT,
    'CN': DaysOfWeek.SUN,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Danh sách các ngày hiển thị trên UI
    final List<String> allDayLabels = [
      'T2',
      'T3',
      'T4',
      'T5',
      'T6',
      'T7',
      'CN',
    ];
    final String repeatText = _getRepeatText(schedule.repeatType);
    final String displayTime = _formatDisplayTime(schedule.startTime);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Opacity(
        opacity: schedule.status ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hàng trên: Icon, Thời gian, Thông tin, Nút bật/tắt
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mainGreen[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Symbols.schedule,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTime,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${schedule.duration} phút • $repeatText',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: schedule.status,
                    onChanged: onToggle,
                    activeThumbColor: AppColors.mainGreen[50]!.withAlpha(0),
                    activeTrackColor: AppColors.mainGreen[400]!.withAlpha(220),
                    inactiveThumbColor: AppColors.mainGreen[500],
                    inactiveTrackColor: AppColors.mainGreen[300]!.withAlpha(80),
                    trackOutlineColor: WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: allDayLabels.map((dayLabel) {
                  final dayEnum = dayMap[dayLabel];
                  final bool isActive =
                      schedule.daysOfWeek?.contains(dayEnum) ?? false;

                  return _DayChip(
                    label: dayLabel,
                    isActive: isActive,
                  );
                }).toList(),
              ),

              // Divider(
              //   height: 24,
              //   thickness: 1,
              //   color: AppColors.mainGreen[100],
              // ),
              SizedBox(height: 20),

              // Hàng dưới: Nút Sửa, Xóa
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onSelectEdit,
                    icon: Icon(Symbols.edit, size: 20),
                    label: Text('Sửa'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onSelectDelete,
                    icon: Icon(Symbols.delete, size: 20),
                    label: Text('Xóa'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.mainGreen[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}
