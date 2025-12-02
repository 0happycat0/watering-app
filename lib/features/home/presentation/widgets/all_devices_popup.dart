import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/core/widgets/search_bar.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/features/devices/presentation/widgets/device_grid_item.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;
import 'package:watering_app/theme/styles.dart';

class AllDevicesPopup extends ConsumerStatefulWidget {
  const AllDevicesPopup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AllDevicesPopupState();
}

class _AllDevicesPopupState extends ConsumerState<AllDevicesPopup> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Load dữ liệu mới khi mở popup để đảm bảo list update
    Future.microtask(() async {
      if (!mounted) return;
      await ref.read(devicesProvider.notifier).getAllDevices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _unfocusSearch() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref
          .read(devicesProvider.notifier)
          .getAllDevices(
            name: query == '' ? null : query,
          );
    });
  }

  void _onSearchSubmitted(String query) {
    ref
        .read(devicesProvider.notifier)
        .getAllDevices(
          name: query,
        );
  }

  void _onDeviceSelected(Device device) {
    Navigator.of(context).pop(device);
  }

  @override
  Widget build(BuildContext context) {
    final devicesState = ref.watch(devicesProvider);

    return GestureDetector(
      onTap: _unfocusSearch,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Chọn cây cần tưới',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // tìm kiếm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CustomSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
              ),
            ),

            // Danh sách (không hiển thị những cây đang tưới và offline)
            Expanded(
              child: Builder(
                builder: (context) {
                  if (devicesState is devices_state.Loading ||
                      devicesState is devices_state.Initial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (devicesState is devices_state.Success) {
                    final devices = devicesState.devicesList
                        .where((device) => (!device.watering && device.online))
                        .toList();

                    if (devices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              devicesState.isSearchResultEmpty
                                  ? Symbols.search_off
                                  : Symbols.variable_remove,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              devicesState.isSearchResultEmpty
                                  ? 'Không tìm thấy thiết bị "${devicesState.searchQuery}"'
                                  : 'Chưa có thiết bị nào',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Scrollbar(
                      interactive: true,
                      thickness: 5,
                      radius: Radius.circular(10),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2 / 3,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                            ),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          // Sử dụng DeviceGridItem nhưng tắt các chức năng edit/delete
                          // bằng cách truyền hàm rỗng hoặc null (tùy vào implementation của DeviceGridItem)
                          return DeviceGridItem(
                            device: device,
                            onSelectDevice: () {
                              _onDeviceSelected(device);
                            },
                            onSelectDelete: () async {},
                            onSelectEdit: () {},
                            isPopup: true,
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
                              await ref
                                  .read(devicesProvider.notifier)
                                  .refresh();
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
