import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String text,
    super.duration = const Duration(milliseconds: 3000),
  }) : super(
         backgroundColor: Colors.transparent,
         content: Container(
           margin: EdgeInsets.all(0),
           padding: EdgeInsets.all(16),
           height: 55,
           alignment: Alignment.centerLeft,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(14),
             color: Colors.black.withValues(alpha: 0.7),
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
             style: TextStyle(fontSize: 14),
             textAlign: TextAlign.justify,
           ),
         ),
       );
}
