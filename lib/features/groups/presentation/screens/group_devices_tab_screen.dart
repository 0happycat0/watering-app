import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:watering_app/features/devices/presentation/widgets/device_grid_item.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;
import 'package:watering_app/features/groups/providers/group/group_provider.dart';

class GroupDevicesTabScreen extends ConsumerStatefulWidget {
  const GroupDevicesTabScreen({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<GroupDevicesTabScreen> createState() =>
      _GroupDevicesTabScreenState();
}

class _GroupDevicesTabScreenState extends ConsumerState<GroupDevicesTabScreen> {
  late List<Device> devices;
  bool _isDeviceListInitialized = false;

  void onDeleteDevice(Device device) async {
    final List<Device> updatedListDevices = devices
        .where((dvc) => dvc.id != device.id)
        .toList();
    final List<String> updatedListIds = updatedListDevices
        .map((d) => d.id)
        .toList();
    try {
      await ref
          .read(updateGroupProvider.notifier)
          .updateGroup(
            id: widget.group.id,
            name: widget.group.name,
            listIdOfDevices: updatedListIds,
          );
      setState(() {
        devices = updatedListDevices;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          text: 'Đã xóa "${device.name}" khỏi nhóm',
        ),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          text: e.message!,
        ),
      );
    }
  }

  void showAskRemoveFromGroupDialog(Device device) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa khỏi nhóm'),
        content: Text(
          'Bạn có muốn xóa "${device.name}" khỏi nhóm "${widget.group.name}" không?',
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
              Navigator.of(context).pop();
              onDeleteDevice(device);
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    Future.microtask(() async {
      await ref
          .read(groupByIdProvider.notifier)
          .getGroupById(id: widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupByIdProvider);

    ref.watch(updateGroupProvider);
    ref.listen(groupByIdProvider, (prev, next) {
      print(
        'Schedule list transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
    });

    if (groupState is group_state.Success && !_isDeviceListInitialized) {
      devices = groupState.listDevices ?? [];
      _isDeviceListInitialized = true;
    }

    return Container(
      color: AppColors.primarySurface,
      child: groupState is group_state.Loading
          ? Center(child: CircularProgressIndicator())
          : devices.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.devices_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nhóm chưa có thiết bị nào',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Scrollbar(
                interactive: true,
                thickness: 5,
                radius: Radius.circular(10),
                child: GridView.builder(
                  primary: true,
                  padding: EdgeInsets.only(top: 12, bottom: 42),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return DeviceGridItem(
                      device: device,
                      isInGroup: true,
                      onSelectDevice: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (ctx) =>
                                DeviceDetailScreen(device: device),
                          ),
                        );
                      },
                      onSelectEdit: () {},
                      onSelectDelete: () async {
                        showAskRemoveFromGroupDialog(device);
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }
}
