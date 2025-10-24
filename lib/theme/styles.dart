import 'package:flutter/material.dart';
import 'package:watering_app/theme/theme.dart';

class AppStyles {
  static ButtonStyle textButtonStyle = ButtonStyle(
    overlayColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      return Colors.transparent;
    }),
    foregroundColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.primaryContainer;
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.onSurface;
      }
      return null;
    }),
  );

  static ButtonStyle elevatedButtonStyle({double? elevation}) =>
      ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: elevation,
      );

}
