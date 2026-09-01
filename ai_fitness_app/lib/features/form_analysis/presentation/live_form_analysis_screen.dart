import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../workouts/presentation/workout_plan_state.dart';
import '../domain/exercise_form_evaluator.dart';
import 'pose_overlay_painter.dart';

class LiveFormAnalysisScreen extends StatefulWidget {
  const LiveFormAnalysisScreen({required this.exercise, super.key});

  final ExerciseItem exercise;

  @override
  State<LiveFormAnalysisScreen> createState() => _LiveFormAnalysisScreenState();
}

class _LiveFormAnalysisScreenState extends State<LiveFormAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final ExerciseFormEvaluator _evaluator;
  late final AnimationController _motionController;
  Timer? _analysisTimer;

  FormEvaluationResult _latestResult = const FormEvaluationResult(
    reps: 0,
    currentAngle: 170.0,
    feedback: 'Get in starting position',
    feedbackType: FormFeedbackType.info,
    formAccuracy: 100.0,
    isInRep: false,
  );

  bool _isCameraActive = true;
  double _manualAngle = 165.0;

  @override
  void initState() {
    super.initState();
    _evaluator = ExerciseFormEvaluator(
      exerciseType: ExerciseFormEvaluator.detectType(widget.exercise.name),
    );

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _motionController.addListener(_onMotionFrame);
  }

  void _onMotionFrame() {
    if (!_isCameraActive) return;

    // Simulate natural exercise joint range from 170 deg down to 80 deg
    final t = _motionController.value;
    final simulatedAngle = 170.0 - (90.0 * sin(t * pi));

    setState(() {
      _manualAngle = simulatedAngle;
      _evaluateCurrentAngle();
    });
  }

  void _evaluateCurrentAngle() {
    // Generate landmarks based on current angle for visual skeleton
    final center = MediaQuery.of(context).size;
    final cx = center.width / 2;
    final cy = center.height / 2 - 20;

    final kneeY = cy + 90;
    final kneeX = cx - (30 * (1 - (_manualAngle / 180)));

    final result = _evaluator.evaluatePose(
      shoulder: Offset(cx, cy - 80),
      elbowOrHip: Offset(cx, cy),
      wristOrKnee: Offset(kneeX, kneeY),
      ankle: Offset(cx, cy + 180),
    );

    _latestResult = result;
  }

  @override
  void dispose() {
    _motionController.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2 - 20;
    final kneeX = cx - (30 * (1 - (_manualAngle / 180)));

    final landmarks = PoseLandmarks(
      head: Offset(cx, cy - 130),
      shoulder: Offset(cx, cy - 80),
      elbow: Offset(cx + 35, cy - 35),
      wrist: Offset(cx + 45, cy + 10),
      hip: Offset(cx, cy),
      knee: Offset(kneeX, cy + 90),
      ankle: Offset(cx, cy + 180),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark gym camera view
      body: SafeArea(
        child: Stack(
          children: [
            // Camera / Pose Canvas Layer
            Positioned.fill(
              child: CustomPaint(
                painter: PoseOverlayPainter(
                  landmarks: landmarks,
                  currentAngle: _latestResult.currentAngle,
                  feedbackType: _latestResult.feedbackType,
                ),
              ),
            ),

            // Top HUD Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam_rounded, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.exercise.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(
                        _isCameraActive ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isCameraActive = !_isCameraActive;
                          if (_isCameraActive) {
                            _motionController.repeat(reverse: true);
                          } else {
                            _motionController.stop();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Reps Badge & Accuracy Card
            Positioned(
              top: 80,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_latestResult.reps}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'REPS',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Accuracy: ${_latestResult.formAccuracy.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Real-time Feedback Banner
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: _getFeedbackColor(_latestResult.feedbackType),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFeedbackIcon(_latestResult.feedbackType),
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _latestResult.feedback,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _showSetSummary,
                      child: const Text(
                        'Finish Form Analysis',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFeedbackColor(FormFeedbackType type) {
    switch (type) {
      case FormFeedbackType.good:
        return const Color(0xFF10B981);
      case FormFeedbackType.warning:
        return const Color(0xFFF59E0B);
      case FormFeedbackType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getFeedbackIcon(FormFeedbackType type) {
    switch (type) {
      case FormFeedbackType.good:
        return Icons.check_circle_rounded;
      case FormFeedbackType.warning:
        return Icons.warning_amber_rounded;
      case FormFeedbackType.info:
        return Icons.info_outline_rounded;
    }
  }

  void _showSetSummary() {
    _motionController.stop();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Form Analysis Summary',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(widget.exercise.name, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _summaryMetric('${_latestResult.reps}', 'Reps Done'),
                  _summaryMetric('${_latestResult.formAccuracy.toInt()}%', 'Form Score'),
                  _summaryMetric('1.8s', 'Avg Tempo'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.pop(context, _latestResult.reps); // Return reps to workout
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryMetric(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

