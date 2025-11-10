import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;
import 'package:watering_app/core/widgets/text_form_field/password_text_form_field.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/theme/styles.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _rePasswordTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    _rePasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: Text('Đăng ký tài khoản'));
    final screenHeight =
        MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final authState = ref.watch(authProvider);
    ref.listen(authProvider, (prev, next) {
      print('Auth transition: ${prev.runtimeType} -> ${next.runtimeType}');
      if (next is auth_state.SignupFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(text: 'Đăng ký thất bại. ${next.message}'),
        );
      } else if (next is auth_state.SignupSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: 'Đăng ký thành công!'));
        Navigator.of(context).pop();
      }
    });
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar,
        body: Container(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          padding: EdgeInsets.all(32),
          width: double.infinity,
          child: AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            duration: Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: SingleChildScrollView(
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
                          return 'Đây là trường bắt buộc';
                        }
                        if (value.length < 3) {
                          return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                        }
                        return null;
                      },
                      textController: _usernameTextController,
                      hintText: 'Email',
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
                      hintText: 'Mật khẩu',
                    ),
                    PasswordTextFormField(
                      validator: (value) {
                        if (value != _passwordTextController.text) {
                          return 'Mật khẩu nhập lại không khớp';
                        }
                        return null;
                      },
                      textController: _rePasswordTextController,
                      hintText: 'Nhập lại mật khẩu',
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(authProvider.notifier)
                              .createUser(
                                username: _usernameTextController.text.trim(),
                                password: _passwordTextController.text,
                              );
                        }
                      },
                      style: AppStyles.elevatedButtonStyle(),
                      child: authState is auth_state.Loading
                          ? CustomCircularProgress()
                          : Text(
                              'Đăng Ký',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(height: 200),
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
