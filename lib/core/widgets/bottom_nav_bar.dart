import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentPageIndex,
    required this.selectPage,
  });

  final int currentPageIndex;
  final void Function(int) selectPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // boxShadow: [
        //   BoxShadow(
        //     color: Color.fromARGB(255, 203, 203, 203),
        //     blurRadius: 5,
        //     offset: Offset(0, 1),
        //   ),
        // ],
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.mainGreen[50],
        animationDuration: Duration(milliseconds: 400),
        onDestinationSelected: selectPage,
        selectedIndex: currentPageIndex,
        maintainBottomViewPadding: true,
        labelTextStyle: WidgetStateTextStyle.resolveWith(
          (Set<WidgetState> states) {
            // Kiểm tra xem trạng thái có chứa 'selected' không
            if (states.contains(WidgetState.selected)) {
              // Trả về TextStyle cho trạng thái ĐÃ CHỌN
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              );
            } else {
              // Trả về TextStyle cho trạng thái BÌNH THƯỜNG
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              );
            }
          },
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(Symbols.home_rounded, weight: 600),
            selectedIcon: Icon(
              Symbols.home_rounded,
              fill: 1,
              weight: 600,
              color: colorScheme.primary,
            ),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Symbols.sprinkler_rounded, weight: 600),
            selectedIcon: Icon(
              Symbols.sprinkler_rounded,
              fill: 1,
              weight: 600,
              color: colorScheme.primary,
            ),
            label: 'Tất cả t.bị',
          ),
          NavigationDestination(
            icon: Icon(Symbols.widgets_rounded, weight: 600),
            selectedIcon: Icon(
              Symbols.widgets_rounded,
              fill: 1,
              weight: 600,
              color: colorScheme.primary,
            ),
            label: 'Nhóm t.bị',
          ),
          NavigationDestination(
            icon: Icon(Symbols.person_rounded, weight: 600),
            selectedIcon: Icon(
              Symbols.person_rounded,
              fill: 1,
              weight: 600,
              color: colorScheme.primary,
            ),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
