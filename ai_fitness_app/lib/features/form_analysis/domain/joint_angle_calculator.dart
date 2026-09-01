import 'dart:math';
import 'package:flutter/material.dart';

class JointAngleCalculator {
  JointAngleCalculator._();

  /// Computes the angle in degrees at vertex [b] between vectors BA and BC.
  static double calculateAngle(Offset a, Offset b, Offset c) {
    final double v1x = a.dx - b.dx;
    final double v1y = a.dy - b.dy;
    final double v2x = c.dx - b.dx;
    final double v2y = c.dy - b.dy;

    final double dotProduct = (v1x * v2x) + (v1y * v2y);
    final double magnitude1 = sqrt((v1x * v1x) + (v1y * v1y));
    final double magnitude2 = sqrt((v2x * v2x) + (v2y * v2y));

    if (magnitude1 == 0 || magnitude2 == 0) return 180.0;

    final double cosAngle = (dotProduct / (magnitude1 * magnitude2)).clamp(-1.0, 1.0);
    return (acos(cosAngle) * 180.0) / pi;
  }
}

