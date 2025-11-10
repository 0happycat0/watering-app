import 'package:flutter/material.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double radius;
  final Color? backgroundColor;
  final double elevation;
  final double scrolledUnderElevation;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.radius = 0,
    this.backgroundColor,
    this.elevation = 0,
    this.scrolledUnderElevation = 2,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      surfaceTintColor: backgroundColor ?? AppColors.mainGreen[200],
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: colorScheme.shadow,
      leading: leading,
      actions: actions,
      bottom: bottom,
      // centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        ),
      ),
      title: Tooltip(
        message: title,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.mainGreen[200],
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
