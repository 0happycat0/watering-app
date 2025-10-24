import 'package:flutter/material.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class NormalTextFormField extends StatelessWidget {
  const NormalTextFormField({
    super.key,
    required this.textController,
    required this.hintText,
    this.label,
    this.validator,
    this.isDense = false,
  });

  final String? Function(String?)? validator;
  final TextEditingController textController;
  final String hintText;
  final String? label;
  final bool isDense;

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
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: isDense
                ? EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                : null,
            fillColor: AppColors.divider.withAlpha(150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
