# Speech Recognition Debugging Guide

## 🔧 Issues Identified and Fixed

### **Problem Analysis from Logs:**

```
I/flutter ( 2475): Starting speech recognition...
D/SpeechToTextPlugin( 2475): Start listening
D/SpeechToTextPlugin( 2475): setupRecognizerIntent
D/SpeechToTextPlugin( 2475): Notify status:listening
I/flutter ( 2475): Speech Status: listening
D/SpeechToTextPlugin( 2475): Start listening done
D/SpeechToTextPlugin( 2475): rmsDB -2.0 / 10.0
I/flutter ( 2475): Speech recognition stopped. Final result: ""
I/flutter ( 2475): listenForPhrase completed with result: "null"
```

### **Root Causes:**

1. **Immediate stopping**: Speech recognition starts but stops immediately
2. **No speech detected**: RMS level shows sound but no words recognized
3. **Configuration issues**: Missing optimal speech recognition parameters

## ✅ **FIXES IMPLEMENTED**

### **1. Enhanced Speech Configuration**

```dart
await _speech.listen(
  onResult: (val) {
    debugPrint('Speech result: "${val.recognizedWords}" (confidence: ${val.confidence})');
    _lastWords = val.recognizedWords;
    _confidence = val.confidence;
    notifyListeners();
  },
  listenFor: timeout, // Full timeout duration
  pauseFor: const Duration(seconds: 2), // Reduced from 3 seconds
  localeId: _currentLocaleId,
  partialResults: true, // ✅ Enable partial results for better feedback
  onSoundLevelChange: (level) {
    debugPrint('Sound level: $level'); // ✅ Better debugging
  },
  cancelOnError: false, // ✅ Don't cancel on minor errors
  listenMode: stt.ListenMode.confirmation, // ✅ Use confirmation mode
);
```

### **2. Improved Initialization**

```dart
_isAvailable = await _speech.initialize(
  onStatus: (val) {
    debugPrint('Speech Status: $val');
    if (val == 'done' || val == 'notListening') {
      _isListening = false;
      notifyListeners();
    } else if (val == 'listening') {
      _isListening = true; // ✅ Track listening state properly
      notifyListeners();
    }
  },
  onError: (val) {
    debugPrint('Speech Error: ${val.errorMsg}');
    _isListening = false;
    notifyListeners();
  },
  debugLogging: true,
  finalTimeout: const Duration(seconds: 3), // ✅ Add final timeout
);
```

### **3. Better Error Handling**

- ✅ Added comprehensive status monitoring
- ✅ Improved timeout handling
- ✅ Better completion detection
- ✅ Enhanced debug logging

### **4. Debug Tools Added**

- ✅ `testBasicSpeech()` method for testing
- ✅ Debug menu option in AI chat
- ✅ Enhanced logging throughout the pipeline

## 🧪 **TESTING STEPS**

### **1. Install Updated App**

```bash
cd /home/s010p/Taskoro/taskoro
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### **2. Test Basic Speech Recognition**

1. Open Taskoro app
2. Navigate to AI Chat
3. Tap the three-dot menu (⋮) in the top right
4. Select "Debug Speech"
5. Watch the console logs for detailed output

### **3. Test Voice Input in Chat**

1. In AI Chat, tap the microphone icon (🎤)
2. Grant microphone permission if prompted
3. Speak clearly when the voice dialog appears
4. Look for these improved log messages:

   ```
   I/flutter: Starting speech recognition...
   I/flutter: Speech result: "your words here" (confidence: 0.95)
   I/flutter: Speech recognition stopped. Final result: "your words here"
   ```

### **4. Monitor Key Improvements**

- **Partial Results**: Should see speech text appearing as you speak
- **Better Timeouts**: Won't stop immediately
- **Sound Level**: Should show microphone is detecting sound
- **Confidence Tracking**: Better result quality assessment

## 📱 **Debug Commands**

### **Monitor Speech Logs**

```bash
# Watch all speech-related logs
adb logcat | grep -i "speech\|microphone\|listening"

# Watch Flutter debug prints
adb logcat | grep "I/flutter"

# Watch speech plugin specifically
adb logcat | grep "SpeechToTextPlugin"
```

### **Check Permissions**

```bash
# Check app permissions
adb shell dumpsys package com.taskoro.taskoro | grep permission

# Check microphone usage
adb logcat | grep -i "microphone"
```

## 🔍 **Expected Log Output (Fixed)**

### **Successful Speech Recognition:**

```
I/flutter: === TESTING BASIC SPEECH RECOGNITION ===
I/flutter: 1. Checking availability...
I/flutter: Current microphone permission status: PermissionStatus.granted
I/flutter: Available: true
I/flutter: 2. Checking permission...
I/flutter: Permission: PermissionStatus.granted
I/flutter: 3. Starting basic listen test...
I/flutter: Configuring speech listener...
I/flutter: Speech listener started successfully
I/flutter: Listen started, waiting 6 seconds...
I/flutter: Speech result: "hello world" (confidence: 0.95)
I/flutter: Final result: "hello world"
I/flutter: === BASIC SPEECH TEST COMPLETE ===
```

### **Voice Input in Chat:**

```
I/flutter: Starting listenForPhrase with timeout: 30s
I/flutter: Starting speech recognition...
I/flutter: Configuring speech listener...
I/flutter: Speech listener started successfully
I/flutter: Sound level: 2.5
I/flutter: Speech result: "create a task" (confidence: 0.89)
I/flutter: Speech result: "create a task to call" (confidence: 0.92)
I/flutter: Speech result: "create a task to call doctor" (confidence: 0.94)
I/flutter: Speech recognition stopped. Final result: "create a task to call doctor"
I/flutter: listenForPhrase completed with result: "create a task to call doctor"
```

## ⚠️ **Troubleshooting**

### **Still Getting Empty Results?**

1. **Environment Check**:
   - Ensure quiet environment
   - Test with headphones/microphone
   - Check device volume levels

2. **Permission Check**:
   - Go to Settings → Apps → Taskoro → Permissions
   - Ensure Microphone permission is granted
   - Try revoking and re-granting permission

3. **Device Compatibility**:
   - Test on different Android devices
   - Some emulators don't support speech recognition
   - Physical device testing recommended

### **Speech Stops Immediately?**

1. Check the enhanced logs for specific error messages
2. Verify `partialResults: true` is working
3. Monitor sound level changes in logs
4. Test the `testBasicSpeech()` method first

### **Low Confidence Scores?**

1. Speak more clearly and slowly
2. Use shorter phrases initially
3. Test in quieter environment
4. Check if correct locale is being used

## 🎯 **Next Steps**

1. **Test the enhanced speech recognition**
2. **Monitor debug logs for improvements**
3. **Use the debug menu for quick testing**
4. **Report any remaining issues with full log output**

The speech recognition should now:

- ✅ Not stop immediately
- ✅ Show partial results as you speak
- ✅ Handle timeouts properly
- ✅ Provide better error feedback
- ✅ Work more reliably overall

## 📋 **Files Modified**

```
✅ /lib/services/speech_service.dart - Enhanced speech configuration and error handling
✅ /lib/widgets/ai_chat_widget.dart - Added debug menu and improved UI feedback
```

The speech recognition functionality has been significantly improved with better configuration, error handling, and debugging capabilities.
