# Synapse App - Android Permission & Manifest Debugging Guide

## Common Permission Errors and Solutions

---

### 1. `POST_NOTIFICATIONS` Permission Denied (Android 13+)

**Error:**
```
Permission denied: android.permission.POST_NOTIFICATIONS
```

**Cause:** Android 13 (API 33+) requires explicit runtime permission for posting notifications. The permission must be requested at runtime, not just declared in the manifest.

**Solution:**
```xml
<!-- In AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

```dart
// In Dart code (already implemented in NotificationMediatorService)
final status = await Permission.notification.request();
if (!status.isGranted) {
  // Show rationale to user
}
```

**Verification:**
```bash
adb shell dumpsys notification | grep -i "granted"
```

---

### 2. `ACCESS_NOTIFICATION_POLICY` (DND Access) Not Granted

**Error:**
```
SecurityException: Notification policy access denied
```

**Cause:** Do Not Disturb access is a **special access permission** that cannot be granted via runtime permission dialogs. Users must manually enable it in system settings.

**Solution:**
Direct users to the correct settings screen:
```dart
import 'package:permission_handler/permission_handler.dart';

// Open system DND settings
await openAppSettings();
// User must navigate to: Settings > Sound > Do Not Disturb > Special access
```

**Verification:**
```bash
adb shell cmd notification is_dnd_enabled
```

---

### 3. Health Permissions Not Showing on Android

**Error:**
```
Health permission request returned false
```

**Cause:** The `health` package on Android requires **Health Connect** to be installed and configured. On Android 14+, Health Connect is built-in; on older versions, it must be installed from the Play Store.

**Solution:**
1. Ensure `minSdkVersion` is **26** or higher in `android/app/build.gradle`:
   ```gradle
   android {
       defaultConfig {
           minSdkVersion 26
       }
   }
   ```

2. Add Health Connect permissions to `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.health.READ_HEART_RATE" />
   <uses-permission android:name="android.permission.health.READ_STEPS" />
   <uses-permission android:name="android.permission.health.READ_SLEEP" />
   ```

3. Ensure the `<queries>` block is present for Android 11+ package visibility:
   ```xml
   <queries>
       <intent>
           <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
       </intent>
   </queries>
   ```

**Verification:**
```bash
adb shell pm list packages | grep health
```

---

### 4. `ACTIVITY_RECOGNITION` Permission Denied

**Error:**
```
Permission denied: android.permission.ACTIVITY_RECOGNITION
```

**Cause:** Required for step count and activity data. Must be requested at runtime on Android 10+.

**Solution:**
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

Request at runtime:
```dart
await Permission.activityRecognition.request();
```

---

### 5. Foreground Service Notification Not Showing

**Error:**
```
ForegroundServiceStartNotAllowedException
```

**Cause:** Android 12+ restricts foreground service starts from the background.

**Solution:**
1. Add the correct foreground service type:
   ```xml
   <service
       android:name="com.dexterous.flutterlocalnotifications.ForegroundService"
       android:foregroundServiceType="specialUse">
       <property
           android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
           android:value="Focus Shield notification mediation" />
   </service>
   ```

2. Ensure the service is started from an active activity context, not from a background receiver.

---

### 6. `RECEIVE_BOOT_COMPLETED` Not Working

**Error:** Scheduled notifications disappear after device reboot.

**Solution:**
Ensure both the permission and receiver are declared:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

**Note:** On some OEM skins (Xiaomi, Huawei, Samsung), you must also whitelist the app in the device's auto-start manager.

---

### 7. `BODY_SENSORS` Permission Crash

**Error:**
```
SecurityException: BODY_SENSORS requires runtime permission
```

**Cause:** Heart rate and other body sensor data require explicit runtime permission.

**Solution:**
```xml
<uses-permission android:name="android.permission.BODY_SENSORS" />
```

Request at runtime before accessing health data:
```dart
await Permission.sensors.request();
```

---

### 8. Manifest Merge Conflicts

**Error:**
```
Manifest merger failed : uses-permission#android.permission.XXX was tagged at AndroidManifest.xml
```

**Cause:** Multiple dependencies declare the same permission with conflicting attributes.

**Solution:**
Use `tools:node="replace"` or `tools:node="merge"` to resolve conflicts:
```xml
<uses-permission
    android:name="android.permission.FOREGROUND_SERVICE"
    tools:node="replace" />
```

Add the tools namespace to the manifest tag:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.synapse.app">
```

---

## Quick Diagnostic Commands

```bash
# Check all granted permissions for the app
adb shell dumpsys package com.synapse.app | grep "granted=true"

# Check if Health Connect is installed
adb shell pm list packages | grep health

# Check notification policy access
adb shell cmd notification is_dnd_enabled

# View manifest merge report
./gradlew :app:processDebugManifest --info

# Check foreground service status
adb shell dumpsys activity services com.synapse.app
```

---

## Permission Checklist

| Permission | Type | Required For | Android Version |
|---|---|---|---|
| `POST_NOTIFICATIONS` | Runtime | Local notifications | 13+ |
| `ACCESS_NOTIFICATION_POLICY` | Special | DND control | All |
| `ACTIVITY_RECOGNITION` | Runtime | Step/activity data | 10+ |
| `BODY_SENSORS` | Runtime | Heart rate data | All |
| `FOREGROUND_SERVICE` | Normal | Persistent shield notification | All |
| `RECEIVE_BOOT_COMPLETED` | Normal | Notification persistence after reboot | All |
| `health.READ_HEART_RATE` | Runtime | Health Connect heart rate | 14+ |
| `health.READ_SLEEP` | Runtime | Health Connect sleep data | 14+ |
| `health.READ_STEPS` | Runtime | Health Connect step count | 14+ |
