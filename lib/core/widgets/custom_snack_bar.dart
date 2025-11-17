import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:watering_app/core/constants/app_colors.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String text,
    double? bottomPadding,
    super.duration = const Duration(milliseconds: 3000),
  }) : super(
         backgroundColor: Colors.transparent,
         padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding ?? 12),
         content: Container(
           margin: EdgeInsets.all(0),
           padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
           height: 65,
           alignment: Alignment.centerLeft,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(16),
             color: const Color.fromARGB(
               255,
               55,
               55,
               55,
             ).withValues(alpha: 0.94),
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withValues(alpha: 0.2), // Màu của bóng
                 spreadRadius: 2, // Độ lan rộng
                 blurRadius: 4, // Độ mờ
                 offset: Offset(0, 3), // Vị trí (x, y)
               ),
             ],
           ),
           child: Text(
             text,
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
             style: TextStyle(fontSize: 14),
             textAlign: TextAlign.justify,
           ),
         ),
       );
  static void showSnackBar({
    required String text,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    toastification.show(
      style: ToastificationStyle.flat,
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      backgroundColor: const Color.fromARGB(248, 50, 50, 50),
      foregroundColor: Colors.white,
      applyBlurEffect: false,
      dismissDirection: DismissDirection.up,
      showProgressBar: true,
      progressBarTheme: ProgressIndicatorThemeData(
        color: AppColors.mainYellow[200],
        borderRadius: BorderRadius.circular(100),
        linearTrackColor: AppColors.divider,
        linearMinHeight: 2,
      ),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
      showIcon: false,
      boxShadow: highModeShadow,
      title: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
