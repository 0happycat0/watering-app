import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';

class ScheduleItemCard extends StatelessWidget {
  const ScheduleItemCard({
    super.key,
    required this.theme,
    this.device,
    this.group,
    required this.onTap,
  });

  final ThemeData theme;
  final Device? device;
  final Group? group;
  final VoidCallback onTap;

  String _formatRunAfter(int? seconds) {
    if (seconds == null) return '--';

    if (seconds < 3600) {
      // Dưới 1 giờ: hiển thị phút (làm tròn lên)
      final minutes = (seconds / 60).ceil();
      return 'Còn $minutes phút';
    } else {
      final hours = seconds / 3600;
      final hoursStr = hours.toStringAsFixed(0);
      return 'Còn $hoursStr giờ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = group != null;
    final Schedule? nextSchedule = isGroup
        ? group?.nextSchedule
        : device?.nextSchedule;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.divider,
        child: Ink(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Skeleton.keep(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mainBlue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Symbols.schedule,
                      color: AppColors.mainBlue[500],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGroup ? group!.name : device!.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextSchedule?.startTime.substring(0, 5) ?? '--',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Skeleton.unite(
                        child: Row(
                          children: [
                            Icon(
                              Symbols.timer,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${nextSchedule?.duration.toString() ?? '--'} phút',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            // const SizedBox(width: 12),
                            // Icon(
                            //   Symbols.settings_remote,
                            //   size: 16,
                            //   color: Colors.grey[600],
                            // ),
                            // const SizedBox(width: 4),
                            // Text(
                            //   item['devices']!,
                            //   style: theme.textTheme.bodyMedium?.copyWith(
                            //     color: Colors.grey[600],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatRunAfter(nextSchedule?.runAfter),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
