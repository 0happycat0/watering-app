import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/providers/all_groups/realtime_groups_provider.dart';
import 'package:watering_app/theme/theme.dart';

class GroupGridItem extends ConsumerWidget {
  const GroupGridItem({
    super.key,
    required this.group,
    required this.onSelectGroup,
    required this.onSelectEdit,
    required this.onSelectDelete,
  });

  final Group group;
  final void Function() onSelectGroup;
  final void Function() onSelectEdit;
  final void Function() onSelectDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, bool> wateringMap = ref.watch(groupsWateringProvider);
    final bool isWatering = wateringMap[group.id] ?? group.watering;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isWatering
              ? AppColors.mainBlue[200]!
              : AppColors.mainGreen[100]!,
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: InkWell(
        onTap: onSelectGroup,
        splashColor: isWatering
            ? AppColors.mainBlue[150]!
            : colorScheme.primaryContainer,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isWatering ? AppColors.mainBlue[50]! : AppColors.mainGreen[10]!,
                isWatering
                    ? AppColors.mainBlue[100]!
                    : AppColors.mainGreen[50]!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      // Tên nhóm
                      Text(
                        group.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: isWatering
                              ? AppColors.mainBlue[400]
                              : colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      SizedBox(height: 8),

                      // Số lượng thiết bị
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isWatering
                              ? AppColors.mainBlue[50]!.withValues(alpha: 0.6)
                              : AppColors.primarySurface.withValues(
                                  alpha: 0.6,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isWatering
                                ? AppColors.divider
                                : AppColors.mainGreen[100]!.withAlpha(150),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.sprinkler,
                              size: 16,
                              color: isWatering
                                  ? AppColors.mainBlue[400]
                                  : colorScheme.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${group.devicesQuantity} thiết bị',
                              style: TextStyle(
                                color: isWatering
                                    ? AppColors.mainBlue[400]
                                    : colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Nút menu góc phải
              Positioned(
                right: -4,
                top: 0,
                child: Row(
                  children: [
                    if (isWatering)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mainBlue[400]!.withValues(
                            alpha: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.5,
                            ),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.power_settings_new,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Đang tưới',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Symbols.more_vert,
                        size: 22,
                        weight: 1000,
                        color: isWatering
                            ? AppColors.mainBlue[400]
                            : colorScheme.primary,
                      ),
                      splashRadius: 20,
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onSelectEdit();
                            break;
                          case 'delete':
                            onSelectDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          height: 40,
                          child: Row(
                            children: [
                              Icon(Symbols.edit),
                              SizedBox(width: 12),
                              Text('Sửa thông tin'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          height: 40,
                          child: Row(
                            children: [
                              Icon(Symbols.delete, color: colorScheme.error),
                              SizedBox(width: 12),
                              Text('Xóa nhóm'),
                            ],
                          ),
                        ),
                      ],
                      offset: Offset(-8, 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
