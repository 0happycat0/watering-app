import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pinput/pinput.dart';
import 'package:watering_app/features/authentication/presentation/screens/new_password_screen.dart';
import 'package:watering_app/features/authentication/presentation/screens/verify_email_screen.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
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

  void _onConfirm() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (ctx) => NewPasswordScreen(otp: _enteredOtp)),
    );
  }

  void _navigateToVerifyEmail() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (ctx) => const VerifyEmailScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildUnverifiedView(String userEmail) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon (Cam)
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.shade50,
          ),
          child: Icon(
            Symbols.gpp_maybe_rounded,
            color: Colors.orange.shade700,
            size: 36,
            fill: 1,
          ),
        ),
        const SizedBox(height: 12),

        // Tiêu đề
        Text(
          'Tài khoản chưa xác thực',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          'Vui lòng xác thực email để tiếp tục đổi mật khẩu',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 32),

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
          clipBehavior: Clip.antiAlias,
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
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50.withValues(alpha: 0.7),
                    border: Border.all(color: Colors.orange.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.warning_rounded,
                        color: Colors.orange.shade800,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chưa được xác thực',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton.icon(
          icon: Icon(Symbols.mail_outline_rounded),
          label: Text('Xác thực email ngay'),
          style: AppStyles.elevatedButtonStyle(),
          onPressed: _navigateToVerifyEmail,
        ),
        const SizedBox(height: 8),

        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          child: Text(
            'Quay lại',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpView(
    auth_state.AuthState sendOtpState,
    String userEmail,
    PinTheme defaultPinTheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon Khóa (Green)
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mainGreen[10],
          ),
          child: Icon(
            Symbols.lock_rounded,
            color: AppColors.mainGreen[200],
            size: 36,
            fill: 1,
          ),
        ),
        const SizedBox(height: 12),

        // Tiêu đề
        Text(
          'Xác thực OTP',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),

        // Logic cũ của bạn (Gửi OTP hoặc Nhập OTP)
        if (_isFirstSend)
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
          )
        else
          Column(
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
                          _startTimerAndSendOtp(email: userEmail);
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
                onPressed: _isCompleted ? _onConfirm : null,
                style: AppStyles.elevatedButtonStyle().copyWith(),
                child: Text(
                  'Xác nhận',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    final sendOtpState = ref.watch(sendOtpProvider);

    final String userEmail = (userState is auth_state.Success)
        ? userState.user?.email ?? ''
        : '';
    final bool isVerified = (userState is auth_state.Success)
        ? userState.user?.verified ?? false
        : false;

    ref.listen(sendOtpProvider, (prev, next) {
      if (next is auth_state.SendOtpFailure) {
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
          title: 'Đổi mật khẩu',
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
                  child: Builder(
                    builder: (context) {
                      if (!isVerified) {
                        return _buildUnverifiedView(userEmail);
                      } else {
                        return _buildOtpView(
                          sendOtpState,
                          userEmail,
                          defaultPinTheme,
                        );
                      }
                    },
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
