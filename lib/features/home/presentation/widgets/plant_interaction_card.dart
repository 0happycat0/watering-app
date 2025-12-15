import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/constants/app_assets.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/providers/all_devices/realtime_devices_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_provider.dart';
import 'package:watering_app/features/home/presentation/widgets/all_devices_popup.dart';
import 'package:watering_app/features/home/presentation/widgets/slider_thumb_shape.dart';
import 'package:watering_app/features/home/presentation/widgets/slider_track_shape.dart';

class PlantInteractionCard extends ConsumerStatefulWidget {
  const PlantInteractionCard({
    super.key,
    required this.device,
    required this.onDeviceChanged,
    this.initialSliderValue = 10.0,
  });

  final Device device;
  final void Function(Device device) onDeviceChanged;
  final double initialSliderValue;

  @override
  ConsumerState<PlantInteractionCard> createState() =>
      _PlantInteractionCardState();
}

class _PlantInteractionCardState extends ConsumerState<PlantInteractionCard>
    with TickerProviderStateMixin {
  late final TextEditingController _durationController;
  late final AnimationController _wateringCanController;
  late final AnimationController _twinklingController;
  late final AnimationController _statusController;
  late double _currentSliderValue;

  bool _isWateringButtonPressed = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isAnimating = false;
  bool _showStatusOverlay = false;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialSliderValue;
    _durationController = TextEditingController(
      text: widget.initialSliderValue.toStringAsFixed(0),
    );
    _wateringCanController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000),
    );
    _twinklingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _statusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    _wateringCanController.dispose();
    _twinklingController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _openDeviceSelectionPopup() async {
    final Device? selectedDevice = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllDevicesPopup(),
        fullscreenDialog: true,
      ),
    );

    if (selectedDevice != null && mounted) {
      widget.onDeviceChanged(selectedDevice);
    }
  }

  Future<bool> _toggleDevice(String id, String action, int duration) async {
    bool result = false;

    // Trạng thái mong đợi sau khi toggle
    final expectedWateringState = action == 'START';

    // Gọi API
    final success = await ref
        .read(toggleDeviceProvider.notifier)
        .toggleDevice(
          device: Device(id: id, action: action, duration: duration),
        );

    if (!mounted) return result;

    if (success) {
      // API thành công, đợi 1000ms để nhận realtime
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return result;

      // Kiểm tra xem realtime có update không
      final updatedWateringMap = ref.read(devicesWateringProvider);
      final newWateringState = updatedWateringMap[widget.device.deviceId];

      // Nếu trạng thái không thay đổi theo expected hoặc giống trạng thái cũ
      if (newWateringState != expectedWateringState
      // false
      ) {
        // Không nhận được realtime confirmation
        result = false;
      } else {
        result = true;
      }
    } else {
      // API thất bại
      result = false;
    }

    if (mounted) {}
    return result;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(devicesWateringProvider);

    bool isDisabled = widget.device.name == 'Hãy chọn cây để tưới';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //tiêu đề
              Text(
                'Tưới cây',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              TextButton.icon(
                onPressed: _openDeviceSelectionPopup,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  foregroundColor: AppColors.mainGreen[500],
                ),
                icon: Icon(
                  Symbols.swap_horiz_rounded,
                  color: AppColors.secondaryGreen[300],
                ),
                label: Text(
                  'Chọn cây',
                  style: TextStyle(
                    color: AppColors.secondaryGreen[300],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          //main card
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                //background
                Image.asset(AppAssets.gardenBackgroundSmall),

                //plant
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.divider.withAlpha(150),
                        border: BoxBorder.all(
                          color: Colors.black.withAlpha(180),
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        widget.device.name,
                        style: GoogleFonts.rowdies(fontSize: 16),
                      ),
                    ),
                    Image.asset(AppAssets.gardenPlant, width: 220),
                    SizedBox(height: 120),
                  ],
                ),

                //watering can
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 75, right: 40),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: Lottie.asset(
                        AppAssets.wateringCanLottie,
                        controller: _wateringCanController,
                        width: 140,
                        repeat: true,
                      ),
                    ),
                  ),
                ),

                //twinkling stars
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 50,
                    ),
                    child: Lottie.asset(
                      AppAssets.twinklingLottie,
                      controller: _twinklingController,
                      width: 200,
                      repeat: true,
                    ),
                  ),
                ),
                //main action
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              //slider
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 12.0,
                                  trackShape: BorderSliderTrackShape(
                                    borderColor: Colors.black.withAlpha(180),
                                    borderWidth: 2,
                                  ),
                                  activeTrackColor: AppColors.mainBlue[300],
                                  thumbShape: CircleThumbWithBorderShape(
                                    thumbRadius: 10,
                                    borderColor: Colors.black.withAlpha(180),
                                    borderWidth: 2.5,
                                    innerColor: AppColors.mainBlue[100],
                                  ),
                                ),
                                child: Slider(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  value: _currentSliderValue,
                                  min: 1,
                                  max: 60,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentSliderValue = value;
                                      _durationController.text = value
                                          .toStringAsFixed(0);
                                    });
                                  },
                                ),
                              ),

                              //số phút
                              Container(
                                width: 96,
                                margin: const EdgeInsets.only(top: 6),
                                child: NormalTextFormField(
                                  textController: _durationController,
                                  textStyle: GoogleFonts.rowdies(
                                    fontSize: 16,
                                    color: AppColors.mainBlue[500],
                                  ),
                                  fillColor: AppColors.mainBlue[50]!.withAlpha(
                                    150,
                                  ),
                                  borderColor: Colors.black.withAlpha(180),
                                  hintText: '',
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  suffixText: 'phút',
                                  readOnly: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Image.asset(AppAssets.wateringCan, width: 100),
                      ],
                    ),
                    const SizedBox(height: 10),

                    //nút tưới
                    SizedBox(
                      height: 32,
                      child: GestureDetector(
                        onTapDown: (_) {
                          if (isDisabled || _isLoading || _isAnimating) return;
                          setState(() {
                            _isWateringButtonPressed = true;
                          });
                        },
                        onTapUp: (_) async {
                          await Future.delayed(
                            Duration(milliseconds: 150),
                            () {
                              if (mounted) {
                                setState(() {
                                  _isWateringButtonPressed = false;
                                });
                              }
                            },
                          );
                          if (isDisabled || _isLoading || _isAnimating) return;

                          setState(() {
                            _isLoading = true;
                          });
                          _isSuccess = await _toggleDevice(
                            widget.device.id,
                            'START',
                            (int.tryParse(
                                      _durationController.text,
                                    ) ??
                                    0) *
                                60,
                          );
                          setState(() {
                            _isLoading = false;
                            _showStatusOverlay = true;
                          });

                          _statusController.reset();
                          _statusController.forward();
                          await Future.delayed(
                            const Duration(milliseconds: 2500),
                          );

                          setState(() {
                            _showStatusOverlay = false;
                          });

                          if (_isSuccess) {
                            try {
                              setState(() {
                                _isAnimating = true;
                              });
                              _wateringCanController.reset();
                              _twinklingController.reset();

                              final wateringTask = _wateringCanController
                                  .forward();

                              // Hẹn giờ cho Twinkling chạy sau 1 giây
                              Future.delayed(
                                const Duration(seconds: 1),
                                () async {
                                  if (mounted) {
                                    // Thay vì forward, ta dùng repeat để nó lặp lại (loop)
                                    _twinklingController.repeat();

                                    await Future.delayed(
                                      const Duration(seconds: 3),
                                    );

                                    if (mounted) {
                                      _twinklingController.reset();
                                    }
                                  }
                                },
                              );

                              await wateringTask;
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isAnimating = false;
                                });
                                //reset cây
                                widget.onDeviceChanged(
                                  Device(name: 'Hãy chọn cây để tưới'),
                                );
                              }
                            }
                          }
                        },
                        onTapCancel: () {
                          setState(() {
                            _isWateringButtonPressed = false;
                          });
                        },
                        child: Image.asset(
                          isDisabled
                              ? AppAssets.wateringButtonDisabled
                              : _isWateringButtonPressed
                              ? AppAssets.wateringButtonPressed
                              : AppAssets.wateringButton,
                          width: 190,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

                //Loading
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),

                //Status overlay
                if (_showStatusOverlay)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              controller: _statusController,
                              _isSuccess
                                  ? AppAssets.successLottie
                                  : AppAssets.failureLottie,
                              width: 150,
                            ),
                            Text(
                              _isSuccess
                                  ? 'Tưới cây ${widget.device.name} thành công!'
                                  : 'Tưới thất bại. Vui lòng thử lại!',
                              style: GoogleFonts.rowdies(
                                fontSize: 20,
                                color: Colors.white,
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
