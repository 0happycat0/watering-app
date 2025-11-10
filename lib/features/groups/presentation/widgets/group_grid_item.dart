import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/theme/theme.dart';

class GroupGridItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: InkWell(
        onTap: onSelectGroup,
        splashColor: colorScheme.primaryContainer,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.mainGreen[10]!,
                AppColors.mainGreen[10]!,
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
                      // Tên nhóm
                      Text(
                        group.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      // // Số lượng thiết bị
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 12,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primarySurface.withValues(
                      //       alpha: 0.6,
                      //     ),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: AppColors.divider,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         Symbols.devices,
                      //         size: 16,
                      //         color: colorScheme.primary,
                      //       ),
                      //       SizedBox(width: 6),
                      //       Text(
                      //         '$deviceCount thiết bị',
                      //         style: TextStyle(
                      //           color: colorScheme.primary,
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              // Nút menu góc phải
              Positioned(
                right: -4,
                top: 0,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Symbols.more_vert,
                    size: 22,
                    weight: 1000,
                    color: colorScheme.primary,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
