import 'package:flutter/material.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/theme/styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> sendForgotPasswordEmail(String email) async {}

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quên mật khẩu',
        leading: BackIcon(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            NormalTextFormField(
              textController: _emailController,
              label: 'Email',
              hintText: 'Nhập email của bạn...',
              helperText: 'Email có dạng abc@example.com',
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                sendForgotPasswordEmail(_emailController.text.trim());
              },
              style: AppStyles.elevatedButtonStyle(),
              child: _isLoading
                  ? CustomCircularProgress()
                  : Text(
                      'Gửi OTP về email',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
