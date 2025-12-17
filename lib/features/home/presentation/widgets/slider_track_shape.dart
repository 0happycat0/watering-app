import 'package:flutter/material.dart';

class BorderSliderTrackShape extends RoundedRectSliderTrackShape {
  final Color borderColor;
  final double borderWidth;

  BorderSliderTrackShape({
    this.borderColor = Colors.grey, 
    this.borderWidth = 1.0
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    // 1. Gọi super để vẽ track màu nền như bình thường
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    // 2. Tính toán vị trí của track để vẽ viền đè lên
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackWidth = parentBox.size.width;
    
    // Căn giữa theo chiều dọc
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;

    // Tạo hình chữ nhật bao quanh track
    final Rect trackRect = Rect.fromLTWH(offset.dx, trackTop, trackWidth, trackHeight);

    // Vẽ viền bo góc (Radius bằng một nửa chiều cao track để tròn đầu)
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(trackHeight / 2)),
      borderPaint,
    );
  }
}