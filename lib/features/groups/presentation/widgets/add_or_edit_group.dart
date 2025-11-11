import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;
import 'package:watering_app/theme/styles.dart';

class AddOrEditGroup extends ConsumerStatefulWidget {
  const AddOrEditGroup({super.key, this.groupToEdit, this.isInTab = false});

  final Group? groupToEdit; //null: thêm, != null: sửa
  final bool isInTab;

  @override
  ConsumerState<AddOrEditGroup> createState() => _AddOrEditGroupState();
}

class _AddOrEditGroupState extends ConsumerState<AddOrEditGroup> {
  final _nameController = TextEditingController();
  // Sử dụng Set để lưu các ID của thiết bị được chọn
  final Set<String> _selectedIds = {};
  bool _isGroupDataLoaded = false; //ngăn UI load lại khi bỏ chọn
  late final bool _isEditMode;

  void _handleStateChange(
    group_state.GroupState? prev,
    group_state.GroupState next,
    String action,
  ) {
    print(
      '$action group transition: ${prev.runtimeType} -> ${next.runtimeType}',
    );

    // Hiển thị snack bar khi có lỗi
    if (next is group_state.Failure) {
      final message = next.message;
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(text: message),
      );
    }

    // Đóng dialog khi thành công
    if (next is group_state.Success && prev is group_state.Loading) {
      Navigator.of(context).pop(true);
    }
  }

  void _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          text: 'Vui lòng nhập tên nhóm',
        ),
      );
      return;
    }

    if (!mounted) return;

    if (_isEditMode) {
      await ref
          .read(updateGroupProvider.notifier)
          .updateGroup(
            id: widget.groupToEdit!.id,
            name: _nameController.text.trim(),
            listIdOfDevices: _selectedIds.toList(),
          );
    } else {
      await ref
          .read(createGroupProvider.notifier)
          .createGroup(
            name: _nameController.text.trim(),
            listIdOfDevices: _selectedIds.toList(),
          );
    }

    // Reset search
    if (!widget.isInTab && !_isEditMode) {
      ref.read(shouldResetGroupSearchProvider.notifier).state = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.groupToEdit != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditMode) {
        _nameController.text = widget.groupToEdit!.name;
        ref
            .read(groupByIdProvider.notifier)
            .getGroupById(id: widget.groupToEdit!.id);
        ref.read(freeDevicesProvider.notifier).getAllGroups();
      } else {
        ref.read(freeDevicesProvider.notifier).getAllGroups();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final freeDevicesState = ref.watch(freeDevicesProvider);
    final groupState = ref.watch(groupByIdProvider);

    final createGroupState = ref.watch(createGroupProvider);
    final updateGroupState = ref.watch(updateGroupProvider);

    final isLoading =
        createGroupState is group_state.Loading ||
        updateGroupState is group_state.Loading;

    ref.listen<group_state.GroupState>(createGroupProvider, (prev, next) {
      _handleStateChange(prev, next, 'create');
    });

    ref.listen<group_state.GroupState>(updateGroupProvider, (prev, next) {
      _handleStateChange(prev, next, 'update');
    });

    if (_isEditMode) {
      ref.listen<group_state.GroupState>(groupByIdProvider, (prev, next) {
        if (next is group_state.Success && !_isGroupDataLoaded) {
          final groupDevices = next.listDevices ?? [];
          setState(() {
            _selectedIds.clear();
            _selectedIds.addAll(groupDevices.map((d) => d.id));
            _isGroupDataLoaded = true;
          });
        }
      });
    }

    final view = MediaQuery.of(context);
    final keyboardSpace = view.viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Padding(
            padding: EdgeInsets.only(bottom: keyboardSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        _isEditMode
                            ? widget.isInTab
                                  ? 'Sửa thiết bị'
                                  : 'Sửa nhóm'
                            : 'Thêm nhóm thiết bị',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Symbols.close,
                          weight: 700,
                          color: Colors.grey,
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: _isEditMode
                      ? widget.isInTab
                            ? Text(
                                'Chọn hoặc bỏ chọn thiết bị trong nhóm',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            : null
                      : Text(
                          'Tạo tên nhóm và chọn thiết bị để thêm vào nhóm',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                ),

                if (!widget.isInTab) const SizedBox(height: 24),
                if (!widget.isInTab)
                  NormalTextFormField(
                    textController: _nameController,
                    hintText: 'Nhập tên nhóm...',
                    label: 'Tên nhóm',
                  ),
                const SizedBox(height: 16),
                Text(
                  'Chọn thiết bị',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: Scrollbar(
                    interactive: true,
                    thickness: 5,
                    radius: Radius.circular(10),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: _buildDeviceList(
                        context,
                        freeDevicesState,
                        groupState,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmit,
                        style: AppStyles.elevatedButtonStyle(),
                        child: isLoading
                            ? CustomCircularProgress()
                            : Text(
                                _isEditMode ? 'Lưu' : 'Tạo nhóm',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() => const Center(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: CustomCircularProgress(),
    ),
  );

  Widget _buildError(String? message) => Center(
    child: Text(message ?? 'Có lỗi xảy ra'),
  );

  Widget _buildDeviceList(
    BuildContext context,
    devices_state.DevicesState freeState,
    group_state.GroupState groupState, //
  ) {
    // Handle Loading
    if (freeState is devices_state.Loading ||
        freeState is devices_state.Initial) {
      return _buildLoading();
    }
    if (_isEditMode &&
        (groupState is group_state.Loading ||
            groupState is group_state.Initial)) {
      return _buildLoading();
    }

    // Handle Failure
    if (freeState is devices_state.Failure) {
      return _buildError(freeState.message);
    }
    if (_isEditMode && groupState is group_state.Failure) {
      return _buildError(groupState.message);
    }

    // Handle Success
    if (freeState is devices_state.Success) {
      List<Device> freeDevices = freeState.devicesList;
      List<Device> groupDevices = [];

      if (_isEditMode) {
        if (groupState is group_state.Success) {
          groupDevices = groupState.listDevices ?? [];
        } else {
          return _buildLoading();
        }
      }

      // Gộp 2 danh sách và loại bỏ trùng lặp (dùng Map)
      final allDevicesMap = <String, Device>{};
      for (var device in groupDevices) {
        allDevicesMap[device.id] = device;
      }
      for (var device in freeDevices) {
        // Chỉ thêm nếu chưa có (thiết bị trong nhóm luôn được ưu tiên)
        allDevicesMap.putIfAbsent(device.id, () => device);
      }
      final allDevices = allDevicesMap.values.toList();

      // Tạo một state Success tạm thời để truyền cho _buildSuccessUI
      final combinedState = devices_state.Success(
        allDevices,
        searchQuery: freeState.searchQuery,
      );

      return _buildSuccessUI(context, allDevices, combinedState);
    }

    // Fallback
    return _buildLoading();
  }

  Widget _buildSuccessUI(
    BuildContext context,
    List<Device> devices,
    devices_state.Success state,
  ) {
    if (state.isNoDevices) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Không có thiết bị nào khả dụng'),
        ),
      );
    }

    final int totalDevices = devices.length;
    final int selectedCount = _selectedIds.length;
    final bool allSelected = totalDevices > 0 && selectedCount == totalDevices;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Checkbox "Chọn tất cả"
        CheckboxListTile(
          title: const Text('Chọn tất cả'),
          secondary: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('$selectedCount/$totalDevices'),
          ),
          value: allSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                // Chọn tất cả: thêm ID của tất cả thiết bị vào Set
                _selectedIds.addAll(devices.map((device) => device.id));
              } else {
                // Bỏ chọn tất cả
                _selectedIds.clear();
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: Theme.of(context).primaryColor,
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            final bool isSelected = _selectedIds.contains(device.id);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: CheckboxListTile(
                  title: Text(
                    device.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(device.deviceId),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(device.id);
                      } else {
                        _selectedIds.remove(device.id);
                      }
                    });
                  },
                  secondary: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPowerIcon(device),
                      const SizedBox(width: 12),
                      _buildWifiIcon(device),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPowerIcon(Device device) {
    if (device.watering) {
      return Icon(Symbols.power_settings_new, color: Colors.blueAccent);
    }
    return Icon(Symbols.power_settings_new, color: Colors.transparent);
  }

  Widget _buildWifiIcon(Device device) {
    if (device.online) {
      return Icon(Symbols.wifi, color: Colors.green);
    }
    return Icon(Symbols.wifi_off, color: Colors.grey);
  }
}
