import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_assets.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';
import 'package:watering_app/features/devices/providers/all_devices/realtime_devices_provider.dart';
import 'package:watering_app/theme/theme.dart';

class DeviceGridItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, HistorySensor> sensorMap = ref.watch(
      devicesSensorProvider,
    );
    final HistorySensor? sensorData = sensorMap[device.deviceId];

    final Map<String, bool> statusMap = ref.watch(devicesStatusProvider);
    final bool isOnline = statusMap[device.deviceId] ?? device.online;
    final Map<String, bool> wateringMap = ref.watch(devicesWateringProvider);
    final bool isWatering = wateringMap[device.deviceId] ?? device.watering;

    return Card(
      elevation: isOnline ? 2 : 0,
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
                              child: Row(
                                children: [
                                  isOnline
                                      ? Icon(
                                          Symbols.android_wifi_3_bar_rounded,
                                          color: isWatering
                                              ? AppColors.mainBlue[400]
                                              : colorScheme.primary,
                                        )
                                      : Icon(
                                          Symbols.wifi_off_rounded,
                                          color: isWatering
                                              ? AppColors.mainBlue[400]
                                              : colorScheme.primary,
                                        ),
                                  if (isWatering)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.mainBlue[400]!
                                            .withValues(alpha: 0.8),
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
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: Image.asset(
                                isWatering
                                    ? AppAssets.wateringPlant
                                    : AppAssets.plant,
                                fit: BoxFit.fitHeight,
                                // color: AppColors.mainGreen[200],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              device.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: isWatering
                                    ? AppColors.mainBlue[400]
                                    : colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              device.deviceId,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //Thông số cảm biến
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 60),
                  // ClipRRect để bo góc cho BackdropFilter
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isWatering
                              ? AppColors.mainBlue[50]!.withValues(alpha: 0.6)
                              : AppColors.primarySurface.withValues(
                                  alpha: 0.6,
                                ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMetricRow(
                              context: context,
                              icon: Symbols.thermostat,
                              label: 'Nhiệt độ',
                              isWatering: isWatering,
                              value: sensorData != null
                                  ? '${sensorData.temp.toStringAsFixed(0)}°C'
                                  : '--',
                            ),
                            SizedBox(height: 6),
                            _buildMetricRow(
                              context: context,
                              icon: Symbols.water,
                              label: 'Độ ẩm KK',
                              isWatering: isWatering,
                              value: sensorData != null
                                  ? '${sensorData.air.toStringAsFixed(0)}%'
                                  : '--',
                            ),
                            SizedBox(height: 6),
                            _buildMetricRow(
                              context: context,
                              icon: Symbols.water_drop,
                              label: 'Độ ẩm đất',
                              isWatering: isWatering,
                              value: sensorData != null
                                  ? '${sensorData.soil.toStringAsFixed(0)}%'
                                  : '--',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //lớp phủ khi offline
              if (!isOnline)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 207, 206, 206).withAlpha(140),
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildMetricRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isWatering,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      color: colorScheme.primary,
      fontSize: 12,
    );

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isWatering ? AppColors.mainBlue[400] : colorScheme.primary,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: textStyle.copyWith(
              color: isWatering ? AppColors.mainBlue[400] : null,
            ),
          ),
        ),
        Text(
          value,
          style: textStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: isWatering ? AppColors.mainBlue[400] : null,
          ),
        ),
      ],
    );
  }
}
