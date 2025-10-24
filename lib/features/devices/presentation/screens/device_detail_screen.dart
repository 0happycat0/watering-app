import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/features/devices/presentation/providers/device_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device_state.dart'
    as device_state;
import 'package:watering_app/features/devices/data/models/device_model.dart';
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
          final deviceState = ref.watch(deviceProvider);
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
                onPressed: () {
                  ref
                      .read(deviceProvider.notifier)
                      .deleteDevice(id: widget.device.id);
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
    ref.listen(deviceProvider, (prev, next) {
      print(
        'All devices transition: ${prev.runtimeType} -> ${next.runtimeType}',
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
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(text: 'Đã xóa "${widget.device.name}"')
        );
      }
    });
    return Scaffold(
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
      ),
    );
  }
}
