// AI Configuration for Taskoro
class AIConfig {
  // Gemini API Configuration
  static const String geminiApiKey = 'AIzaSyDd8KLWSo1b73s76hK3hMIdcvclF32dYrc';
  static const String geminiModel = 'gemini-pro';

  // Ollama Local AI Configuration (fallback)
  static const String ollamaBaseUrl = 'http://localhost:11434';
  static const String ollamaModel = 'llama2';

  // AI Features Configuration
  static const bool enableVoiceInput = true;
  static const bool enableTaskSuggestions = true;
  static const bool enableAIChat = true;
  static const bool enableDescriptionGeneration = true;

  // Speech Recognition Configuration
  static const Duration speechTimeout = Duration(seconds: 45);
  static const Duration listeningTimeout = Duration(seconds: 30);

  // Task Suggestion Configuration
  static const int maxSuggestions = 3;
  static const Duration suggestionRefreshInterval = Duration(hours: 1);

  // Check if AI features are properly configured
  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY';
  static bool get isAIEnabled => isGeminiConfigured || isOllamaAvailable;

  // This will be checked at runtime
  static bool isOllamaAvailable = false;

  // Get effective AI backend
  static String get activeBackend {
    if (isGeminiConfigured) return 'Gemini';
    if (isOllamaAvailable) return 'Ollama';
    return 'Rule-based';
  }
}
