import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pinput/pinput.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _initialCountdownTime = 10;
  late int _countdownSeconds;
  Timer? _timer;
  String _enteredOtp = '';
  bool _isFirstSend = true;
  bool _canResend = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _countdownSeconds = _initialCountdownTime;
    if (!mounted) return;
  }

  void _startTimerAndSendOtp({required String email}) async {
    setState(() {
      _canResend = false;
    });
    await ref.read(sendOtpProvider.notifier).sendOtp(email: email);
    final sendOtpState = ref.read(sendOtpProvider);

    if (sendOtpState is auth_state.SendOtpFailure) {
      // Nếu API lỗi: Kích hoạt lại nút "Gửi lại mã"
      if (!mounted) return;
      setState(() {
        _canResend = true;
      });
      return; // Dừng, không chạy timer
    }

    if (_isFirstSend) {
      if (!mounted) return;
      setState(() {
        _isFirstSend = false;
      });
    }
    if (!mounted) return;
    setState(() {
      _countdownSeconds = _initialCountdownTime; // Đặt lại thời gian
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        if (!mounted) {
          _timer?.cancel();
          return;
        }
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _timer?.cancel();
        if (!mounted) return;
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _onConfirm({required String email}) {
    FocusScope.of(context).unfocus();
    ref
        .read(verifyEmailProvider.notifier)
        .verifyEmail(otp: _enteredOtp, email: email);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildSuccessView(String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Email của bạn đã được xác thực thành công.\nTài khoản của bạn giờ đã an toàn hơn.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 32),
        Card(
          color: AppColors.mainGreen[10]!.withAlpha(
            80,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColors.mainGreen[50]!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Symbols.check_circle,
                  color: AppColors.mainGreen[200],
                  weight: 700,
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email đã được xác thực',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mainGreen[200],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainGreen[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: AppStyles.elevatedButtonStyle(),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Quay về Tài khoản'),
        ),
      ],
    );
  }

  Widget _buildFirstView(auth_state.AuthState sendOtpState, String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Xác thực email để bảo mật tài khoản của bạn',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 32),
        Card(
          color: AppColors.divider.withAlpha(100),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email của bạn:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: AppStyles.elevatedButtonStyle(),
          onPressed: sendOtpState is auth_state.Loading
              ? null
              : () {
                  _startTimerAndSendOtp(email: userEmail);
                },
          child: sendOtpState is auth_state.Loading
              ? CustomCircularProgress()
              : Text('Gửi mã OTP'),
        ),
      ],
    );
  }

  Widget _buildOtpView(
    auth_state.AuthState verifyEmailState,
    String userEmail,
    PinTheme defaultPinTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mô tả & Email
        Text(
          'Nhập mã OTP đã được gửi đến',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),

        Text(
          userEmail,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Mã OTP',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Nhập Pinput
        Pinput(
          length: 6,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(
                color: Color.fromARGB(255, 95, 196, 75),
                width: 2.4,
              ),
            ),
          ),
          onChanged: (pin) {
            setState(() {
              _isCompleted = false;
            });
          },
          onCompleted: (pin) {
            _enteredOtp = pin;
            setState(() {
              _isCompleted = true;
            });
          },
        ),
        const SizedBox(height: 20),

        // Gửi lại mã & Timer
        Align(
          alignment: Alignment.centerRight,
          child: _canResend
              ? TextButton(
                  style: AppStyles.textButtonStyle.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.zero,
                    ),
                    minimumSize: WidgetStateProperty.all(
                      Size.zero,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    _startTimerAndSendOtp(
                      email: userEmail,
                    );
                  },
                  child: const Text('Gửi lại mã'),
                )
              : Text(
                  'Gửi lại mã sau $_countdownSeconds\s',
                  style: TextStyle(color: Colors.grey[700]),
                ),
        ),
        const SizedBox(height: 32),

        // Nút Xác nhận
        ElevatedButton(
          onPressed: _isCompleted
              ? verifyEmailState is auth_state.Loading
                    ? null
                    : () {
                        _onConfirm(email: userEmail);
                      }
              : null,
          style: AppStyles.elevatedButtonStyle().copyWith(),
          child: verifyEmailState is auth_state.Loading
              ? CustomCircularProgress()
              : Text(
                  'Xác nhận',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    final sendOtpState = ref.watch(sendOtpProvider);
    final verifyEmailState = ref.watch(verifyEmailProvider);

    final String userEmail = (userState is auth_state.Success)
        ? userState.user?.email ?? ''
        : '';
    final bool isVerified = (userState is auth_state.Success)
        ? userState.user?.verified ?? false
        : false;

    // Biến master control UI
    final bool showSuccessView =
        isVerified || (verifyEmailState is auth_state.Success);

    // final bool showSuccessView = true;

    ref.listen(sendOtpProvider, (prev, next) {
      if (next is auth_state.SendOtpFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: next.message));
      }
    });

    ref.listen(verifyEmailProvider, (prev, next) async {
      //cập nhật trạng thái verify sau khi thành công
      if (next is auth_state.Success) {
        await ref.read(authProvider.notifier).getUserInfo();
      }
      // Sửa: Dùng else if và đúng tên State
      else if (next is auth_state.VerifyEmailFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: next.message));
      }
    });

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final view = MediaQuery.of(context);
    final keyboardSpace = view.viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Xác thực email',
          automaticallyImplyLeading: false,
          leading: BackIcon(),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = (constraints.maxHeight - keyboardSpace)
                .clamp(
                  0.0,
                  double.infinity,
                );

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // header
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: showSuccessView
                              ? AppColors.mainGreen[50]
                              : AppColors.mainBlue[50],
                        ),
                        child: Icon(
                          showSuccessView
                              ? Symbols.check_rounded
                              : Symbols.mail_shield_rounded,
                          color: showSuccessView
                              ? AppColors.mainGreen[200]
                              : AppColors.mainBlue[300],
                          size: 36,
                          fill: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        showSuccessView
                            ? 'Xác thực thành công!'
                            : 'Xác thực địa chỉ email',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 32),

                      //body
                      Builder(
                        builder: (context) {
                          if (showSuccessView) {
                            return _buildSuccessView(userEmail);
                          }
                          if (_isFirstSend) {
                            return _buildFirstView(sendOtpState, userEmail);
                          }
                          return _buildOtpView(
                            verifyEmailState,
                            userEmail,
                            defaultPinTheme,
                          );
                        },
                      ),
                    ],
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
