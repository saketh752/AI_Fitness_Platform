import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../domain/exercise_form_evaluator.dart';

class PoseLandmarks {
  final Offset head;
  final Offset shoulder;
  final Offset elbow;
  final Offset wrist;
  final Offset hip;
  final Offset knee;
  final Offset ankle;

  const PoseLandmarks({
    required this.head,
    required this.shoulder,
    required this.elbow,
    required this.wrist,
    required this.hip,
    required this.knee,
    required this.ankle,
  });
}

class PoseOverlayPainter extends CustomPainter {
  final PoseLandmarks landmarks;
  final double currentAngle;
  final FormFeedbackType feedbackType;

  PoseOverlayPainter({
    required this.landmarks,
    required this.currentAngle,
    required this.feedbackType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color themeColor;
    switch (feedbackType) {
      case FormFeedbackType.good:
        themeColor = const Color(0xFF10B981);
        break;
      case FormFeedbackType.warning:
        themeColor = const Color(0xFFF59E0B);
        break;
      case FormFeedbackType.info:
        themeColor = AppColors.primary;
        break;
    }

    final bonePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.85)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final jointBorderPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw skeletal bones
    _drawBone(canvas, landmarks.head, landmarks.shoulder, bonePaint);
    _drawBone(canvas, landmarks.shoulder, landmarks.elbow, bonePaint);
    _drawBone(canvas, landmarks.elbow, landmarks.wrist, bonePaint);
    _drawBone(canvas, landmarks.shoulder, landmarks.hip, bonePaint);
    _drawBone(canvas, landmarks.hip, landmarks.knee, bonePaint);
    _drawBone(canvas, landmarks.knee, landmarks.ankle, bonePaint);

    // Draw joints
    final joints = [
      landmarks.head,
      landmarks.shoulder,
      landmarks.elbow,
      landmarks.wrist,
      landmarks.hip,
      landmarks.knee,
      landmarks.ankle,
    ];

    for (final joint in joints) {
      canvas.drawCircle(joint, 7.0, jointPaint);
      canvas.drawCircle(joint, 7.0, jointBorderPaint);
    }

    // Draw active joint angle badge
    final anglePos = Offset(landmarks.knee.dx + 20, landmarks.knee.dy - 10);
    _drawAngleBadge(canvas, anglePos, '${currentAngle.toInt()}°', themeColor);
  }

  void _drawBone(Canvas canvas, Offset a, Offset b, Paint paint) {
    canvas.drawLine(a, b, paint);
  }

  void _drawAngleBadge(Canvas canvas, Offset position, String text, Color color) {
    final bgPaint = Paint()..color = color.withValues(alpha: 0.9);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: position, width: 48, height: 26),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, bgPaint);

    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter oldDelegate) {
    return oldDelegate.currentAngle != currentAngle ||
        oldDelegate.feedbackType != feedbackType ||
        oldDelegate.landmarks != landmarks;
  }
}
