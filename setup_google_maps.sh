#!/bin/bash

# Google Maps API Key Setup Script for Taskoro
echo "=== Google Maps API Key Setup ==="
echo ""
echo "This script will help you configure your Google Maps API key."
echo ""
echo "Prerequisites:"
echo "1. You should have created a Google Maps API key in Google Cloud Console"
echo "2. The API key should be restricted to Android apps"
echo "3. Package name: com.taskoro.taskoro"
echo "4. SHA-1 fingerprint: 5B:53:90:DF:35:63:7C:A5:29:9C:BE:58:EF:A6:30:46:22:41:06:DC"
echo ""

# Check if API key is provided as argument
if [ "$1" ]; then
    API_KEY="$1"
else
    echo "Please enter your Google Maps API key:"
    read -r API_KEY
fi

if [ -z "$API_KEY" ]; then
    echo "Error: No API key provided"
    exit 1
fi

# Backup the current manifest
cp android/app/src/main/AndroidManifest.xml android/app/src/main/AndroidManifest.xml.backup
echo "✅ Backed up AndroidManifest.xml"

# Replace the placeholder API key
sed -i "s/YOUR_GOOGLE_MAPS_API_KEY_HERE/$API_KEY/g" android/app/src/main/AndroidManifest.xml

echo "✅ Updated AndroidManifest.xml with your API key"
echo ""
echo "Next steps:"
echo "1. Build and run your app: flutter run"
echo "2. Test the location picker functionality"
echo "3. Check that the map loads properly without 'For development purposes only' watermark"
echo ""
echo "If you need to revert changes, restore from: android/app/src/main/AndroidManifest.xml.backup"
