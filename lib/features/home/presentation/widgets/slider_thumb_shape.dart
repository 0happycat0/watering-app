import 'package:flutter/material.dart';

class CircleThumbWithBorderShape extends SliderComponentShape {
  final double thumbRadius;
  final double borderWidth;
  final Color? borderColor;
  final Color? innerColor; // Màu bên trong (nếu null sẽ lấy màu của Slider)

  const CircleThumbWithBorderShape({
    this.thumbRadius = 12.0,
    this.borderWidth = 2.0,
    this.borderColor,
    this.innerColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // 1. Xác định màu
    final Color fill = innerColor ?? sliderTheme.thumbColor ?? Colors.blue;
    final Color border = borderColor ?? Colors.white;

    // 2. Vẽ hình tròn nền (Fill)
    final Paint fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);

    // 3. Vẽ viền (Border)
    if (borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = border
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, thumbRadius, borderPaint);
    }
  }
}