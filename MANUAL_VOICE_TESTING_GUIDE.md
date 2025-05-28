# Manual Voice Feature Testing Guide

## 🎯 **TESTING OBJECTIVE**

Validate that the voice feature in Taskoro app now works correctly after implementing comprehensive fixes for speech recognition issues.

## 📱 **PRE-TESTING SETUP**

### **Step 1: Install Updated App**

The app has been installed on your Android device (RMX2103). If you need to reinstall:

```bash
cd /home/s010p/Taskoro/taskoro
flutter run -d f50278c0
```

### **Step 2: Verify Permissions**

1. Open **Settings** → **Apps** → **Taskoro**
2. Go to **Permissions**
3. Ensure **Microphone** permission is **GRANTED**
4. If not granted, enable it manually

## 🧪 **TEST SCENARIOS**

### **Test 1: Basic Voice Input Functionality**

**Steps:**

1. Open Taskoro app
2. Navigate to the AI Assistant (chat icon)
3. Tap the **microphone button** (🎤) in the chat input
4. **Expected**: Voice input dialog should appear
5. **Expected**: Should show "Listening..." status
6. Say clearly: **"Create a task to buy groceries"**
7. **Expected**: Should capture your speech and process it

**✅ Success Criteria:**

- Voice dialog opens without error
- Shows "Listening..." status
- Captures and displays your speech
- Creates AI response for task creation

**❌ Failure Indicators:**

- "Couldn't hear anything" appears immediately
- Dialog closes without capturing speech
- Shows permission errors

### **Test 2: Debug Menu Testing**

**Steps:**

1. In AI chat, tap the **⋮** (three dots) menu
2. Select **"Debug Speech"**
3. This opens a comprehensive debug panel
4. Tap **"Test Basic Speech"**
5. Speak when prompted

**✅ Success Criteria:**

- Debug menu appears
- Shows detailed speech status information
- Displays permission status as "granted"
- Shows available speech locales
- Captures test speech successfully

### **Test 3: Permission Handling**

**Steps:**

1. Go to device **Settings** → **Apps** → **Taskoro** → **Permissions**
2. **Disable** microphone permission
3. Return to Taskoro and try voice input
4. **Expected**: Should show clear permission error message
5. Should guide you to enable permissions
6. Re-enable microphone permission and test again

**✅ Success Criteria:**

- Shows clear permission denied message
- Provides guidance to fix permissions
- Works correctly after re-enabling permissions

## 📊 **MONITORING AND LOGGING**

### **Log Monitoring Script**

If you want to monitor logs while testing:

```bash
cd /home/s010p/Taskoro/taskoro
./test_speech_fixes.sh
```

This will show real-time speech recognition logs.

### **Key Log Messages to Look For**

**✅ Good Signs:**

```
I/flutter: Speech Status: listening
I/flutter: Speech result: "your spoken text" (confidence: 0.95)
I/flutter: Sound level: 5.2
I/flutter: Speech recognition completed successfully
```

**❌ Problem Signs:**

```
I/flutter: Speech recognition stopped. Final result: ""
I/flutter: Microphone permission not granted
I/flutter: Speech service not available
```

## 🔧 **TROUBLESHOOTING**

### **Issue: "Couldn't hear anything instantly"**

**Possible Causes:**

- Microphone permission not granted
- Hardware microphone issue
- Background noise interference

**Solutions:**

1. Check microphone permissions in device settings
2. Test in a quiet environment
3. Ensure no other apps are using microphone
4. Restart the app

### **Issue: Speech starts but stops immediately**

**Fixed in this update!** Previously this was caused by:

- Poor speech recognition configuration
- Missing `partialResults: true` parameter
- Incorrect timeout settings

**New Configuration Applied:**

- `partialResults: true` for real-time feedback
- `cancelOnError: false` to prevent premature stopping
- `listenMode: ListenMode.confirmation` for better detection
- Reduced `pauseFor` timeout from 3s to 2s

### **Issue: BuildContext errors in logs**

**Fixed in this update!** All BuildContext across async gaps have been resolved.

## 📋 **TEST RESULTS CHECKLIST**

**Basic Functionality:**

- [ ] Voice button opens dialog
- [ ] Shows "Listening..." status
- [ ] Captures spoken words correctly
- [ ] Processes speech into AI task creation
- [ ] No immediate "couldn't hear anything" errors

**Permission Handling:**

- [ ] Works when permissions granted
- [ ] Shows clear error when permissions denied
- [ ] Guides user to fix permission issues

**Debug Tools:**

- [ ] Debug menu accessible via ⋮ button
- [ ] Debug panel shows speech status
- [ ] Test functions work correctly

**Error Handling:**

- [ ] No BuildContext errors in logs
- [ ] Proper timeout handling
- [ ] Clear error messages for users

## 🎉 **EXPECTED IMPROVEMENTS**

After implementing the fixes, you should experience:

1. **Reliable Voice Input**: No more instant "couldn't hear anything" errors
2. **Better Speech Detection**: Improved recognition accuracy and responsiveness
3. **Clear Error Messages**: When issues occur, you'll get helpful guidance
4. **Debug Tools**: Built-in troubleshooting capabilities
5. **Stable Performance**: No more crashes or BuildContext errors

## 📞 **REPORTING RESULTS**

After testing, please report:

1. **Which tests passed/failed**
2. **Any error messages seen**
3. **Speech recognition accuracy**
4. **Overall user experience improvement**

The comprehensive fixes should resolve the original issues where:

- Voice input was saying "couldn't hear anything instantly"
- Debug panel showed "microphone permission not granted"
- Speech recognition was starting but immediately stopping

## 🔗 **Additional Resources**

- **Full Fix Documentation**: `VOICE_FEATURE_FIXES_COMPLETE.md`
- **Technical Debug Guide**: `SPEECH_RECOGNITION_DEBUG_GUIDE.md`
- **Resolution Summary**: `SPEECH_RECOGNITION_RESOLUTION_COMPLETE.md`
