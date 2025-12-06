import 'package:flutter/material.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Thông tin ứng dụng'),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}