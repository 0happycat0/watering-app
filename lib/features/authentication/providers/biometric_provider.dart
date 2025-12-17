import 'package:flutter_riverpod/legacy.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:watering_app/core/utils/debug_print.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository_impl.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository_provider.dart';

class BiometricState {
  final bool isDeviceSupported; // Thiết bị có hỗ trợ không?
  final bool
  hasEnrolledBiometrics; // User đã bật trong cài đặt (trong máy) chưa?
  final bool isEnabled; // User đã bật trong cài đặt (app) chưa?

  BiometricState({
    this.isDeviceSupported = false,
    this.hasEnrolledBiometrics = false,
    this.isEnabled = false,
  });

  BiometricState copyWith({
    bool? isDeviceSupported,
    bool? hasEnrolledBiometrics,
    bool? isEnabled,
  }) {
    return BiometricState(
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      hasEnrolledBiometrics:
          hasEnrolledBiometrics ?? this.hasEnrolledBiometrics,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return BiometricNotifier(authRepository);
    });

class BiometricNotifier extends StateNotifier<BiometricState> {
  BiometricNotifier(this.authRepository) : super(BiometricState()) {
    _init();
  }
  final AuthRepositoryImpl authRepository;
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _init() async {
    // Kiểm tra thiết bị có phần cứng không
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    // final bool isSupported = await auth.isDeviceSupported();
    final bool deviceHasHardware = canCheckBiometrics;

    // Kiểm tra đã bật trong cài đặt hệ thống chưa
    final List<BiometricType> availableBiometrics = await auth
        .getAvailableBiometrics();
    final bool hasEnrolled = availableBiometrics.isNotEmpty;

    // Kiểm tra user đã bật trong cài đặt trước đó chưa
    final bool enabledInApp = await authRepository.isEnabledBiometric;

    state = state.copyWith(
      isDeviceSupported: deviceHasHardware,
      hasEnrolledBiometrics: hasEnrolled,
      isEnabled: enabledInApp,
    );
  }

  // Hàm bật/tắt tính năng (dùng cho màn hình Cài đặt)
  Future<void> setEnabled(bool value) async {
    await authRepository.setEnabledBiometric(value);
    state = state.copyWith(isEnabled: value);
  }

  // Cập nhật trạng thái cài đặt hệ thống hiện tại
  Future<bool> updateEnrolled() async {
    final List<BiometricType> availableBiometrics = await auth
        .getAvailableBiometrics();
    final bool hasEnrolled = availableBiometrics.isNotEmpty;
    printDebug('[DEBUG]: hasEnrolled = $hasEnrolled');
    state = state.copyWith(hasEnrolledBiometrics: hasEnrolled);
    return hasEnrolled;
  }

  // Hàm gọi xác thực (hiện popup vân tay/face id)
  Future<bool> authenticate() async {
    try {
      if (!state.isDeviceSupported) return false;

      return await auth.authenticate(
        localizedReason: 'Vui lòng quét mặt/ vân tay của bạn',
        biometricOnly: true,
        authMessages: <AuthMessages>[
          AndroidAuthMessages(signInHint: '', signInTitle: 'Xác thực vân tay'),
          IOSAuthMessages(cancelButton: 'No thanks'),
        ],
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      printDebug('Lỗi xác thực: $e');
      return false;
    }
  }
}
