import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String text,
    super.duration = const Duration(milliseconds: 3000),
  }) : super(
         backgroundColor: Colors.transparent,
         padding: EdgeInsets.all(12),
         content: Container(
           margin: EdgeInsets.all(0),
           padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
           height: 65,
           alignment: Alignment.centerLeft,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(14),
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
}
