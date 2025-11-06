import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        appBar: AppBar(
          title: Text('Thêm thiết bị'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight =
                (constraints.maxHeight - keyboardSpace).clamp(
                      0,
                      double.infinity,
                    )
                    as double;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: keyboardSpace),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Align(
                  alignment: FractionalOffset(0.5, 1 / 3),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NormalTextFormField(
                          textController: _nameController,
                          hintText: '',
                          label: 'Tên thiết bị',
                        ),
                        const SizedBox(height: 10),
                        NormalTextFormField(
                          textController: _deviceIdController,
                          hintText: '',
                          label: 'Mã thiết bị',
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
          },
        ),
      ),
    );
  }
}
