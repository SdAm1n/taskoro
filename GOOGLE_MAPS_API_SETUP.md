# Google Maps API Setup Guide

## Overview

To use the Google Maps functionality in the Taskoro app, you need to set up Google Maps API keys for both Android and iOS platforms.

## Prerequisites

- Google Cloud Console account
- Google Maps SDK enabled

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable billing for the project

## Step 2: Enable Required APIs

Enable the following APIs in Google Cloud Console:

- Maps SDK for Android
- Maps SDK for iOS
- Geocoding API
- Places API (optional, for enhanced search)

## Step 3: Create API Keys

### For Android

1. Go to "Credentials" in Google Cloud Console
2. Click "Create Credentials" → "API Key"
3. Restrict the key to Android apps
4. Add your app's package name and SHA-1 fingerprint
5. Copy the API key

### For iOS

1. Create another API key in Google Cloud Console
2. Restrict the key to iOS apps
3. Add your app's bundle identifier
4. Copy the API key

## Step 4: Configure API Keys in App

### Android Configuration

1. Open `/android/app/src/main/AndroidManifest.xml`
2. Add the following inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY_HERE" />
```

### iOS Configuration

1. Open `/ios/Runner/AppDelegate.swift`
2. Add the following import at the top:

```swift
import GoogleMaps
```

3. Add the following in the `application` method:

```swift
GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
```

## Step 5: Get SHA-1 Fingerprint (Android)

### For Debug Build

```bash
cd /home/s010p/Taskoro/taskoro/android
./gradlew signingReport
```

### For Release Build

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Step 6: Test the Configuration

1. Build and run the app
2. Navigate to Add/Edit Task screen
3. Tap "Add Location"
4. Verify that the map loads correctly

## Current Status

- ✅ Location permissions configured
- ✅ Google Maps packages added
- ⏳ API keys need to be configured
- ⏳ Testing required

## Notes

- The app will work in development mode but may show "For development purposes only" watermark
- For production, proper API keys with billing enabled are required
- Consider implementing error handling for cases when location services are disabled
- The current implementation defaults to San Francisco when no location is available

## Security Best Practices

- Restrict API keys to specific apps and IP addresses
- Enable only the required APIs
- Monitor API usage in Google Cloud Console
- Consider using environment variables for API keys in CI/CD pipelines

## Testing Without API Keys

The app will still function with basic location features, but the map will show a development watermark and may have limited functionality.
