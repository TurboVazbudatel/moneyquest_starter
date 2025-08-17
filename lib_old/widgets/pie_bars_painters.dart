import 'dart:math' as math;
import 'package:flutter/material.dart';

class PieChartPainter extends CustomPainter {
  final Map<String, double> byCat;
  final List<dynamic> cats; // for names/icons at runtime (kept dynamic to avoid coupling)
  PieChartPainter(this.byCat, this.cats);

  @override
  void paint(Canvas canvas, Size size) {
    final total = byCat.values.fold(0.0, (s, v) => s + v);
    if (total <= 0) {
      final paint = Paint()..color = Colors.grey.withOpacity(.2);
      canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2.4, paint);
      return;
    }
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: size.shortestSide * 0.9, height: size.shortestSide * 0.9);
    double start = -math.pi / 2;
    final rnd = math.Random(42);
    for (final e in byCat.entries) {
      final sweep = (e.value / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = HSVColor.fromAHSV(1.0, (rnd.nextDouble() * 360.0), 0.55, 0.85).toColor();
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) => old.byCat != byCat;
}

class BarsChartPainter extends CustomPainter {
  final List<double> history;
  BarsChartPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;
    final maxV = history.reduce(math.max);
    final barW = size.width / (history.length * 1.6);
    final gap = barW * 0.6;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueGrey;

    for (int i = 0; i < history.length; i++) {
      final v = history[i];
      final h = maxV <= 0 ? 0.0 : (v / maxV) * size.height;
      final left = i.toDouble() * (barW + gap);
      final rect = Rect.fromLTWH(left, size.height - h, barW, h);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BarsChartPainter old) => old.history != history;
}
