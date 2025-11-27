import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pinput/pinput.dart';
import 'package:watering_app/features/authentication/presentation/screens/new_password_screen.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _initialCountdownTime = 10;
  late int _countdownSeconds;
  Timer? _timer;
  bool _canResend = false;

  bool _isOtpSent = false; // false: Nhập email, true: Nhập OTP
  String _enteredOtp = '';
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _countdownSeconds = _initialCountdownTime;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleSendOtp() async {
    if (!_isOtpSent) {
      if (!_formKey.currentState!.validate()) return;
    }

    final email = _emailController.text.trim();

    if (_isOtpSent) {
      setState(() {
        _canResend = false;
      });
    }

    await ref.read(sendOtpProvider.notifier).sendOtp(email: email);
    final sendOtpState = ref.read(sendOtpProvider);

    if (sendOtpState is auth_state.SendOtpFailure) {
      if (_isOtpSent && mounted) {
        setState(() {
          _canResend = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isOtpSent = true; // Chuyển sang màn nhập OTP
        _canResend = false;
        _countdownSeconds = _initialCountdownTime;
      });
      _startTimer();
    }
  }

  void _startTimer() {
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

  void _onConfirmOtp() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => NewPasswordScreen(
          email: _emailController.text,
          otp: _enteredOtp,
          isForgotPassword: true,
        ),
      ),
    );
  }

  Widget _buildEmailInputView(auth_state.AuthState sendOtpState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mainGreen[10],
            ),
            child: Icon(
              Symbols.lock_reset_rounded,
              color: AppColors.mainGreen[200],
              size: 36,
              fill: 1,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Quên mật khẩu',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Nhập email của bạn để nhận mã xác thực',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 32),

          NormalTextFormField(
            textController: _emailController,
            label: 'Email',
            hintText: 'example@email.com...',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              final emailRegex = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Email không đúng định dạng';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            style: AppStyles.elevatedButtonStyle(),
            onPressed: sendOtpState is auth_state.Loading
                ? null
                : _handleSendOtp,
            child: sendOtpState is auth_state.Loading
                ? CustomCircularProgress()
                : Text('Gửi mã OTP'),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputView(
    auth_state.AuthState sendOtpState,
    PinTheme defaultPinTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
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
        const SizedBox(height: 16),

        Text(
          'Xác thực OTP',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Mã OTP đã được gửi đến email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        Text(
          _emailController.text,
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

        // Pinput
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

        // Resend & Timer
        Align(
          alignment: Alignment.centerRight,
          child: _canResend
              ? TextButton(
                  style: AppStyles.textButtonStyle.copyWith(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    minimumSize: WidgetStateProperty.all(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _handleSendOtp, // Gọi lại hàm gửi
                  child: const Text('Gửi lại mã'),
                )
              : Text(
                  'Gửi lại mã sau $_countdownSeconds\s',
                  style: TextStyle(color: Colors.grey[700]),
                ),
        ),
        const SizedBox(height: 32),

        // Nút Xác nhận -> Sang màn hình NewPassword
        ElevatedButton(
          onPressed: _isCompleted ? _onConfirmOtp : null,
          style: AppStyles.elevatedButtonStyle(),
          child: Text('Xác nhận'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sendOtpState = ref.watch(sendOtpProvider);

    ref.listen(sendOtpProvider, (prev, next) {
      if (next is auth_state.SendOtpFailure) {
        CustomSnackBar.showSnackBar(text: next.message);
      } else if (next is auth_state.Success && !_isOtpSent) {}
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
          title: 'Quên mật khẩu',
          automaticallyImplyLeading: false,
          leading: BackIcon(),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = (constraints.maxHeight - keyboardSpace)
                .clamp(0.0, double.infinity);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Builder(
                    builder: (context) {
                      if (_isOtpSent) {
                        return _buildOtpInputView(
                          sendOtpState,
                          defaultPinTheme,
                        );
                      } else {
                        return _buildEmailInputView(sendOtpState);
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
