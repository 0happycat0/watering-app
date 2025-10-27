import 'package:flutter/material.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class NormalTextFormField extends StatelessWidget {
  const NormalTextFormField({
    super.key,
    required this.textController,
    required this.hintText,
    this.suffixText,
    this.label,
    this.validator,
    this.isDense = false,
    this.padding,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.onChanged,
  });

  final String? Function(String?)? validator;
  final TextEditingController textController;
  final String hintText;
  final String? suffixText;
  final String? label;
  final bool isDense;
  final EdgeInsetsGeometry? padding;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(
              label!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black.withAlpha(200),
              ),
            ),
          ),
        TextFormField(
          controller: textController,
          validator: validator,
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
          textAlign: textAlign,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: isDense
                ? EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                : padding,
            fillColor: AppColors.divider.withAlpha(150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            suffixText: suffixText,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
