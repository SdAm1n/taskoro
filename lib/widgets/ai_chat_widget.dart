import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../services/ai_task_service.dart';
import '../services/auth_service.dart';

class AIChatWidget extends StatefulWidget {
  const AIChatWidget({super.key});

  @override
  State<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends State<AIChatWidget> {
  final List<types.Message> _messages = [];
  late types.User _user;
  late types.User _aiUser;

  @override
  void initState() {
    super.initState();

    _user = const types.User(id: 'user', firstName: 'You');

    _aiUser = const types.User(
      id: 'ai',
      firstName: 'TaskoroAI',
      imageUrl: 'https://i.pravatar.cc/150?img=5',
    );

    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _aiUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'welcome',
      text:
          'Hi! I\'m TaskoroAI, your intelligent task assistant. I can help you:\n\n'
          '• Create tasks from natural language\n'
          '• Generate task descriptions\n'
          '• Manage your schedule\n'
          '• Answer questions about productivity\n'
          '• Provide task suggestions\n\n'
          'Try asking me something like "Create a task to review project proposal" or "How can I be more productive?"',
    );

    setState(() {
      _messages.insert(0, welcomeMessage);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    _addMessage(textMessage);

    // Show typing indicator
    final typingMessage = types.TextMessage(
      author: _aiUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'typing',
      text: '...',
    );
    _addMessage(typingMessage);

    // Get services before async operations
    final authService = Provider.of<AuthService>(context, listen: false);
    final aiTaskService = Provider.of<AITaskService>(context, listen: false);
    final userId = authService.currentUser?.id;

    // Get AI response
    try {
      final response = await aiTaskService.chatWithAI(
        message.text,
        userId: userId,
      );

      // Check if widget is still mounted before updating UI
      if (!mounted) return;

      // Remove typing indicator
      setState(() {
        _messages.removeWhere((msg) => msg.id == 'typing');
      });

      // Add AI response
      final aiResponse = types.TextMessage(
        author: _aiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
      );
      _addMessage(aiResponse);
    } catch (e) {
      // Check if widget is still mounted before updating UI
      if (!mounted) return;

      // Remove typing indicator
      setState(() {
        _messages.removeWhere((msg) => msg.id == 'typing');
      });

      // Add error message
      final errorMessage = types.TextMessage(
        author: _aiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error. Please try again later.',
      );
      _addMessage(errorMessage);
    }
  }

  void _handleVoicePressed() async {
    // Get services and context-dependent values before async operations
    final authService = Provider.of<AuthService>(context, listen: false);
    final aiTaskService = Provider.of<AITaskService>(context, listen: false);
    final userId = authService.currentUser?.id;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      if (userId == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Please log in to use voice features'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check speech availability first
      final isAvailable = await aiTaskService.speechService.checkAvailability();

      if (!mounted) return;

      if (!isAvailable) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Speech recognition is not available. Please check microphone permissions in Settings.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Show voice input dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Voice Input'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic,
                    size: 64,
                    color: Theme.of(dialogContext).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text('Speak your message...'),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap Cancel to stop listening',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    aiTaskService.speechService.cancelListening();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );

      // Listen for voice input
      final voiceInput = await aiTaskService.speechService.listenForPhrase(
        timeout: const Duration(seconds: 30),
        prompt: "What would you like to say?",
      );

      if (!mounted) return;

      navigator.pop(); // Close dialog

      if (voiceInput != null && voiceInput.trim().isNotEmpty) {
        _handleSendPressed(types.PartialText(text: voiceInput));
      } else {
        // If normal method failed, try simple method as fallback
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'No speech detected with normal method. Trying simple method...',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        // Try simple test method
        final simpleResult =
            await aiTaskService.speechService.testSimpleListen();

        if (simpleResult != null && simpleResult.trim().isNotEmpty) {
          _handleSendPressed(types.PartialText(text: simpleResult));
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text(
                'No speech detected. Please check microphone permissions and try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      navigator.pop(); // Close dialog if open
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Voice input error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaskoroAI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'AI Task Assistant',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _handleVoicePressed,
            tooltip: 'Voice input',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (!mounted) return;

              switch (value) {
                case 'clear':
                  setState(() {
                    _messages.clear();
                  });
                  _addWelcomeMessage();
                  break;
                case 'help':
                  _showHelpDialog();
                  break;
                case 'debug_speech':
                  _debugSpeech();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Chat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'help',
                    child: Row(
                      children: [
                        Icon(Icons.help),
                        SizedBox(width: 8),
                        Text('Help'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'debug_speech',
                    child: Row(
                      children: [
                        Icon(Icons.bug_report),
                        SizedBox(width: 8),
                        Text('Debug Speech'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Chat(
                // For flutter_chat_ui 1.6.10
                messages: _messages,
                onSendPressed: _handleSendPressed,
                user: _user,
                theme: DefaultChatTheme(
                  primaryColor: Theme.of(context).primaryColor,
                  secondaryColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  inputBackgroundColor: Theme.of(context).cardColor,
                  inputTextColor:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                  messageBorderRadius: 16,
                  messageInsetsHorizontal: 12,
                  messageInsetsVertical: 8,
                  inputMargin: const EdgeInsets.all(8),
                  inputPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                showUserAvatars: true,
                showUserNames: true,
                inputOptions: const InputOptions(
                  sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('TaskoroAI Help'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Example Commands:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• "Create a task to call doctor tomorrow"'),
                  Text('• "Add high priority meeting with team"'),
                  Text('• "Show my tasks for today"'),
                  Text('• "Delete the grocery shopping task"'),
                  Text('• "Mark project review as complete"'),
                  Text('• "How can I be more productive?"'),
                  Text('• "Suggest tasks for this afternoon"'),
                  SizedBox(height: 16),
                  Text(
                    'Voice Commands:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Tap the microphone icon to use voice input'),
                  Text('• You can speak naturally to create and manage tasks'),
                  Text('• Voice responses are available for feedback'),
                  SizedBox(height: 16),
                  Text(
                    'AI Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Automatic task description generation'),
                  Text('• Smart priority and category detection'),
                  Text('• Natural language date parsing'),
                  Text('• Personalized task suggestions'),
                  Text('• Productivity tips and advice'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _debugSpeech() async {
    final aiTaskService = Provider.of<AITaskService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Speech Debug Test'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Running simple speech recognition test...'),
                const SizedBox(height: 8),
                const Text(
                  'Speak clearly when prompted.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );

    try {
      // Run the simple speech test first
      // print('=== STARTING SIMPLE SPEECH TEST ===');
      final simpleResult = await aiTaskService.speechService.testSimpleListen();

      // print('=== SIMPLE TEST RESULT: "$simpleResult" ===');

      // Also run the comprehensive test for comparison
      await aiTaskService.speechService.testBasicSpeech();

      if (!mounted) return;
      Navigator.of(context).pop();

      final resultMessage =
          simpleResult != null
              ? 'Speech test completed! Captured: "$simpleResult"'
              : 'Speech test completed but no speech was captured. Check logs.';

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(resultMessage),
          backgroundColor: simpleResult != null ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      // print('DEBUG SPEECH TEST ERROR: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Speech debug test failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
