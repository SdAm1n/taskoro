import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_task_service.dart';

class SpeechDebugWidget extends StatefulWidget {
  const SpeechDebugWidget({super.key});

  @override
  State<SpeechDebugWidget> createState() => _SpeechDebugWidgetState();
}

class _SpeechDebugWidgetState extends State<SpeechDebugWidget> {
  Map<String, dynamic>? _testResults;
  bool _isLoading = false;
  String _lastSpeechResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Debug'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runSpeechTest,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Test Speech Functionality'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testSpeechRecognition,
              child: const Text('Test Speech Recognition'),
            ),
            const SizedBox(height: 16),
            if (_lastSpeechResult.isNotEmpty) ...[
              const Text(
                'Last Speech Result:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_lastSpeechResult),
              ),
              const SizedBox(height: 16),
            ],
            if (_testResults != null) ...[
              const Text(
                'Test Results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _formatTestResults(_testResults!),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runSpeechTest() async {
    setState(() {
      _isLoading = true;
      _testResults = null;
    });

    try {
      final aiTaskService = Provider.of<AITaskService>(context, listen: false);
      final results =
          await aiTaskService.speechService.testSpeechFunctionality();

      setState(() {
        _testResults = results;
      });
    } catch (e) {
      setState(() {
        _testResults = {'error': e.toString()};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSpeechRecognition() async {
    setState(() {
      _isLoading = true;
      _lastSpeechResult = '';
    });

    try {
      final aiTaskService = Provider.of<AITaskService>(context, listen: false);

      // Show a dialog while listening
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Speech Test'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, size: 48),
                  SizedBox(height: 16),
                  Text('Say something...'),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    aiTaskService.speechService.cancelListening();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );

      final result = await aiTaskService.speechService.listenForPhrase(
        timeout: const Duration(seconds: 15),
        prompt: null, // No TTS prompt to avoid interference
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        setState(() {
          _lastSpeechResult = result ?? 'No speech detected';
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        setState(() {
          _lastSpeechResult = 'Error: $e';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTestResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();

    results.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    return buffer.toString();
  }
}
