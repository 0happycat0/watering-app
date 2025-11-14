import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/core/widgets/text_form_field/password_text_form_field.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key, required this.otp});

  final String otp;

  @override
  ConsumerState<NewPasswordScreen> createState() {
    return _NewPasswordScreenState();
  }
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _passwordTextController = TextEditingController();
  final _rePasswordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordTextController.dispose();
    _rePasswordTextController.dispose();
    super.dispose();
  }

  void _submitNewPassword() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      await ref
          .read(changePasswordProvider.notifier)
          .changePassword(
            code: widget.otp,
            newPassword: _passwordTextController.text,
            confirmNewPassword: _rePasswordTextController.text,
          );
    }
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mainGreen[10],
          ),
          child: Icon(
            Symbols.check_rounded,
            color: AppColors.mainGreen[200],
            size: 36,
            fill: 1,
          ),
        ),
        const SizedBox(height: 16),

        // Tiêu đề
        Text(
          'Đổi mật khẩu thành công!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 160),

        ElevatedButton(
          style: AppStyles.elevatedButtonStyle(),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Text('Quay về tài khoản'),
        ),
        const SizedBox(height: 16),

        Text(
          'Bạn có thể đăng nhập lại với mật khẩu mới',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon Khóa
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mainGreen[10],
            ),
            child: Icon(
              Symbols.key_vertical_rounded,
              color: AppColors.mainGreen[200],
              size: 36,
              fill: 1,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Mật khẩu mới',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Tạo mật khẩu mới cho tài khoản của bạn',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 32),

          PasswordTextFormField(
            label: 'Mật khẩu mới',
            hintText: '',
            textController: _passwordTextController,
            helperText: 'Mật khẩu phải có ít nhất 8 ký tự',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mật khẩu không được để trống';
              }
              if (value.length < 8) {
                return 'Mật khẩu phải có ít nhất 8 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          PasswordTextFormField(
            label: 'Nhập lại mật khẩu mới',
            hintText: '',
            textController: _rePasswordTextController,
            validator: (value) {
              if (value != _passwordTextController.text) {
                return 'Mật khẩu nhập lại không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitNewPassword,
            style: AppStyles.elevatedButtonStyle(),
            child: _isLoading
                ? CustomCircularProgress()
                : const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final changePasswordState = ref.watch(changePasswordProvider);
    _isLoading = changePasswordState is auth_state.Loading;

    ref.listen(changePasswordProvider, (prev, next) {
      if (next is auth_state.ChangePasswordFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: next.message));
      }
    });

    final appBar = CustomAppBar(
      title: 'Mật khẩu mới',
      automaticallyImplyLeading: false,
      leading: BackIcon(),
    );
    final screenHeight =
        MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar,
        body: Container(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Builder(
                builder: (context) {
                  if (changePasswordState is auth_state.Success) {
                    // if (true) {
                    return _buildSuccessView();
                  } else {
                    return _buildFormView();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
