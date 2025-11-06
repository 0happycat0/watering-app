import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/widgets/search_bar.dart';
import 'package:watering_app/features/devices/presentation/widgets/sort_button.dart';
import 'package:watering_app/features/devices/providers/all_devices/realtime_devices_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_provider.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:watering_app/features/devices/presentation/widgets/device_grid_item.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;
import 'package:watering_app/theme/styles.dart';

class AllDevicesScreen extends ConsumerStatefulWidget {
  const AllDevicesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AllDevicesScreenState();
}

class _AllDevicesScreenState extends ConsumerState<AllDevicesScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  //TODO: implement sort feature
  SortOption _currentSort = SortOption.defaultSort;
  bool _isAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _unfocusSearch() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  void _onSortSelected(SortOption option) {
    setState(() {
      if (_currentSort == option) {
        // Nhấn lại cùng option → đảo thứ tự
        _isAscending = !_isAscending;
      } else {
        // Chọn option mới → reset về ascending
        _currentSort = option;
        _isAscending = true;
      }
    });

    // TODO: Implement sort logic
    print('Sort by: ${option.label}, ascending: $_isAscending');
  }

  void _onSelectDevice(Device device) {
    Navigator.of(
      context,
    ).push(
      CupertinoPageRoute(builder: (ctx) => DeviceDetailScreen(device: device)),
    );
  }

  void _showAskDeleteDialog(Device device) {
    final deleteDeviceNotifier = ref.read(deleteDeviceProvider.notifier);
    final devicesNotifier = ref.read(devicesProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
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
              Navigator.of(context).pop();
              devicesNotifier.setLoading();
              await deleteDeviceNotifier.deleteDevice(id: device.id);
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(CustomSnackBar(text: 'Đã xóa "${device.name}"'));
              }
              devicesNotifier.refresh();
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Device device) {
    final updateDeviceNotifier = ref.read(updateDeviceProvider.notifier);
    final devicesNotifier = ref.read(devicesProvider.notifier);

    final nameController = TextEditingController(text: device.name);
    final idController = TextEditingController(text: device.deviceId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sửa thông tin',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              NormalTextFormField(
                textController: nameController,
                hintText: '',
                label: 'Tên thiết bị',
                isDense: true,
              ),
              SizedBox(height: 10),
              NormalTextFormField(
                textController: idController,
                hintText: '',
                label: 'Mã thiết bị',
                isDense: true,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Hủy'),
                  ),
                  SizedBox(width: 10),
                  FilledButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      devicesNotifier.setLoading();
                      await updateDeviceNotifier.updateDevice(
                        id: device.id,
                        name: nameController.text.trim(),
                        deviceId: idController.text.trim(),
                      );
                      devicesNotifier.refresh();
                    },
                    child: Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    print('Tìm kiếm với "$query"');
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    Future.microtask(() async {
      ref.read(devicesProvider.notifier).getAllDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final devicesState = ref.watch(devicesProvider);
    //updateDeviceProvider và deleteDeviceProvider là các autoDispose, nên nếu không watch sẽ
    //không dùng được hàm update và delete, vì nó sẽ bị dispose trong dialog
    ref.watch(updateDeviceProvider);
    ref.watch(deleteDeviceProvider);

    ref.watch(devicesSensorProvider);
    ref.watch(devicesStatusProvider);
    ref.watch(devicesWateringProvider);

    ref.listen(devicesProvider, (prev, next) {
      print(
        'All devices transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
    });
    return GestureDetector(
      onTap: _unfocusSearch,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: 'Tất cả thiết bị',
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Expanded(
                    child: DeviceSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  // Nút Sort
                  DeviceSortButton(
                    currentSort: _currentSort,
                    isAscending: _isAscending,
                    onSortSelected: _onSortSelected,
                    onMenuOpened: _unfocusSearch,
                    onMenuClosed: _unfocusSearch,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: () {
            if (devicesState is devices_state.Loading) {
              return Center(child: CircularProgressIndicator());
            } else if (devicesState is devices_state.Success) {
              final devices = devicesState.devicesList;

              return RefreshIndicator(
                displacement: 40,
                edgeOffset: 0,
                onRefresh: () async {
                  await ref.read(devicesProvider.notifier).refresh();
                },
                child: Scrollbar(
                  interactive: true,
                  thickness: 5,
                  radius: Radius.circular(10),
                  child: GridView.builder(
                    primary: true,
                    padding: EdgeInsets.only(bottom: 42),
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
                        onSelectDevice: () {
                          _onSelectDevice(device);
                        },
                        onSelectDelete: () async {
                          _showAskDeleteDialog(device);
                        },
                        onSelectEdit: () {
                          _showEditDialog(device);
                        },
                      );
                    },
                  ),
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
              return Center(child: Text("Trạng thái không xác định"));
            }
          }(),
        ),
      ),
    );
  }
}
