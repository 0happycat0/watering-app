import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/features/authentication/presentation/screens/change_password_screen.dart';
import 'package:watering_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:watering_app/features/authentication/presentation/screens/new_password_screen.dart';
import 'package:watering_app/features/authentication/presentation/screens/verify_email_screen.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  void _onChangePasswordTap() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        //TODO: change this
        builder: (ctx) => ChangePasswordScreen(),
      ),
    );
  }

  void _onVerifyEmailTap() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => VerifyEmailScreen(),
      ),
    );
  }

  void _onAppInforTap() {
    //TODO: implement this
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      //đọc từ local
      await ref.read(authProvider.notifier).getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tài khoản',
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Card(
              elevation: 0,
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: userState is auth_state.Loading
                    ? Center(child: CircularProgressIndicator())
                    : userState is auth_state.Success
                    ? Column(
                        children: [
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Gradient cho avatar
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mainBlue[300]!,
                                  AppColors.mainGreen[150]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              Symbols.person_rounded,
                              color: Colors.white,
                              fill: 1,
                              size: 52,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Name
                          Text(
                            userState.user?.username ?? '',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                ),
                          ),
                          SizedBox(height: 4),
                          // Email
                          Text(
                            userState.user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          // SizedBox(height: 16),
                          // Divider(height: 1, color: AppColors.divider),
                          // SizedBox(height: 4),
                          // Email Row
                          // ListTile(
                          //   leading: Icon(
                          //     Symbols.mail,
                          //     fill: 1,
                          //   ),
                          //   title: Text(
                          //     'Email',
                          //     style: TextStyle(
                          //       color: Colors.grey.shade700,
                          //       fontSize: 13,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     'nguyenvana@email.com',
                          //     style: TextStyle(color: Colors.black87, fontSize: 16),
                          //   ),
                          //   contentPadding: EdgeInsets.zero,
                          // ),
                          // // Phone Row
                          // ListTile(
                          //   leading: Icon(
                          //     Symbols.call,
                          //     fill: 1,
                          //   ),
                          //   title: Text(
                          //     'Số điện thoại',
                          //     style: TextStyle(
                          //       color: Colors.grey.shade700,
                          //       fontSize: 13,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     '0123456789',
                          //     style: TextStyle(fontSize: 16),
                          //   ),
                          //   contentPadding: EdgeInsets.zero,
                          // ),
                        ],
                      )
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 0,
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: Icon(
                      Symbols.lock_rounded,
                      // color: AppColors.mainGreen[200],
                      fill: 1,
                    ),
                    title: Text('Đổi mật khẩu'),
                    trailing: Icon(
                      Symbols.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: _onChangePasswordTap,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Divider(
                      height: 0.5,
                      color: AppColors.divider,
                    ),
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    leading: Icon(
                      Symbols.mail_shield_rounded,
                      // color: AppColors.mainGreen[200],
                      fill: 1,
                    ),
                    title: Text('Xác thực email'),
                    trailing: Icon(
                      Symbols.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: _onVerifyEmailTap,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Divider(
                      height: 0.5,
                      color: AppColors.divider,
                    ),
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    leading: Icon(
                      Symbols.info,
                      // color: AppColors.mainGreen[200],
                    ),
                    title: Text('Thông tin ứng dụng'),
                    trailing: Icon(
                      Symbols.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: _onAppInforTap,
                  ),
                ],
              ),
            ),
            Spacer(),
            OutlinedButton.icon(
              label: Text('Đăng xuất'),
              icon: Icon(Symbols.logout),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade200, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout(ref);
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => LoginScreen()),
                  );
                }
              },
            ),

            SizedBox(height: 8),
            Center(
              child: Text(
                'Phiên bản ${AppStrings.version}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
