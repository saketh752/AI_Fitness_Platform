import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/domain/auth_session_store.dart';
import '../data/coach_api_service.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CoachApiService _coachApiService = CoachApiService();

  bool _isThinking = false;
  final List<_ChatMessage> _messages = [];

  final List<String> _suggestedQuestions = [
    'How is my workout plan optimized for my goal?',
    'What should I eat to hit my remaining macros today?',
    'Tips for proper form on squats & pushups',
    'How should I warm up before my session?',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final userName = AuthSessionStore.name.isNotEmpty
        ? AuthSessionStore.name.split(' ')[0]
        : 'Athlete';

    try {
      final history = await _coachApiService.getHistory();
      if (mounted && history.isNotEmpty) {
        setState(() {
          for (final item in history.reversed) {
            final userMsg = item['message']?.toString() ?? '';
            final aiResp = item['response']?.toString() ?? '';
            if (userMsg.isNotEmpty) {
              _messages.add(_ChatMessage(text: userMsg, isAi: false));
            }
            if (aiResp.isNotEmpty) {
              _messages.add(_ChatMessage(text: aiResp, isAi: true));
            }
          }
        });
        _scrollToBottom();
        return;
      }
    } catch (_) {
      // Fallback to default greeting
    }

    if (mounted && _messages.isEmpty) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Hi $userName! 👋\nI am your AI Coach. I have your profile, workout routine, and today\'s nutrition targets ready. How can I help you today?',
            isAi: true,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? suggestedMessage]) async {
    final message = suggestedMessage ?? _messageController.text.trim();

    if (message.isEmpty || _isThinking) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: message,
          isAi: false,
        ),
      );

      _messageController.clear();
      _isThinking = true;
    });

    _scrollToBottom();

    try {
      final result = await _coachApiService.sendMessage(message);
      final reply = result['response']?.toString() ??
          'I am analyzing your fitness data. Keep up the great consistency!';

      if (mounted) {
        setState(() {
          _isThinking = false;
          _messages.add(_ChatMessage(text: reply, isAi: true));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isThinking = false;
          _messages.add(
            _ChatMessage(
              text:
                  'Based on your plan, stay focused on progressive overload and hitting your daily protein target! (Offline mode)',
              isAi: true,
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AI Coach',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Powered by Llama 3 & Groq',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isThinking) {
                    return _buildThinkingBubble();
                  }
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
            if (_messages.length <= 2 && !_isThinking) _buildSuggestions(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isAi = message.isAi;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.fitness_center_rounded, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAi ? const Color(0xFFF3F4F6) : AppColors.primary,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isAi ? const Radius.circular(4) : const Radius.circular(16),
                  bottomRight: isAi ? const Radius.circular(16) : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isAi ? AppColors.textPrimary : Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.fitness_center_rounded, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                SizedBox(width: 10),
                Text('Coach is thinking...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestedQuestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final q = _suggestedQuestions[index];
          return ActionChip(
            label: Text(q, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
            backgroundColor: AppColors.primaryLight,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () => _sendMessage(q),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask your coach anything...',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isAi});
  final String text;
  final bool isAi;
}