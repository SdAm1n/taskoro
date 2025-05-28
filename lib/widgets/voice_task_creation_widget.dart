import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../services/ai_task_service.dart';
import '../services/auth_service.dart';

class VoiceTaskCreationWidget extends StatefulWidget {
  final VoidCallback? onTaskCreated;
  final String? initialPrompt;

  const VoiceTaskCreationWidget({
    super.key,
    this.onTaskCreated,
    this.initialPrompt,
  });

  @override
  State<VoiceTaskCreationWidget> createState() =>
      _VoiceTaskCreationWidgetState();
}

class _VoiceTaskCreationWidgetState extends State<VoiceTaskCreationWidget>
    with TickerProviderStateMixin {
  late AITaskService _aiTaskService;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  String _lastWords = '';
  String _status = 'Tap to start voice input';

  @override
  void initState() {
    super.initState();
    _aiTaskService = Provider.of<AITaskService>(context, listen: false);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to speech service changes
    _aiTaskService.speechService.addListener(_onSpeechStateChanged);
  }

  @override
  void dispose() {
    _aiTaskService.speechService.removeListener(_onSpeechStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onSpeechStateChanged() {
    if (mounted) {
      setState(() {
        _isListening = _aiTaskService.speechService.isListening;
        _lastWords = _aiTaskService.speechService.lastWords;

        if (_isListening) {
          _status = 'Listening... Speak now';
          _animationController.repeat(reverse: true);
        } else if (_lastWords.isNotEmpty) {
          _status = 'Processing: $_lastWords';
          _animationController.stop();
        } else {
          _status = 'Tap to start voice input';
          _animationController.stop();
        }
      });
    }
  }

  Future<void> _startVoiceTaskCreation() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;

    if (userId == null) {
      _showError('Please log in to create tasks');
      return;
    }

    setState(() {
      _status = 'Initializing...';
    });

    try {
      final task = await _aiTaskService.createTaskFromVoice(
        prompt: widget.initialPrompt,
        userId: userId,
      );

      if (task != null) {
        setState(() {
          _status = 'Task created successfully!';
        });

        widget.onTaskCreated?.call();

        // Show success feedback
        _showSuccess('Task "${task.title}" created successfully!');

        // Reset after delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _status = 'Tap to start voice input';
            _lastWords = '';
          });
        }
      } else {
        setState(() {
          _status = 'Failed to create task. Try again.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error occurred. Please try again.';
      });
      _showError('Failed to create task: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AITaskService>(
      builder: (context, aiTaskService, child) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(16), // Reduced from 24
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: Theme.of(context).primaryColor,
                      size: 24, // Reduced from 28
                    ),
                    const SizedBox(width: 8), // Reduced from 12
                    Expanded(
                      child: Text(
                        'Voice Task Creation',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          // Changed from headlineSmall
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16), // Reduced from 24
                // Voice Button
                GestureDetector(
                  onTap:
                      aiTaskService.isProcessing
                          ? null
                          : _startVoiceTaskCreation,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: AvatarGlow(
                          animate: _isListening,
                          glowColor: Theme.of(context).primaryColor,
                          // radius parameter is not available in version 3.0.1
                          duration: const Duration(milliseconds: 2000),
                          repeat: true,
                          child: Container(
                            width: 100, // Reduced from 120
                            height: 100, // Reduced from 120
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _isListening
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              size: 42, // Reduced from 48
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16), // Reduced from 20
                // Status Text
                Text(
                  _status,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ), // Changed from bodyLarge
                  textAlign: TextAlign.center,
                ),

                // Last Words Preview
                if (_lastWords.isNotEmpty) ...[
                  const SizedBox(height: 8), // Reduced from 12
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced from 12
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 14, // Reduced from 16
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6), // Reduced from 8
                        Expanded(
                          child: Text(
                            _lastWords,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                            maxLines: 2, // Limit number of lines
                            overflow:
                                TextOverflow.ellipsis, // Handle overflow text
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12), // Reduced from 16
                // Processing Indicator
                if (aiTaskService.isProcessing)
                  Column(
                    children: [
                      const LinearProgressIndicator(),
                      const SizedBox(height: 6), // Reduced from 8
                      Text(
                        'Processing with AI...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                // Help Text
                if (!_isListening && !aiTaskService.isProcessing) ...[
                  const SizedBox(height: 12), // Reduced from 16
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced from 12
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 14, // Reduced from 16
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 6), // Reduced from 8
                        Expanded(
                          child: Text(
                            'Try saying: "Create a task to buy groceries tomorrow"',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[700],
                              fontSize: 11, // Added smaller font size
                            ),
                            maxLines: 2, // Limit to 2 lines
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
