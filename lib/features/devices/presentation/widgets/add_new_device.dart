import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/providers/device/device_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/theme/styles.dart';

class AddNewDevice extends ConsumerStatefulWidget {
  const AddNewDevice({super.key});

  @override
  ConsumerState<AddNewDevice> createState() => _AddNewDeviceState();
}

class _AddNewDeviceState extends ConsumerState<AddNewDevice> {
  final _nameController = TextEditingController();
  final _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addDeviceState = ref.watch(createDeviceProvider);
    ref.listen<device_state.DeviceState>(createDeviceProvider, (prev, next) {
      print(
        'create device transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
      //hien thi snack bar khi co loi
      if (next is device_state.Failure) {
        final message = next.message;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: message));
      }
      if (next is device_state.Success && prev is device_state.Loading) {
        Navigator.of(context).pop();
      }
    });

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
                        'Thêm thiết bị',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Symbols.close_rounded,
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
                    'Nhập thông tin chi tiết của thiết bị',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NormalTextFormField(
                          textController: _nameController,
                          hintText: 'Nhập tên thiết bị...',
                          label: 'Tên thiết bị',
                        ),
                        const SizedBox(height: 10),
                        NormalTextFormField(
                          textController: _deviceIdController,
                          hintText: 'Nhập mã thiết bị...',
                          label: 'Mã thiết bị',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: addDeviceState is device_state.Loading
                      ? null
                      : () async {
                          if (!mounted) return;
                          await ref
                              .read(createDeviceProvider.notifier)
                              .createDevice(
                                name: _nameController.text,
                                deviceId: _deviceIdController.text,
                              );
                          ref.read(devicesProvider.notifier).refresh();
                          ref
                                  .read(
                                    shouldResetSortAndSearchProvider.notifier,
                                  )
                                  .state =
                              true;
                        },
                  style: AppStyles.elevatedButtonStyle(),
                  child: addDeviceState is device_state.Loading
                      ? CustomCircularProgress()
                      : Text(
                          'Thêm',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
