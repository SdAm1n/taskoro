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
      // Request microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint('Microphone permission denied');
        return;
      }

      _isAvailable = await _speech.initialize(
        onStatus: (val) {
          debugPrint('Speech Status: $val');
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (val) {
          debugPrint('Speech Error: $val');
          _isListening = false;
          notifyListeners();
        },
      );

      if (_isAvailable) {
        _locales = await _speech.locales();
        var systemLocale = await _speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? 'en_US';
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
      await _speech.listen(
        onResult: (val) {
          _lastWords = val.recognizedWords;
          _confidence = val.confidence;
          notifyListeners();
        },
        listenFor: timeout ?? const Duration(seconds: 45),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        localeId: localeId ?? _currentLocaleId,
        onSoundLevelChange: (level) {
          // Can be used for visual feedback
        },
      );

      _isListening = true;
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
      if (status != PermissionStatus.granted) {
        status = await Permission.microphone.request();
      }

      if (status == PermissionStatus.granted) {
        _isAvailable = await _speech.initialize();
        notifyListeners();
        return _isAvailable;
      }
    } catch (e) {
      debugPrint('Availability check error: $e');
    }

    return false;
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
    if (!_isAvailable) {
      await _initializeSpeech();
      if (!_isAvailable) {
        debugPrint('Speech recognition not available');
        return null;
      }
    }

    if (prompt != null) {
      await speak(prompt);
      // Wait for TTS to finish
      while (_isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _lastWords = '';
    final completer = Completer<String?>();

    // Start listening with better error handling
    try {
      await startListening(
        timeout: timeout,
        pauseFor: const Duration(
          seconds: 2,
        ), // Reduced pause for better responsiveness
      );

      // Set up timeout handler
      Timer(timeout, () {
        if (!completer.isCompleted) {
          stopListening();
          final result = _lastWords.trim();
          debugPrint('Speech timeout. Last words: "$result"');
          completer.complete(result.isEmpty ? null : result);
        }
      });

      // Monitor speech recognition status
      late StreamSubscription subscription;
      subscription = Stream.periodic(const Duration(milliseconds: 200)).listen((
        _,
      ) {
        if (!_isListening && !completer.isCompleted) {
          subscription.cancel();
          final result = _lastWords.trim();
          debugPrint('Speech recognition stopped. Final result: "$result"');
          completer.complete(result.isEmpty ? null : result);
        }
      });

      final result = await completer.future;
      subscription.cancel();
      return result;
    } catch (e) {
      debugPrint('Speech recognition error: $e');
      if (!completer.isCompleted) {
        completer.complete(null);
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

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
