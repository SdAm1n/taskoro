# Firebase Client Error Fix - "Requests from this android client application <empty> are blocked"

## Issue Description

The Android app is receiving the error: "Requests from this android client application <empty> are blocked" when trying to use AI features that depend on Google APIs.

## Root Cause Analysis

This error typically occurs when:

1. SHA-1 fingerprint mismatch between local keystore and Firebase project
2. API key restrictions blocking Android client requests  
3. Firebase project configuration issues
4. Missing or incorrect OAuth 2.0 client configuration

## Current Configuration Status

### ✅ Package Name: Correct

- AndroidManifest.xml: `com.taskoro.taskoro`
- build.gradle.kts: `com.taskoro.taskoro`
- google-services.json: `com.taskoro.taskoro`

### ✅ SHA-1 Fingerprint: Correct

- Local keystore: `5B:53:90:DF:35:63:7C:A5:29:9C:BE:58:EF:A6:30:46:22:41:06:DC`
- Firebase config: `5b5390df35637ca5299cbe58efa63046224106dc` (matches)

## **IMPORTANT: Multiple API Keys Detected**

Your app is using **two different Gemini API keys**:

1. **Firebase/Google Cloud API Key**: `AIzaSyCHEZymBWlF2lTuAETWe5qZLVzJvt2K-ds` (from google-services.json)
2. **Separate Gemini API Key**: `AIzaSyAM6kjJ8A-kLipJq2EV2RSWqV6ohhLzkkA` (in ai_service.dart)
3. **Third Gemini API Key**: `AIzaSyDd8KLWSo1b73s76hK3hMIdcvclF32dYrc` (in ai_config.dart)

**You need to configure BOTH keys separately:**

### For the Firebase API Key (AIzaSyCHEZymBWlF2lTuAETWe5qZLVzJvt2K-ds)

- Configure in Google Cloud Console → APIs & Services → Credentials
- Restrict to Android apps with your package name and SHA-1
- Enable: **Firebase Authentication API**, **Cloud Firestore API**

### For the Gemini API Key (AIzaSyAM6kjJ8A-kLipJq2EV2RSWqV6ohhLzkkA)

- This should be configured separately in Google AI Studio or Google Cloud Console
- Enable: **Generative Language API**
- Can be restricted to your Android app or left unrestricted for testing

## Solution Steps

### Step 1: Verify Firebase Project Settings

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `taskoro-app`
3. Navigate to **Project Settings** → **General**
4. Under **Your apps**, find the Android app
5. Verify the package name is `com.taskoro.taskoro`

### Step 2: Check SHA-1 Fingerprints

1. In Firebase Console → **Project Settings** → **General**
2. Click on your Android app
3. Scroll to **SHA certificate fingerprints**
4. Ensure this SHA-1 is listed: `5B:53:90:DF:35:63:7C:A5:29:9C:BE:58:EF:A6:30:46:22:41:06:DC`
5. If not present, click **Add fingerprint** and add it

### Step 3: Configure Google Cloud API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `taskoro-app`
3. Navigate to **APIs & Services** → **Credentials**
4. Find your API key (likely `AIzaSyCHEZymBWlF2lTuAETWe5qZLVzJvt2K-ds`)
5. Click **Edit** on the API key
6. Under **Application restrictions**:
   - Select **Android apps**
   - Add package name: `com.taskoro.taskoro`
   - Add SHA-1: `5B:53:90:DF:35:63:7C:A5:29:9C:BE:58:EF:A6:30:46:22:41:06:DC`

### Step 4: Enable Required APIs

Ensure these APIs are enabled in Google Cloud Console:

- ✅ **Generative Language API** (this is the correct name for Gemini AI)
- ✅ **Firebase Authentication API**
- ✅ **Cloud Firestore API**
- ✅ **Maps SDK for Android** (if using location features)

**Note:** The APIs "Firebase ML API", "Cloud Speech-to-Text API", and "Android Device Verification API" are not needed for basic AI chat functionality.

## **FIXED: Gemini Model Name Issue**

**Problem**: The app was using the outdated model name `gemini-pro` which is no longer supported.

**Solution**: Updated to use `gemini-1.5-flash` which is the current supported model name.

**Files Updated**:

- `/lib/services/ai_service.dart` - Changed model from `gemini-pro` to `gemini-1.5-flash`
- `/lib/config/ai_config.dart` - Updated model configuration

### Step 5: OAuth 2.0 Client Configuration

1. In Google Cloud Console → **APIs & Services** → **Credentials**
2. Find your OAuth 2.0 client ID for Android
3. Verify these settings:
   - **Application type**: Android
   - **Package name**: `com.taskoro.taskoro`
   - **SHA-1**: `5B:53:90:DF:35:63:7C:A5:29:9C:BE:58:EF:A6:30:46:22:41:06:DC`

### Step 6: Download Updated Configuration

1. After making changes in Firebase Console
2. Download the updated `google-services.json`
3. Replace the file in `android/app/google-services.json`
4. Rebuild the app

## Quick Commands

### Get Current SHA-1 Fingerprint

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
```

### Clean and Rebuild App

```bash
cd /home/s010p/Taskoro/taskoro
flutter clean
flutter pub get
flutter run
```

## Verification Steps

1. Build and run the app
2. Try using AI chat feature
3. Check for specific error messages in logs
4. Test other Firebase features (authentication, Firestore)

## Common Additional Issues

### If Still Getting Errors

1. **API Key Quotas**: Check if you've exceeded free tier limits
2. **Billing**: Ensure billing is enabled for paid APIs
3. **Regional Restrictions**: Check if APIs are available in your region
4. **Network Issues**: Test on different networks/WiFi

### Debug Commands

```bash
# Check detailed logs
flutter run --verbose

# Check specific Firebase errors
adb logcat | grep -i firebase
adb logcat | grep -i "client application"
```

## Expected Result

After completing these steps:

- ✅ AI chat should work without "blocked" errors
- ✅ Firebase Authentication should function properly
- ✅ All Google API dependent features should work

## Notes

- Changes in Google Cloud Console may take a few minutes to propagate
- Always test after making configuration changes
- Keep backup of working `google-services.json` files
