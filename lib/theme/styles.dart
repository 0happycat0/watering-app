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

  static ButtonStyle elevatedButtonStyle({
    double? elevation,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) => ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
    foregroundColor: foregroundColor ?? colorScheme.onPrimaryContainer,
    padding: padding,
    elevation: elevation,
  );
}
