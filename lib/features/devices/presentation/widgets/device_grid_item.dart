import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/theme/theme.dart';

class DeviceGridItem extends StatelessWidget {
  const DeviceGridItem({
    super.key,
    required this.device,
    required this.onSelectDevice,
    required this.onSelectEdit,
    required this.onSelectDelete,
  });

  final Device device;
  final void Function() onSelectDevice;
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
        onTap: onSelectDevice,
        splashColor: colorScheme.primaryContainer,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.mainGreen[50]!,
                AppColors.mainGreen[100]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(device.deviceId),
                    ],
                  ),
                ),
              ),
              // Nút menu góc phải
              Positioned(
                right: 0,
                top: 0,
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 22),
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
                          Text('Xóa thiết bị'),
                        ],
                      ),
                    ),
                  ],
                  offset: const Offset(-8, 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
