import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_assets.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_provider.dart';
import 'package:watering_app/theme/styles.dart';

class ControlTabScreen extends ConsumerStatefulWidget {
  const ControlTabScreen({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ControlTabScreenState();
}

class _ControlTabScreenState extends ConsumerState<ControlTabScreen> {
  final _durationController = TextEditingController(text: '10');

  bool _isWatering = false;
  void _onDurationTextChanged(String text) {
    setState(() {
      final value = double.tryParse(text);
      String newText = text;

      if (value != null) {
        if (value > 60) {
          newText = AppStrings.maxPumpDurationValue;
        } else if (value < 0) {
          newText = AppStrings.minPumpDurationValue;
        } else {
          //xóa số 0 đứng đầu
          newText = value.toStringAsFixed(0);
        }
      } else {
        newText = '0';
      }

      if (_durationController.text != newText) {
        _durationController.text = newText;
        //di chuyển con trỏ về cuối
        _durationController.selection = TextSelection.fromPosition(
          TextPosition(offset: _durationController.text.length),
        );
      }
    });
  }

  void _toggleDevice(String id, String action, int duration) async {
    setState(() {
      _isWatering = !_isWatering;
    });

    await ref.read(
      toggleDeviceProvider(
        Device(id: id, action: action, duration: duration),
      ).future,
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.device.id;

    double currentSliderValue = double.tryParse(_durationController.text) ?? 0;
    double sliderValue = currentSliderValue.clamp(0.0, 60.0);

    return SizedBox(
      height: double.infinity,
      child: Column(
        children: [
          //pump section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Image.asset(AppAssets.pump, width: 100),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            year2023: false,
                            padding: EdgeInsets.all(0),
                            value: sliderValue,
                            max: 60,
                            onChanged: (value) {
                              setState(() {
                                _durationController.text = value
                                    .toStringAsFixed(0);
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                child: NormalTextFormField(
                                  textController: _durationController,
                                  textAlign: TextAlign.center,
                                  hintText: '',
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 2,
                                  ),
                                  onChanged: _onDurationTextChanged,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'phút',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainGreen[200],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                  child: _isWatering
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('Đang bơm...', textAlign: TextAlign.left),
                        )
                      : null,
                ),
                Center(
                  child: SizedBox(
                    width: 150,
                    child: _isWatering
                        ? ElevatedButton(
                            onPressed: () {
                              _toggleDevice(id, 'STOP', 0);
                            },
                            style: AppStyles.elevatedButtonStyle(),
                            child: Text('Hủy'),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              _toggleDevice(
                                id,
                                'START',
                                int.tryParse(_durationController.text) ?? 0,
                              );
                            },
                            style: AppStyles.elevatedButtonStyle(),
                            child: Text('Bơm ngay'),
                          ),
                  ),
                ),
              ],
            ),
          ),

          //history section
          Expanded(
            child: Card(
              margin: EdgeInsets.all(16),
              child: Text('data'),
            ),
          ),
        ],
      ),
    );
  }
}
