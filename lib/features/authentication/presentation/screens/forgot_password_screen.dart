import 'package:flutter/material.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
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

  Future<void> sendForgotPasswordEmail(String email) async {
    try {
      setState(() {
        _isLoading = true;
      });
      //TODO: await
    } catch (e) {
      if (!mounted) return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            NormalTextFormField(
              textController: _emailController,
              label: 'Email',
              hintText: 'Nhập email của bạn',
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
                      'Send reset password email',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
