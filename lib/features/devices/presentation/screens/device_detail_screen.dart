import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/features/devices/presentation/screens/schedule_tab_screen.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/screens/analytics_tab_screen.dart';
import 'package:watering_app/features/devices/presentation/screens/control_tab_screen.dart';
import 'package:watering_app/theme/theme.dart';

class DeviceDetailScreen extends ConsumerStatefulWidget {
  const DeviceDetailScreen({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen> {
  void _showAskDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final deviceState = ref.watch(deleteDeviceProvider);
          return AlertDialog(
            title: Text('Xóa thiết bị'),
            content: Text(
              'Bạn có muốn xóa "${widget.device.name}" khỏi danh sách thiết bị không?',
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
                      .read(deleteDeviceProvider.notifier)
                      .deleteDevice(id: widget.device.id);
                  ref.read(devicesProvider.notifier).refresh();
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
    final device = widget.device;
    ref.listen(deleteDeviceProvider, (prev, next) {
      print(
        'Delete device transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
      if (next is device_state.Failure) {
        final message = next.message;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: message));
      }
      if (next is device_state.Success && prev is device_state.Loading) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: 'Đã xóa "${widget.device.name}"'));
      }
    });

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,
          title: widget.device.name,
          leading: BackIcon(),
          actions: [
            IconButton(
              onPressed: _showAskDeleteDialog,
              icon: Icon(
                Symbols.delete,
                size: 28,
              ),
            ),
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: <Widget>[
              Tab(text: 'Điều khiển'),
              Tab(text: 'Theo dõi'),
              Tab(text: 'Lên lịch'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ControlTabScreen(device: device),
            AnalyticsTabScreen(device: device),
            ScheduleTabScreen(device: device),
          ],
        ),
      ),
    );
  }
}
