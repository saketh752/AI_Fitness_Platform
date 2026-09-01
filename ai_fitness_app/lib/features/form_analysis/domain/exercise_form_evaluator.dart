import 'package:flutter/material.dart';
import 'joint_angle_calculator.dart';

enum ExerciseType { squat, pushup, bicepCurl, general }

enum FormFeedbackType { good, warning, info }

class FormEvaluationResult {
  final int reps;
  final double currentAngle;
  final String feedback;
  final FormFeedbackType feedbackType;
  final double formAccuracy;
  final bool isInRep;

  const FormEvaluationResult({
    required this.reps,
    required this.currentAngle,
    required this.feedback,
    required this.feedbackType,
    required this.formAccuracy,
    required this.isInRep,
  });
}

class ExerciseFormEvaluator {
  final ExerciseType exerciseType;
  int reps = 0;
  bool _isAtBottom = false;
  int _goodFormRepCount = 0;
  String _lastFeedback = 'Get in starting position';
  FormFeedbackType _lastFeedbackType = FormFeedbackType.info;

  ExerciseFormEvaluator({this.exerciseType = ExerciseType.squat});

  static ExerciseType detectType(String exerciseName) {
    final lower = exerciseName.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    if (lower.contains('squat') || lower.contains('leg')) return ExerciseType.squat;
    if (lower.contains('pushup') || lower.contains('press') || lower.contains('bench') || lower.contains('chest')) {
      return ExerciseType.pushup;
    }
    if (lower.contains('curl') || lower.contains('bicep') || lower.contains('arm')) {
      return ExerciseType.bicepCurl;
    }
    return ExerciseType.general;
  }

  FormEvaluationResult evaluateAngle(double angle) {
    switch (exerciseType) {
      case ExerciseType.squat:
        _evaluateSquat(angle);
        break;
      case ExerciseType.pushup:
        _evaluatePushup(angle);
        break;
      case ExerciseType.bicepCurl:
        _evaluateCurl(angle);
        break;
      case ExerciseType.general:
        _evaluateGeneral(angle);
        break;
    }

    final accuracy = reps > 0
        ? ((_goodFormRepCount / reps) * 100).clamp(50.0, 100.0)
        : 100.0;

    return FormEvaluationResult(
      reps: reps,
      currentAngle: angle,
      feedback: _lastFeedback,
      feedbackType: _lastFeedbackType,
      formAccuracy: accuracy,
      isInRep: _isAtBottom,
    );
  }

  FormEvaluationResult evaluatePose({
    required Offset shoulder,
    required Offset elbowOrHip,
    required Offset wristOrKnee,
    Offset? ankle,
  }) {
    double angle;
    if (exerciseType == ExerciseType.squat && ankle != null) {
      // Hip -> Knee -> Ankle angle
      angle = JointAngleCalculator.calculateAngle(elbowOrHip, wristOrKnee, ankle);
    } else {
      // Shoulder -> Elbow -> Wrist angle
      angle = JointAngleCalculator.calculateAngle(shoulder, elbowOrHip, wristOrKnee);
    }

    return evaluateAngle(angle);
  }

  void _evaluateSquat(double kneeAngle) {
    if (kneeAngle < 95.0) {
      if (!_isAtBottom) {
        _isAtBottom = true;
        _lastFeedback = 'Great depth! Press through your heels';
        _lastFeedbackType = FormFeedbackType.good;
      }
    } else if (kneeAngle > 155.0) {
      if (_isAtBottom) {
        _isAtBottom = false;
        reps++;
        _goodFormRepCount++;
        _lastFeedback = 'Rep completed! Ready for next';
        _lastFeedbackType = FormFeedbackType.good;
      } else {
        _lastFeedback = 'Start lowering into squat';
        _lastFeedbackType = FormFeedbackType.info;
      }
    } else if (kneeAngle >= 95.0 && kneeAngle <= 120.0) {
      if (!_isAtBottom) {
        _lastFeedback = 'Go slightly lower for full depth';
        _lastFeedbackType = FormFeedbackType.warning;
      }
    }
  }

  void _evaluatePushup(double elbowAngle) {
    if (elbowAngle < 90.0) {
      if (!_isAtBottom) {
        _isAtBottom = true;
        _lastFeedback = 'Chest down! Push back up strong';
        _lastFeedbackType = FormFeedbackType.good;
      }
    } else if (elbowAngle > 150.0) {
      if (_isAtBottom) {
        _isAtBottom = false;
        reps++;
        _goodFormRepCount++;
        _lastFeedback = 'Rep completed! Maintain plank';
        _lastFeedbackType = FormFeedbackType.good;
      } else {
        _lastFeedback = 'Lower your chest to floor';
        _lastFeedbackType = FormFeedbackType.info;
      }
    }
  }

  void _evaluateCurl(double elbowAngle) {
    if (elbowAngle < 65.0) {
      if (!_isAtBottom) {
        _isAtBottom = true;
        _lastFeedback = 'Peak contraction! Squeeze bicep';
        _lastFeedbackType = FormFeedbackType.good;
      }
    } else if (elbowAngle > 145.0) {
      if (_isAtBottom) {
        _isAtBottom = false;
        reps++;
        _goodFormRepCount++;
        _lastFeedback = 'Full extension! Curl up';
        _lastFeedbackType = FormFeedbackType.good;
      } else {
        _lastFeedback = 'Curl weight up toward shoulder';
        _lastFeedbackType = FormFeedbackType.info;
      }
    }
  }

  void _evaluateGeneral(double angle) {
    if (angle < 90.0) {
      if (!_isAtBottom) {
        _isAtBottom = true;
        _lastFeedback = 'Good range of motion!';
        _lastFeedbackType = FormFeedbackType.good;
      }
    } else if (angle > 150.0) {
      if (_isAtBottom) {
        _isAtBottom = false;
        reps++;
        _goodFormRepCount++;
        _lastFeedback = 'Rep count +1!';
        _lastFeedbackType = FormFeedbackType.good;
      }
    }
  }

  void reset() {
    reps = 0;
    _goodFormRepCount = 0;
    _isAtBottom = false;
    _lastFeedback = 'Get in starting position';
    _lastFeedbackType = FormFeedbackType.info;
  }
}

