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
    this.isOnline = true,
  });

  final Device device;
  final bool isOnline;
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
                AppColors.mainGreen[10]!,
                AppColors.mainGreen[150]!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // color: colorScheme.onPrimary,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        // color: Colors.white54,
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: isOnline
                                  ? Icon(Symbols.android_wifi_3_bar_rounded)
                                  : Icon(Symbols.wifi_off_rounded),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: Image.asset(
                                'assets/images/plant.png',
                                fit: BoxFit.fitHeight,
                                color: AppColors.mainGreen[200],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Divider(
                        thickness: 1,
                        height: 10,
                        color: colorScheme.primary.withAlpha(60),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            device.name,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            device.deviceId,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Nút menu góc phải
              Positioned(
                right: -4,
                top: 0,
                child: PopupMenuButton<String>(
                  icon: Icon(Symbols.more_vert, size: 22, weight: 1000),
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
