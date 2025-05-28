#!/bin/bash

# Voice Feature Testing Script for Taskoro
echo "🎙️ Taskoro Voice Feature Testing Guide"
echo "========================================"
echo ""

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "⚠️  ADB not found. Please install Android SDK or connect via USB debugging."
fi

echo "📱 Building debug APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    
    echo "📋 Manual Testing Steps:"
    echo "1. Install the APK: adb install build/app/outputs/flutter-apk/app-debug.apk"
    echo "2. Open the Taskoro app"
    echo "3. Navigate to AI Chat (usually via a chat icon)"
    echo "4. Tap the microphone icon in the app bar"
    echo "5. Grant microphone permission when prompted"
    echo "6. Speak clearly when the voice dialog appears"
    echo "7. Verify speech is converted to text and sent to AI"
    echo ""
    
    echo "🔍 Debug Commands:"
    echo "# Monitor microphone permission requests:"
    echo "adb logcat | grep -i 'permission'"
    echo ""
    echo "# Monitor speech service logs:"
    echo "adb logcat | grep -i 'speech'"
    echo ""
    echo "# Monitor microphone usage:"
    echo "adb logcat | grep -i 'microphone'"
    echo ""
    
    echo "🐛 Troubleshooting:"
    echo "- If permission dialog doesn't appear: Check app settings manually"
    echo "- If speech isn't detected: Ensure quiet environment, speak clearly"
    echo "- If TTS doesn't work: Check device audio settings"
    echo "- For detailed testing: Use the Speech Debug Widget in the app"
    echo ""
    
    echo "✅ Voice feature is ready for testing!"
else
    echo "❌ Build failed. Please check the error messages above."
    exit 1
fi
