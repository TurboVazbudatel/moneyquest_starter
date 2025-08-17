import 'dart:math' as math;
import 'package:flutter/material.dart';

class SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  SparklinePainter(this.points, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final minV = points.reduce(math.min);
    final maxV = points.reduce(math.max);
    final span = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);
    final dx = points.length > 1 ? size.width / (points.length - 1) : size.width;
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = points.length > 1 ? i.toDouble() * dx : size.width / 2;
      final y = size.height - ((points[i] - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter old) => old.points != points || old.color != color;
}
