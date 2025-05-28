#!/bin/bash

# Test Google Maps API Setup Script
echo "=== Testing Google Maps Integration ==="
echo ""

# Check if API key is configured
if grep -q "YOUR_GOOGLE_MAPS_API_KEY_HERE" android/app/src/main/AndroidManifest.xml; then
    echo "❌ Google Maps API Key NOT configured"
    echo "   Found placeholder: YOUR_GOOGLE_MAPS_API_KEY_HERE"
    echo ""
    echo "📋 To fix this:"
    echo "1. Get your API key from Google Cloud Console"
    echo "2. Run: ./setup_google_maps.sh YOUR_API_KEY"
    echo "3. Or manually replace YOUR_GOOGLE_MAPS_API_KEY_HERE in AndroidManifest.xml"
else
    echo "✅ Google Maps API Key configured"
fi

echo ""
echo "📱 Current Test Steps:"
echo "1. Open the app (currently running on RMX2103)"
echo "2. Navigate to Add Task screen (+ button)"
echo "3. Tap 'Add Location' button"
echo "4. Check location picker modal behavior:"
echo ""
echo "   🔴 WITHOUT API Key (current state):"
echo "   - Modal opens but map shows 'For development purposes only'"
echo "   - Location selection may not work properly"
echo "   - Fallback UI with 'Get Current Location' button"
echo ""
echo "   🟢 WITH API Key (after setup):"
echo "   - Modal opens with full Google Maps"
echo "   - Tap anywhere on map to select location"
echo "   - 'Select Location' button works properly"
echo "   - Returns to task creation with selected location"
echo ""

# Check if the app is currently running
if pgrep -f "flutter run" > /dev/null; then
    echo "✅ Flutter app is currently running"
    echo "📲 Device: RMX2103"
    echo ""
    echo "🧪 Test the location picker now:"
    echo "   1. Tap the + (Add Task) button in the app"
    echo "   2. Tap 'Add Location'"
    echo "   3. Observe the current behavior"
else
    echo "❌ Flutter app is not running"
    echo "   Run: flutter run"
fi

echo ""
echo "📊 Your App Configuration:"
echo "   Package: com.taskoro.taskoro"
echo "   SHA-1: 5B:53:90:DF:35:63:7C:A5:29:9C:BE:58:EF:A6:30:46:22:41:06:DC"
echo ""
echo "🔗 Google Cloud Console Link:"
echo "   https://console.cloud.google.com/apis/credentials"
