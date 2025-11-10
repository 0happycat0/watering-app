import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class NormalTextFormField extends StatelessWidget {
  const NormalTextFormField({
    super.key,
    required this.textController,
    required this.hintText,
    this.suffixText,
    this.suffixIcon,
    this.label,
    this.validator,
    this.isDense = false,
    this.padding,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
  });

  final String? Function(String?)? validator;
  final TextEditingController textController;
  final String hintText;
  final String? suffixText;
  final Icon? suffixIcon;
  final String? label;
  final bool isDense;
  final EdgeInsetsGeometry? padding;
  final bool readOnly;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function()? onTap;

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
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
          onTap: onTap,
        ),
      ],
    );
  }
}
