import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.subTitle,
    this.subTitleHeight = 0,
    this.leading,
    this.actions,
    this.bottom,
    this.radius = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.scrolledUnderElevation = 2,
    this.automaticallyImplyLeading = true,
    this.systemOverlayStyle,
  });

  final String title;
  final String? subTitle;
  final int subTitleHeight;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double scrolledUnderElevation;
  final bool automaticallyImplyLeading;
  final SystemUiOverlayStyle? systemOverlayStyle;
  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0) + subTitleHeight,
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      automaticallyImplyLeading: automaticallyImplyLeading,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
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
      systemOverlayStyle: systemOverlayStyle,
      title: Tooltip(
        message: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: foregroundColor ?? AppColors.mainGreen[200],
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),

            if (subTitle != null) ...[
              Text(
                subTitle!,
                style: TextStyle(
                  color: foregroundColor ?? AppColors.mainGreen[200],
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
