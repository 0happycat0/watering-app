import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/providers/device_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/devices_provider.dart';
import 'package:watering_app/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:watering_app/features/devices/presentation/widgets/device_grid_item.dart';
import 'package:watering_app/features/devices/presentation/providers/devices_state.dart'
    as devices_state;
import 'package:watering_app/features/devices/presentation/providers/device_state.dart'
    as device_state;
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/theme/theme.dart';

class AllDevicesScreen extends ConsumerStatefulWidget {
  const AllDevicesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AllDevicesScreenState();
}

class _AllDevicesScreenState extends ConsumerState<AllDevicesScreen> {
  void _onSelectDevice(Device device) {
    Navigator.of(
      context,
    ).push(
      CupertinoPageRoute(builder: (ctx) => DeviceDetailScreen(device: device)),
    );
  }

  void _showAskDeleteDialog(Device device) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final deviceState = ref.watch(deviceProvider);
          return AlertDialog(
            title: Text('Xóa thiết bị'),
            content: Text(
              'Bạn có muốn xóa "${device.name}" khỏi danh sách thiết bị không?',
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Hủy'),
              ),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(deviceProvider.notifier)
                      .deleteDevice(id: device.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: deviceState is device_state.Loading
                    ? CustomCircularProgress(
                        color: colorScheme.primaryContainer,
                      )
                    : Text('Xóa'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesState = ref.watch(devicesProvider);
    ref.listen(devicesProvider, (prev, next) {
      print(
        'All devices transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
    });
    return Scaffold(
      appBar: CustomAppBar(title: 'Tất cả thiết bị'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: () {
          if (devicesState is devices_state.Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (devicesState is devices_state.Success) {
            final devices = devicesState.devicesList;

            return RefreshIndicator(
              displacement: 30,
              onRefresh: () async {
                await ref.read(devicesProvider.notifier).refresh();
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return DeviceGridItem(
                    device: device,
                    onSelectDevice: () {
                      _onSelectDevice(device);
                    },
                    onSelectDelete: () {
                      _showAskDeleteDialog(device);
                    },
                    onSelectEdit: () {
                      //TODO: add logic
                    },
                  );
                },
              ),
            );
          } else if (devicesState is devices_state.Failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(devicesState.message),
                  TextButton(
                    style: AppStyles.textButtonStyle,
                    onPressed: () async {
                      await ref.read(devicesProvider.notifier).refresh();
                    },
                    child: Text(AppStrings.tryAgain),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("Trạng thái không xác định"));
          }
        }(),
      ),
    );
  }
}
