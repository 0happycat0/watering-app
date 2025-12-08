import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/screens/webview_screen.dart';
import 'package:watering_app/core/utils/debug_print.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;
import 'package:watering_app/theme/styles.dart';

class AddNewDeviceStepper extends ConsumerStatefulWidget {
  const AddNewDeviceStepper({super.key});

  @override
  ConsumerState<AddNewDeviceStepper> createState() =>
      _AddNewDeviceStepperState();
}

class _AddNewDeviceStepperState extends ConsumerState<AddNewDeviceStepper> {
  final _nameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  int _currentStep = 0; // 0 -> 3 (tổng 4 bước)

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  // Bước tiếp theo
  void _nextStep() {
    if (_currentStep < 3) {
      if (_currentStep == 1) {
        //TODO: config wifi
      }
      if (_currentStep == 2) {
        //TODO: navigation to web view
      }
      setState(() => _currentStep++);
    } else {
      _submitDevice(); // Ở bước cuối gọi API
    }
  }

  // Quay lại
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // Hàm mở Cài đặt WiFi
  Future<void> _openNetworkSetting() async {
    await AppSettings.openAppSettingsPanel(
      AppSettingsPanelType.internetConnectivity,
    );
  }

  // Hàm mở trang Config WiFi
  Future<void> _launchConfigUrl() async {
    final String url = 'http://192.168.4.1';
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => WebviewScreen(
          url: url,
          title: 'Cấu hình WiFi',
        ),
      ),
    );
  }

  // Tạo thiết bị
  Future<void> _submitDevice() async {
    if (_nameController.text.isEmpty || _deviceIdController.text.isEmpty) {
      CustomSnackBar.showSnackBar(text: 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    if (!mounted) return;

    await ref
        .read(createDeviceProvider.notifier)
        .createDevice(
          name: _nameController.text,
          deviceId: _deviceIdController.text,
        );

    // Refresh danh sách và reset sort
    ref.read(devicesProvider.notifier).refresh();
    ref.read(shouldResetSortAndSearchProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final addDeviceState = ref.watch(createDeviceProvider);

    ref.listen<device_state.DeviceState>(createDeviceProvider, (prev, next) {
      printDebug(
        'create device transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
      if (next is device_state.Failure) {
        CustomSnackBar.showSnackBar(text: next.message);
      }
      if (next is device_state.Success && prev is device_state.Loading) {
        Navigator.of(context).pop();
        CustomSnackBar.showSnackBar(text: 'Thêm thiết bị thành công');
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
                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Thêm thiết bị',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Symbols.close,
                          weight: 600,
                          color: Colors.grey,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stepper
                _buildCustomStepper(),
                const SizedBox(height: 32),

                // Nội dung
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildStepContent(),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    // Nút Quay lại
                    if (_currentStep > 0)
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            'Quay lại',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),

                    // Nút Tiếp theo / Hoàn thành
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: addDeviceState is device_state.Loading
                            ? null
                            : _nextStep,
                        style: AppStyles.elevatedButtonStyle(
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: AppColors.mainGreen[200],
                          foregroundColor: Colors.white,
                        ),
                        child: addDeviceState is device_state.Loading
                            ? const CustomCircularProgress(color: Colors.white)
                            : Text(
                                _currentStep == 3 ? 'Hoàn tất' : 'Tiếp theo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
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

  // Widget nội dung từng bước
  Widget _buildStepContent() {
    final infoTextStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[800],
      height: 1.5,
    );
    switch (_currentStep) {
      case 0: // Bước 1: Cấp nguồn
        return _buildInstructionView(
          icon: Symbols.power,
          title: 'Cấp nguồn thiết bị',
          subtitle: 'Kết nối thiết bị với nguồn điện',
          infoBoxContent: Text(
            'Cắm dây nguồn của thiết bị vào ổ điện. Đèn LED trên thiết bị sẽ nhấp nháy màu xanh khi sẵn sàng.',
            style: infoTextStyle,
          ),
        );
      case 1: // Bước 2: Kết nối Wifi thiết bị
        return _buildInstructionView(
          icon: Symbols.wifi,
          title: 'Kết nối WiFi thiết bị',
          subtitle: 'Kết nối vào WiFi của thiết bị',
          infoBoxContent: Column(
            children: [
              Text.rich(
                TextSpan(
                  style: infoTextStyle,
                  children: [
                    TextSpan(
                      text:
                          'Mở cài đặt WiFi trên điện thoại và tìm mạng có tên ',
                    ),
                    TextSpan(
                      text: '"${AppStrings.wifiName}"',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '. Kết nối vào mạng này.',
                    ),
                    TextSpan(
                      text: '\n\nLưu ý:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    TextSpan(
                      text: ' Cần ngắt kết nối mạng di động 4G/5G',
                      // style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              //Nút mở cài đặt Wifi
              ElevatedButton.icon(
                onPressed: _openNetworkSetting,
                icon: const Icon(Symbols.network_manage),
                label: const Text('Cài đặt Mạng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainBlue[300],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 2: // Bước 3: Config Wifi
        return _buildInstructionView(
          icon: Symbols.settings_remote,
          title: 'Cấu hình WiFi',
          subtitle:
              'Truy cập trang cấu hình để kết nối thiết bị với mạng WiFi nhà bạn.',
          infoBoxContent: Column(
            children: [
              const Text(
                'Nhấn nút bên dưới để mở trang cấu hình (192.168.4.1)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),

              //Nút mở trang 192.168.4.1
              ElevatedButton.icon(
                onPressed: _launchConfigUrl,
                icon: const Icon(Symbols.open_in_browser),
                label: const Text('Mở trang cấu hình'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainBlue[300],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 3: // Bước 4: Nhập thông tin
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mainGreen[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.edit_document,
                size: 40,
                color: AppColors.mainGreen[400],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thông tin thiết bị',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập tên và mã ID dán trên thân thiết bị',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Nhập thông tin thiết bị
            NormalTextFormField(
              textController: _nameController,
              hintText: 'Ví dụ: Cây Lan Ban Công',
              label: 'Tên thiết bị',
            ),
            const SizedBox(height: 16),
            NormalTextFormField(
              textController: _deviceIdController,
              hintText: 'Ví dụ: ESP_123456',
              label: 'Mã thiết bị (Device ID)',
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // --- HELPER: GIAO DIỆN HƯỚNG DẪN CHUNG ---
  Widget _buildInstructionView({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? infoBoxContent,
  }) {
    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mainGreen[50],
          ),
          child: Icon(
            icon,
            size: 40,
            color: AppColors.mainGreen[400],
          ),
        ),
        const SizedBox(height: 24),

        // Tiêu đề
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Phụ đề
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        // Hộp thông tin
        if (infoBoxContent != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.mainBlue[10],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mainBlue[100]!,
              ), // Viền xanh nhạt
            ),
            child: infoBoxContent,
          ),
      ],
    );
  }

  // --- CUSTOM STEPPER WIDGET ---
  Widget _buildCustomStepper() {
    return Row(
      children: [
        _buildStepItem(0, 'Bước 1'),
        _buildStepLine(0),
        _buildStepItem(1, 'Bước 2'),
        _buildStepLine(1),
        _buildStepItem(2, 'Bước 3'),
        _buildStepLine(2),
        _buildStepItem(3, 'Bước 4'),
      ],
    );
  }

  Widget _buildStepItem(int stepIndex, String label) {
    final bool isActive = _currentStep >= stepIndex;
    final bool isCompleted = _currentStep > stepIndex;

    return Column(
      children: [
        // Vòng tròn Icon
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: isActive ? 40 : 36,
          height: isActive ? 40 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.mainGreen[200]
                : isActive
                ? AppColors.mainGreen[400]
                : Colors.grey[200],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Symbols.check,
                    color: Colors.white,
                    size: 20,
                    weight: 600,
                  )
                : isActive
                ? Icon(
                    _getIconForStep(stepIndex),
                    color: Colors.white,
                    size: 18,
                  )
                : Icon(
                    _getIconForStep(stepIndex),
                    color: Colors.grey[400],
                    size: 18,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        // Text nhãn
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getIconForStep(int step) {
    switch (step) {
      case 0:
        return Symbols.power;
      case 1:
        return Symbols.wifi;
      case 2:
        return Symbols.language;
      case 3:
        return Symbols.check_circle;
      default:
        return Symbols.circle;
    }
  }

  Widget _buildStepLine(int stepIndex) {
    final bool isCompleted = _currentStep > stepIndex;
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 2,
        margin: EdgeInsets.only(
          bottom: 20,
          left: 4,
          right: 4,
        ),
        color: isCompleted ? AppColors.mainGreen[200] : Colors.grey[200],
      ),
    );
  }
}
