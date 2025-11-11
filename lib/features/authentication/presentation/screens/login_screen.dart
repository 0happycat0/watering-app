import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/network/stomp_service.dart';
import 'package:watering_app/core/network/stomp_service_provider.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/core/widgets/text_form_field/password_text_form_field.dart';

import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;
import 'package:watering_app/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:watering_app/features/authentication/presentation/screens/signup_screen.dart';
import 'package:watering_app/core/constants/app_assets.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/main_scaffold.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/theme/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  void navigateToSignUpScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => SignUpScreen()));
  }

  void navigateToForgotPasswordScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => ForgotPasswordScreen()));
  }

  @override
  void initState() {
    super.initState();
    //kiểm tra xem đã đăng nhập chưa, nếu rồi thì điều hướng đến màn hình chính
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isLoggedIn = await ref.read(authProvider.notifier).isLoggedIn();
      if (isLoggedIn && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const MainScaffold()),
          (route) => false,
        );
        //Khởi tạo stomp service khi đã đăng nhập 
        //(nếu chỉ khởi tạo lúc gọi hàm login thì khi khởi động app lại sẽ không có stomp service)
        ref.read(stompServiceProvider.notifier).state = StompService();
      }
      //bỏ màn hình splash sau khi xử lý xong
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final authState = ref.watch(authProvider);
    ref.listen(authProvider, (prev, next) {
      print('Auth transition: ${prev.runtimeType} -> ${next.runtimeType}');
      if (next is auth_state.LoginFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(text: 'Đăng nhập thất bại. ${next.message}'),
        );
      }
      if (next is auth_state.Success && prev is! auth_state.Success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => MainScaffold()),
          (route) => false,
        );
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          constraints: BoxConstraints(minHeight: screenHeight),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.mainGreen[50]!, AppColors.mainGreen[200]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Image.asset(
                AppAssets.splash,
                height: 300,
                scale: 0.7,
              ),
              AnimatedPadding(
                padding: EdgeInsets.only(
                  bottom: bottomPadding,
                ),
                duration: Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Center(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                      color: colorScheme.surface,
                      margin: EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            NormalTextFormField(
                              textController: _usernameTextController,
                              hintText: 'Email',
                            ),
                            SizedBox(height: 18),
                            PasswordTextFormField(
                              textController: _passwordTextController,
                              hintText: 'Mật khẩu',
                            ),
                            Row(
                              children: [
                                Spacer(),
                                TextButton(
                                  onPressed: navigateToForgotPasswordScreen,
                                  style: AppStyles.textButtonStyle,
                                  child: Text('Quên mật khẩu?'),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(authProvider.notifier)
                                    .loginUser(
                                      ref,
                                      username: _usernameTextController.text
                                          .trim(),
                                      password: _passwordTextController.text,
                                    );
                              },
                              style: AppStyles.elevatedButtonStyle(),
                              child: authState is auth_state.Loading
                                  ? CustomCircularProgress()
                                  : Text(
                                      'Đăng Nhập',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Chưa có tài khoản?'),
                                TextButton(
                                  onPressed: navigateToSignUpScreen,
                                  style: AppStyles.textButtonStyle.copyWith(
                                    padding: WidgetStatePropertyAll(
                                      EdgeInsets.only(left: 4),
                                    ),
                                  ),
                                  child: Text(
                                    'Đăng ký ngay',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // //test
                            // ElevatedButton(
                            //   onPressed: () {
                            //     setState(() {
                            //       test = test == '1' ? '2' : '1';
                            //     });
                            //   },
                            //   child: Text(testState),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
