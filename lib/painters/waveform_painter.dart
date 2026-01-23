import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final Color color;

  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final height = size.height;
    final width = size.width;
    final centerY = height / 2;
    final barWidth = width / 12;

    for (int i = 0; i < 12; i++) {
      final randomHeight = (5 + (i * 7) % 15).toDouble();
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, centerY - randomHeight / 2),
        Offset(x, centerY + randomHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => false;
}