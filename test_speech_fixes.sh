#!/bin/bash

# Speech Recognition Fix Testing Script
echo "🎙️ Speech Recognition Fix Testing"
echo "================================="
echo ""

# Check if app is installed
echo "📱 Checking if Taskoro app is installed..."
if adb shell pm list packages | grep -q "com.taskoro.taskoro"; then
    echo "✅ Taskoro app is installed"
else
    echo "❌ Taskoro app not found. Installing..."
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        adb install build/app/outputs/flutter-apk/app-debug.apk
        echo "✅ App installed"
    else
        echo "❌ APK not found. Please build first with: flutter build apk --debug"
        exit 1
    fi
fi

echo ""
echo "🔧 Testing Steps:"
echo "1. Open the Taskoro app"
echo "2. Navigate to AI Chat"
echo "3. Test the debug speech option first:"
echo "   - Tap ⋮ menu → Debug Speech"
echo "   - Watch for console logs"
echo "4. Test voice input:"
echo "   - Tap 🎤 microphone icon"
echo "   - Grant permission if prompted"
echo "   - Speak clearly"
echo ""

echo "🔍 Monitoring speech logs..."
echo "Press Ctrl+C to stop monitoring"
echo ""

# Monitor speech-related logs
adb logcat -s flutter | grep -E "(Speech|speech|listening|microphone|Sound level|confidence)" &
LOGCAT_PID=$!

# Also show SpeechToTextPlugin logs
adb logcat -s SpeechToTextPlugin &
PLUGIN_PID=$!

# Wait for user to stop
trap 'kill $LOGCAT_PID $PLUGIN_PID 2>/dev/null; echo ""; echo "🏁 Monitoring stopped"; exit 0' INT

wait
