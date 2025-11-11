import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/bottom_nav_bar.dart';
import 'package:watering_app/core/widgets/custom_fab.dart';
import 'package:watering_app/features/authentication/presentation/screens/account_screen.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:watering_app/features/devices/presentation/screens/all_devices_screen.dart';
import 'package:watering_app/features/devices/presentation/widgets/add_new_device.dart';
import 'package:watering_app/features/groups/presentation/screens/all_groups_screen.dart';
import 'package:watering_app/features/groups/presentation/widgets/add_or_edit_group.dart';
import 'package:watering_app/theme/styles.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _showAddDeviceDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: AppColors.mainGreen[300]?.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) {
        return AddNewDevice();
      },
    );
  }

  void _showAddGroupDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: AppColors.mainGreen[300]?.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) {
        return AddOrEditGroup();
      },
    );
  }

  void _showRequestLogInAgainDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('Phiên đăng nhập đã hết hạn'),
          content: Text('Vui lòng đăng nhập lại'),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: AppStyles.elevatedButtonStyle(elevation: 0),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: Text('Đăng nhập lại'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(requestLogoutProvider, (prev, next) {
      print('Request logout transition: $prev -> $next');
      if (next == true) {
        ref.read(authProvider.notifier).logout(ref);
        //reset
        ref.read(requestLogoutProvider.notifier).state = false;
        _showRequestLogInAgainDialog();
      }
    });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavBar(
        currentPageIndex: _currentPageIndex,
        selectPage: _selectPage,
      ),
      //TODO: tìm hiểu để sửa chiều cao
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      floatingActionButton: (_currentPageIndex == 1 || _currentPageIndex == 2)
          ? CustomFab(
              onAddDevicePressed: _showAddDeviceDialog,
              onAddGroupPressed: _showAddGroupDialog,
            )
          : null,
      body: <Widget>[
        Column(
          children: [
            //TODO: remove this
           
          ],
        ),
        AllDevicesScreen(),
        AllGroupsScreen(),
        AccountScreen(),
      ][_currentPageIndex],
    );
  }
}
