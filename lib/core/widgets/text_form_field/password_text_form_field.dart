import 'package:flutter/material.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class PasswordTextFormField extends StatefulWidget {
  const PasswordTextFormField({
    super.key,
    required this.textController,
    required this.hintText,
    this.label,
    this.validator,
  });

  final TextEditingController textController;
  final String hintText;
  final String? label;
  final String? Function(String?)? validator;

  @override
  State<PasswordTextFormField> createState() {
    return _PasswordTextFormFieldState();
  }
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool _isObscure = true;
  IconData showPasswordIcon = Icons.visibility;

  void toggleVisible() {
    setState(() {
      _isObscure = !_isObscure;
      showPasswordIcon = _isObscure ? Icons.visibility : Icons.visibility_off;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(widget.label!),
          ),
        TextFormField(
          controller: widget.textController,
          validator: widget.validator,
          obscureText: _isObscure,
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            fillColor: AppColors.divider.withAlpha(150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            suffixIcon: IconButton(
              onPressed: toggleVisible,
              icon: Icon(showPasswordIcon),
            ),
          ),
        ),
      ],
    );
  }
}
