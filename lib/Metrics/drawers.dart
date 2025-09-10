// Custom Painter for Heart Rate
import 'dart:math' as math;

import 'package:flutter/material.dart';

class HeartRatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.25, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.35, size.height * 0.9),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.6),
      Offset(size.width * 0.65, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.75, size.height * 0.6),
      Offset(size.width, size.height * 0.6),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Lungs
class LungsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Left lung
    final leftLung = Path()
      ..moveTo(size.width * 0.1, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.05, size.height * 0.5,
          size.width * 0.15, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.4,
          size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.43, size.height * 0.5,
          size.width * 0.38, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.15,
          size.width * 0.1, size.height * 0.25);

    // Right lung
    final rightLung = Path()
      ..moveTo(size.width * 0.62, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.15,
          size.width * 0.9, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.5,
          size.width * 0.85, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.9, size.width * 0.6,
          size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.57, size.height * 0.5,
          size.width * 0.62, size.height * 0.25);

    canvas.drawPath(leftLung, paint);
    canvas.drawPath(rightLung, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Weekly Trend
class WeeklyTrendPainter extends CustomPainter {
  final List<double> trendValues;
  final Color lineColor;

  WeeklyTrendPainter(this.trendValues, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (trendValues.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double minValue = trendValues.reduce((a, b) => a < b ? a : b);
    final double maxValue = trendValues.reduce((a, b) => a > b ? a : b);
    final double range =
        (maxValue - minValue).abs() < 1 ? 1 : (maxValue - minValue);

    final double horizontalStep = size.width / (trendValues.length - 1);

    Path path = Path();
    for (int i = 0; i < trendValues.length; i++) {
      double x = i * horizontalStep;
      double y = size.height -
          ((trendValues[i] - minValue) / range * size.height * 0.8 +
              size.height * 0.1);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots for each value
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < trendValues.length; i++) {
      double x = i * horizontalStep;
      double y = size.height -
          ((trendValues[i] - minValue) / range * size.height * 0.8 +
              size.height * 0.1);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Joint Mobility Visualization
class JointMobilityPainter extends CustomPainter {
  final int jointsScore;

  JointMobilityPainter(this.jointsScore);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw mobility arc
    final arcPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double sweepAngle = (jointsScore / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw score text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$jointsScore',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final offset = Offset(
        center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Breathing Visualization (Lungs)
class BreathingVisualizationPainter extends CustomPainter {
  final int lungsScore;

  BreathingVisualizationPainter(this.lungsScore);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double maxRadius = size.width * 0.4;
    final double minRadius = size.width * 0.2;
    final double radius = minRadius +
        ((lungsScore.clamp(0, 100) / 100) * (maxRadius - minRadius));

    final Paint circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw expanding/contracting circle
    canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);
    canvas.drawCircle(Offset(centerX, centerY), radius, outlinePaint);

    // Draw lungs icon in the center
    final lungsIconPainter = TextPainter(
      text: const TextSpan(
        text: '🫁',
        style: TextStyle(fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    );
    lungsIconPainter.layout();
    lungsIconPainter.paint(
      canvas,
      Offset(centerX - lungsIconPainter.width / 2,
          centerY - lungsIconPainter.height / 2),
    );

    // Draw score text below
    final scorePainter = TextPainter(
      text: TextSpan(
        text: '$lungsScore%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(
      canvas,
      Offset(centerX - scorePainter.width / 2, centerY + radius + 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
