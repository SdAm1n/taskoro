import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService extends ChangeNotifier {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isAvailable = false;
  bool _isSpeaking = false;
  String _lastWords = '';
  double _confidence = 1.0;

  List<stt.LocaleName> _locales = [];
  String _currentLocaleId = '';

  // Getters
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;
  double get confidence => _confidence;
  List<stt.LocaleName> get locales => _locales;
  String get currentLocaleId => _currentLocaleId;

  SpeechService() {
    _initializeSpeech();
    _initializeTts();
  }

  /// Initialize speech-to-text
  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();

    try {
      // Check and request microphone permission
      var status = await Permission.microphone.status;
      debugPrint('Current microphone permission status: $status');

      if (status.isDenied) {
        status = await Permission.microphone.request();
        debugPrint('Requested microphone permission, new status: $status');
      }

      if (status.isPermanentlyDenied) {
        debugPrint(
          'Microphone permission permanently denied. Opening app settings.',
        );
        await openAppSettings();
        return;
      }

      if (status != PermissionStatus.granted) {
        debugPrint('Microphone permission not granted: $status');
        _isAvailable = false;
        notifyListeners();
        return;
      }

      debugPrint(
        'Microphone permission granted, initializing speech recognition...',
      );

      _isAvailable = await _speech.initialize(
        onStatus: (val) {
          debugPrint('Speech Status: $val');
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
            notifyListeners();
          } else if (val == 'listening') {
            _isListening = true;
            notifyListeners();
          }
        },
        onError: (val) {
          debugPrint('Speech Error: ${val.errorMsg}');
          _isListening = false;
          notifyListeners();
        },
        debugLogging: true,
        finalTimeout: const Duration(seconds: 3), // Add final timeout
      );

      debugPrint('Speech initialization result: $_isAvailable');

      if (_isAvailable) {
        _locales = await _speech.locales();
        var systemLocale = await _speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? 'en_US';
        debugPrint(
          'Available locales: ${_locales.length}, using: $_currentLocaleId',
        );
        debugPrint('Speech recognition successfully initialized');
      } else {
        debugPrint('Speech recognition not available on this device');
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      _isAvailable = false;
    }

    notifyListeners();
  }

  /// Initialize text-to-speech
  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();

    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// Start listening for speech input
  Future<void> startListening({
    Duration? timeout,
    Duration? pauseFor,
    String? localeId,
  }) async {
    if (!_isAvailable || _isListening) return;

    try {
      debugPrint('Configuring speech listener...');
      await _speech.listen(
        onResult: (val) {
          debugPrint(
            'Speech result: "${val.recognizedWords}" (confidence: ${val.confidence})',
          );
          _lastWords = val.recognizedWords;
          _confidence = val.confidence;
          notifyListeners();
        },
        listenFor: timeout ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 2),
        localeId: localeId ?? _currentLocaleId,
        partialResults: true, // Enable partial results for better feedback
        onSoundLevelChange: (level) {
          debugPrint('Sound level: $level');
        },
        cancelOnError: false, // Don't cancel on minor errors
        listenMode: stt.ListenMode.confirmation, // Use confirmation mode
      );

      _isListening = true;
      debugPrint('Speech listener started successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('Start listening error: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
      _isListening = false;
      _lastWords = '';
      notifyListeners();
    } catch (e) {
      debugPrint('Cancel listening error: $e');
    }
  }

  /// Speak text using TTS
  Future<void> speak(
    String text, {
    double? pitch,
    double? rate,
    double? volume,
    String? language,
  }) async {
    if (_isSpeaking) {
      await stop();
    }

    try {
      if (pitch != null) await _flutterTts.setPitch(pitch);
      if (rate != null) await _flutterTts.setSpeechRate(rate);
      if (volume != null) await _flutterTts.setVolume(volume);
      if (language != null) await _flutterTts.setLanguage(language);

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Speak error: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Stop TTS
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Stop TTS error: $e');
    }
  }

  /// Pause TTS
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('Pause TTS error: $e');
    }
  }

  /// Check if speech recognition is available
  Future<bool> checkAvailability() async {
    try {
      var status = await Permission.microphone.status;
      debugPrint('Checking microphone permission status: $status');

      if (status != PermissionStatus.granted) {
        status = await Permission.microphone.request();
        debugPrint('Requested microphone permission, result: $status');
      }

      if (status == PermissionStatus.granted) {
        if (!_isAvailable) {
          await _initializeSpeech();
        }
        debugPrint('Speech recognition availability: $_isAvailable');
        return _isAvailable;
      } else {
        debugPrint(
          'Microphone permission not granted, speech recognition unavailable',
        );
        _isAvailable = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Availability check error: $e');
      _isAvailable = false;
      notifyListeners();
      return false;
    }
  }

  /// Get available TTS languages
  Future<List<dynamic>> getTtsLanguages() async {
    try {
      return await _flutterTts.getLanguages ?? [];
    } catch (e) {
      debugPrint('Get TTS languages error: $e');
      return [];
    }
  }

  /// Get available TTS voices
  Future<List<dynamic>> getTtsVoices() async {
    try {
      return await _flutterTts.getVoices ?? [];
    } catch (e) {
      debugPrint('Get TTS voices error: $e');
      return [];
    }
  }

  /// Set TTS voice
  Future<void> setTtsVoice(Map<String, String> voice) async {
    try {
      await _flutterTts.setVoice(voice);
    } catch (e) {
      debugPrint('Set TTS voice error: $e');
    }
  }

  /// Get speech recognition error
  String? getLastError() {
    return _speech.lastError?.errorMsg;
  }

  /// Set speech recognition locale
  Future<void> setLocale(String localeId) async {
    _currentLocaleId = localeId;
    notifyListeners();
  }

  /// Listen for a single phrase with timeout
  Future<String?> listenForPhrase({
    Duration timeout = const Duration(seconds: 30),
    String? prompt,
  }) async {
    debugPrint('Starting listenForPhrase with timeout: ${timeout.inSeconds}s');

    if (!_isAvailable) {
      debugPrint('Speech not available, attempting to initialize...');
      await _initializeSpeech();
      if (!_isAvailable) {
        debugPrint('Speech recognition not available after initialization');
        return null;
      }
    }

    // Check microphone permission again
    var status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      debugPrint('Microphone permission not granted: $status');
      return null;
    }

    if (prompt != null) {
      debugPrint('Speaking prompt: $prompt');
      await speak(prompt);
      // Wait for TTS to finish
      while (_isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _lastWords = '';
    _confidence = 0.0;
    final completer = Completer<String?>();
    bool hasCompleted = false;
    bool hasReceivedResult = false;

    // Start listening with enhanced error handling
    try {
      debugPrint('Starting speech recognition...');
      debugPrint('Speech engine available: $_isAvailable');
      debugPrint('Current locale: $_currentLocaleId');

      await _speech.listen(
        onResult: (val) {
          debugPrint(
            'SPEECH RESULT RECEIVED: "${val.recognizedWords}" (final: ${val.hasConfidenceRating}, confidence: ${val.confidence})',
          );
          _lastWords = val.recognizedWords;
          _confidence = val.confidence;
          hasReceivedResult = true;
          notifyListeners();

          // Complete immediately if we get a result with good confidence
          if (val.recognizedWords.trim().isNotEmpty &&
              val.confidence > 0.7 &&
              !hasCompleted) {
            hasCompleted = true;
            debugPrint(
              'Completing with high-confidence result: "${val.recognizedWords}"',
            );
            completer.complete(val.recognizedWords.trim());
          }
        },
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3), // Increased pause time
        localeId: _currentLocaleId,
        partialResults: true,
        onSoundLevelChange: (level) {
          // Only log every 10th sound level to reduce spam
          if (level % 1.0 == 0) {
            debugPrint('Sound level: $level');
          }
        },
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );

      _isListening = true;
      notifyListeners();
      debugPrint('Speech listener started successfully, waiting for input...');

      // Set up timeout handler
      Timer(timeout, () {
        if (!hasCompleted) {
          hasCompleted = true;
          debugPrint('Speech recognition TIMEOUT after ${timeout.inSeconds}s');
          stopListening();
          final result = _lastWords.trim();
          debugPrint(
            'Timeout result: "$result" (hasReceivedResult: $hasReceivedResult)',
          );
          completer.complete(result.isEmpty ? null : result);
        }
      });

      // Simplified status monitoring - check less frequently
      late StreamSubscription subscription;
      subscription = Stream.periodic(const Duration(milliseconds: 500)).listen((
        _,
      ) {
        debugPrint(
          'Status check - isListening: $_isListening, hasCompleted: $hasCompleted, hasReceivedResult: $hasReceivedResult',
        );

        if (!_isListening && !hasCompleted) {
          // Only complete if we're not listening AND we have some result OR enough time has passed
          if (hasReceivedResult || _lastWords.trim().isNotEmpty) {
            hasCompleted = true;
            subscription.cancel();
            final result = _lastWords.trim();
            debugPrint('Speech stopped naturally. Final result: "$result"');
            completer.complete(result.isEmpty ? null : result);
          }
        }
      });

      final result = await completer.future;
      if (!subscription.isPaused) {
        subscription.cancel();
      }
      debugPrint('listenForPhrase COMPLETED with result: "$result"');
      return result;
    } catch (e) {
      debugPrint('Speech recognition ERROR: $e');
      if (!hasCompleted) {
        hasCompleted = true;
        _isListening = false;
        notifyListeners();
      }
      return null;
    }
  }

  /// Continuous conversation mode
  Stream<String> continuousListen({
    Duration phraseTimeout = const Duration(seconds: 5),
    Duration sessionTimeout = const Duration(minutes: 10),
  }) async* {
    if (!_isAvailable) await _initializeSpeech();
    if (!_isAvailable) return;

    final sessionStart = DateTime.now();

    while (DateTime.now().difference(sessionStart) < sessionTimeout) {
      try {
        final result = await listenForPhrase(timeout: phraseTimeout);
        if (result != null && result.trim().isNotEmpty) {
          yield result;
        }

        // Short break between phrases
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Continuous listen error: $e');
        break;
      }
    }
  }

  /// Simple speech test without complex logic
  Future<String?> testSimpleListen() async {
    debugPrint('=== SIMPLE SPEECH TEST START ===');

    if (!_isAvailable) {
      await _initializeSpeech();
    }

    if (!_isAvailable) {
      debugPrint('Speech not available');
      return null;
    }

    final permission = await Permission.microphone.status;
    debugPrint('Microphone permission: $permission');

    if (permission != PermissionStatus.granted) {
      debugPrint('No microphone permission');
      return null;
    }

    String lastResult = '';

    try {
      await _speech.listen(
        onResult: (result) {
          debugPrint('Simple test result: "${result.recognizedWords}"');
          lastResult = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
      );

      debugPrint('Started listening, waiting 10 seconds...');
      await Future.delayed(const Duration(seconds: 10));

      await _speech.stop();
      debugPrint('Stopped listening, final result: "$lastResult"');

      return lastResult.trim().isEmpty ? null : lastResult.trim();
    } catch (e) {
      debugPrint('Simple test error: $e');
      return null;
    }
  }

  /// Simple test for speech recognition
  Future<void> testBasicSpeech() async {
    debugPrint('=== TESTING BASIC SPEECH RECOGNITION ===');

    // Check availability
    debugPrint('1. Checking availability...');
    bool available = await checkAvailability();
    debugPrint('   Available: $available');

    if (!available) {
      debugPrint('   Speech not available, stopping test');
      return;
    }

    // Check permission
    debugPrint('2. Checking permission...');
    var permission = await Permission.microphone.status;
    debugPrint('   Permission: $permission');

    if (permission != PermissionStatus.granted) {
      debugPrint('   Permission not granted, stopping test');
      return;
    }

    // Test basic listen
    debugPrint('3. Starting basic listen test...');
    _lastWords = '';

    try {
      await _speech.listen(
        onResult: (result) {
          debugPrint('   Test result: "${result.recognizedWords}"');
          _lastWords = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 1),
        partialResults: true,
      );

      _isListening = true;
      debugPrint('   Listen started, waiting 6 seconds...');

      await Future.delayed(const Duration(seconds: 6));

      await _speech.stop();
      _isListening = false;

      debugPrint('   Final result: "$_lastWords"');
      debugPrint('=== BASIC SPEECH TEST COMPLETE ===');
    } catch (e) {
      debugPrint('   Test error: $e');
      _isListening = false;
    }
  }

  /// Test speech recognition functionality
  Future<Map<String, dynamic>> testSpeechFunctionality() async {
    final result = <String, dynamic>{};

    try {
      // Test microphone permission
      var permissionStatus = await Permission.microphone.status;
      result['microphone_permission_status'] = permissionStatus.toString();

      if (permissionStatus != PermissionStatus.granted) {
        permissionStatus = await Permission.microphone.request();
        result['microphone_permission_after_request'] =
            permissionStatus.toString();
      }

      result['microphone_permission_granted'] =
          permissionStatus == PermissionStatus.granted;

      // Test speech recognition initialization
      if (permissionStatus == PermissionStatus.granted) {
        final speechAvailable = await _speech.initialize(
          debugLogging: true,
          onStatus: (status) => debugPrint('Test Speech Status: $status'),
          onError:
              (error) => debugPrint('Test Speech Error: ${error.errorMsg}'),
        );

        result['speech_recognition_available'] = speechAvailable;

        if (speechAvailable) {
          final locales = await _speech.locales();
          result['available_locales_count'] = locales.length;
          result['available_locales'] =
              locales.map((l) => l.localeId).take(5).toList();

          final systemLocale = await _speech.systemLocale();
          result['system_locale'] = systemLocale?.localeId ?? 'unknown';
        }
      }

      // Test TTS
      result['tts_available'] = true;

      final languages = await getTtsLanguages();
      result['tts_languages_count'] = languages.length;
    } catch (e) {
      result['error'] = e.toString();
    }

    debugPrint('Speech functionality test results: $result');
    return result;
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
