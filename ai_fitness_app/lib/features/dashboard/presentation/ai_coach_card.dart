import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class AICoachCard extends StatefulWidget {
  const AICoachCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  State<AICoachCard> createState() => _AICoachCardState();
}

class _AICoachCardState extends State<AICoachCard> {
  bool _pressed = false;
  bool _opening = false;

  void _open() {
    if (_opening) return;
    setState(() {
      _pressed = true;
      _opening = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _pressed = false);
      widget.onTap();
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _opening = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .98 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      'AI COACH',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Need help with your\nworkout or nutrition?',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Text(
                      'Ask',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
