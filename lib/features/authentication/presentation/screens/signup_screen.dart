import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;
import 'package:watering_app/core/widgets/text_form_field/password_text_form_field.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/theme/theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailTextController = TextEditingController();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _rePasswordTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .createUser(
            email: _emailTextController.text.trim(),
            username: _usernameTextController.text.trim(),
            password: _passwordTextController.text,
          );
    }
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    _rePasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(authProvider);
    final isLoading = signupState is auth_state.Loading;

    ref.listen(authProvider, (prev, next) {
      print('Auth transition: ${prev.runtimeType} -> ${next.runtimeType}');
      if (next is auth_state.SignupFailure) {
        CustomSnackBar.showSnackBar(text: 'Đăng ký thất bại. ${next.message}');
      } else if (next is auth_state.SignupSuccess) {
        CustomSnackBar.showSnackBar(text: 'Đăng ký thành công!');
        Navigator.of(context).pop();
      }
    });

    final appBar = CustomAppBar(
      title: 'Đăng ký tài khoản',
      leading: BackIcon(),
      backgroundColor: colorScheme.surface,
    );
    final screenHeight =
        MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar,
        body: Container(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          padding: EdgeInsets.all(0),
          width: double.infinity,
          child: AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            duration: Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 18,
                  children: [
                    NormalTextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email không được để trống';
                        }
                        final emailRegex = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Email không đúng định dạng';
                        }
                        return null;
                      },
                      textController: _emailTextController,
                      label: 'Email',
                      hintText: 'abc@example.com',
                      helperText: 'Ví dụ: abc@example.com',
                    ),
                    NormalTextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên đăng nhập không được để trống';
                        }
                        if (value.length < 3) {
                          return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                        }
                        return null;
                      },
                      textController: _usernameTextController,
                      label: 'Tên đăng nhập',
                      hintText: '',
                      helperText: 'Tên đăng nhập phải có ít nhất 3 ký tự',
                    ),
                    PasswordTextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mật khẩu không được để trống';
                        }
                        if (value.length < 8) {
                          return 'Mật khẩu phải có ít nhất 8 ký tự';
                        }
                        return null;
                      },
                      textController: _passwordTextController,
                      label: 'Mật khẩu',
                      hintText: '',
                      helperText: 'Mật khẩu phải có ít nhất 8 ký tự',
                    ),
                    PasswordTextFormField(
                      validator: (value) {
                        if (value != _passwordTextController.text) {
                          return 'Mật khẩu nhập lại không khớp';
                        }
                        return null;
                      },
                      textController: _rePasswordTextController,
                      label: 'Nhập lại mật khẩu',
                      hintText: '',
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _signup,
                      style: AppStyles.elevatedButtonStyle(),
                      child: isLoading
                          ? CustomCircularProgress()
                          : Text(
                              'Đăng Ký',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
