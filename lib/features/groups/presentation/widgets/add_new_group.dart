import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_provider.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;
import 'package:watering_app/theme/styles.dart';

class AddNewGroup extends ConsumerStatefulWidget {
  const AddNewGroup({super.key});

  @override
  ConsumerState<AddNewGroup> createState() => _AddNewGroupState();
}

class _AddNewGroupState extends ConsumerState<AddNewGroup> {
  final _nameController = TextEditingController();
  // Sử dụng Set để lưu các ID của thiết bị được chọn
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(freeDevicesProvider.notifier).getAllGroups();
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
                        'Thêm nhóm thiết bị',
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
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    'Tạo tên nhóm và chọn thiết bị để thêm vào nhóm',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),

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
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: _buildDeviceList(context, freeDevicesState),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('Group Name: ${_nameController.text}');
                          print('Selected IDs: $_selectedIds');
                          Navigator.of(context).pop();
                        },
                        style: AppStyles.elevatedButtonStyle(),
                        child: const Text('Tạo nhóm'),
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

  Widget _buildDeviceList(
    BuildContext context,
    devices_state.DevicesState state,
  ) {
    return switch (state) {
      devices_state.Loading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CustomCircularProgress(),
        ),
      ),
      devices_state.Failure(exception: final e) => Center(
        child: Text(e.message!),
      ),
      devices_state.Success(
        devicesList: final devices,
        searchQuery: final sq,
      ) =>
        _buildSuccessUI(
          context,
          devices,
          devices_state.Success(devices, searchQuery: sq),
        ),
      _ => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CustomCircularProgress(),
        ),
      ),
    };
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
