import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watering_app/core/constants/shared_preference_key.dart';
import 'package:watering_app/core/network/stomp_service.dart';
import 'package:watering_app/core/network/stomp_service_provider.dart';
import 'package:watering_app/core/utils/debug_print.dart';
import 'package:watering_app/core/utils/secure_storage_service.dart';
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
import 'package:watering_app/features/authentication/providers/biometric_provider.dart';
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

  String? _savedUsername;
  bool _isCheckingSavedUser = true;
  bool _isWelcomeBackMode = false;

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

  void _handleLogin() {
    ref
        .read(authProvider.notifier)
        .loginUser(
          ref,
          username: _isWelcomeBackMode
              ? (_savedUsername ?? '')
              : _usernameTextController.text.trim(),
          password: _passwordTextController.text,
        );
  }

  void _handleBioMetricLogin() async {
    final bioMetricState = ref.watch(biometricProvider);
    if (bioMetricState.isEnabled) {
      final success = await ref.read(biometricProvider.notifier).authenticate();
      if (success) {
        // Lấy token đã lưu (secure storage) để đăng nhập vào app
        final prefs = await SharedPreferences.getInstance();

        final username = prefs.getString(SharedPreferenceKey.username) ?? '';
        final password =
            await SecureStorageService.instance.read(key: SharedPreferenceKey.password) ?? '';
        ref
            .read(authProvider.notifier)
            .loginUser(
              ref,
              username: username,
              password: password,
            );
        printDebug("Đăng nhập vân tay thành công -> Chuyển màn hình");
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Thông báo'),
          content: Text(
            'Bạn chưa bật tính năng đăng nhập bằng Khuôn mặt/ Vân tay. Vui lòng đăng nhập để bật tính năng này!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  void _switchToNewAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Đăng nhập tài khoản khác'),
        content: Text(
          'Dữ liệu đăng nhập hiện tại (bao gồm cài đặt vân tay) sẽ bị xóa. Bạn có chắc chắn không?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              await ref.read(authProvider.notifier).deleteUser();
              ref.read(biometricProvider.notifier).setEnabled(false);

              setState(() {
                _isWelcomeBackMode = false;
                _savedUsername = null;
                _usernameTextController.clear();
                _passwordTextController.clear();
              });
            },
            child: Text('Đồng ý'),
          ),
        ],
      ),
    );
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
      } else {
        final prefs = await SharedPreferences.getInstance();
        final savedUsername = prefs.getString(SharedPreferenceKey.username);
        setState(() {
          if (savedUsername != null && savedUsername.isNotEmpty) {
            _savedUsername = savedUsername;
            _isWelcomeBackMode = true;
          }
          _isCheckingSavedUser = false;
        });
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

  List<Widget> _buildNormalLoginView() {
    return [
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
        hintText: 'Tên đăng nhập',
      ),
      SizedBox(height: 18),
    ];
  }

  List<Widget> _buildWelcomeBackView() {
    return [
      CircleAvatar(
        radius: 40,
        backgroundColor: AppColors.mainGreen[100],
        child: Icon(
          Symbols.person,
          size: 40,
          color: AppColors.mainGreen[600],
        ),
      ),
      SizedBox(height: 16),
      Text(
        'Xin chào,',
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        textAlign: TextAlign.center,
      ),
      Text(
        _savedUsername ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 24),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bioMetricState = ref.watch(biometricProvider);

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    ref.listen(authProvider, (prev, next) {
      printDebug('Auth transition: ${prev.runtimeType} -> ${next.runtimeType}');
      if (next is auth_state.LoginFailure) {
        CustomSnackBar.showSnackBar(
          text: 'Đăng nhập thất bại. ${next.message}',
        );
      }
      if (next is auth_state.Success && prev is! auth_state.Success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => MainScaffold()),
          (route) => false,
        );
      }
    });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
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
                    child: _isCheckingSavedUser
                        ? const SizedBox.shrink()
                        : Card(
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
                                  if (_isWelcomeBackMode)
                                    ..._buildWelcomeBackView()
                                  else
                                    ..._buildNormalLoginView(),
                                  PasswordTextFormField(
                                    textController: _passwordTextController,
                                    hintText: 'Mật khẩu',
                                  ),
                                  Row(
                                    children: [
                                      if (_isWelcomeBackMode)
                                        TextButton(
                                          onPressed: _switchToNewAccount,
                                          style: AppStyles.textButtonStyle,
                                          child: Text(
                                            'Sử dụng tài khoản khác',
                                            style: TextStyle(
                                              color: AppColors.mainGreen[600],
                                            ),
                                          ),
                                        ),
                                      if (_isWelcomeBackMode) Spacer(),
                                      if (!_isWelcomeBackMode) Spacer(),
                                      TextButton(
                                        onPressed:
                                            navigateToForgotPasswordScreen,
                                        style: AppStyles.textButtonStyle,
                                        child: Text('Quên mật khẩu?'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed:
                                              authState is auth_state.Loading
                                              ? null
                                              : _handleLogin,
                                          style:
                                              AppStyles.elevatedButtonStyle(),
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
                                      ),
                                      if (bioMetricState.isDeviceSupported)
                                        SizedBox(width: 4),
                                      if (bioMetricState.isDeviceSupported)
                                        IconButton(
                                          icon: Icon(
                                            Symbols.fingerprint,
                                            weight: 700,
                                            size: 32,
                                          ),
                                          onPressed: _handleBioMetricLogin,
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  if (!_isWelcomeBackMode)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Chưa có tài khoản?'),
                                        TextButton(
                                          onPressed: navigateToSignUpScreen,
                                          style: AppStyles.textButtonStyle
                                              .copyWith(
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
