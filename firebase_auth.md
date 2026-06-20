# Firebase Setup Guide for Budget Tracker

This document walks you through configuring **Firebase** for the **Budget Tracker** Flutter app, covering authentication, Cloud Firestore, and Firebase Cloud Messaging (FCM).

---

## 1️⃣ Prerequisites
- A Google account.
- Flutter SDK (stable) installed.
- Android Studio / Xcode for platform builds.
- Existing Flutter project at `d:/NEW/2026 app/budget_tracker`.

---

## 2️⃣ Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/) and click **Add project**.
2. Give it a name (e.g., `budget‑tracker`).
3. Disable Google Analytics for now (or enable if you prefer) and finish creation.

---

## 3️⃣ Register Android & iOS Apps
### Android
1. In the Firebase console, click **Add app** → **Android**.
2. Enter your Android package name – you can find it in `android/app/src/main/AndroidManifest.xml` under `package="..."`.
3. (Optional) Provide a nickname and SHA‑1 certificate.
4. Download the generated `google‑services.json`.
5. Place it in `android/app/` folder.
6. Add the Google Services plugin:
   ```gradle
   // android/build.gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```
   ```gradle
   // android/app/build.gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### iOS
1. Click **Add app** → **iOS**.
2. Enter the iOS bundle ID (found in Xcode under *General → Bundle Identifier*).
3. Download `GoogleService-Info.plist`.
4. Open the `ios/Runner` Xcode project and drag the file into the Runner target.
5. Ensure `ios/Runner/Info.plist` contains:
   ```xml
   <key>FirebaseAppDelegateProxyEnabled</key>
   <false/>
   ```
   (required when using custom notification handling).

---

## 4️⃣ Add Flutter Packages
Add the following dependencies to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.11.0
  cloud_firestore: ^4.14.0
  firebase_messaging: ^14.7.0
```
Run `flutter pub get`.

---

## 5️⃣ Initialize Firebase in Flutter
Create `lib/firebase_options.dart` using the FlutterFire CLI (recommended):
```bash
flutterfire configure
```
This generates the options file and updates native code.

In `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

---

## 6️⃣ Set Up Firebase Authentication
1. In the Firebase console, go to **Authentication → Sign‑in method**.
2. Enable **Email/Password** (or any other method you need).
3. (Optional) Enable **Google** sign‑in for a smoother experience.

### Sample Auth Service (`lib/services/auth_service.dart`)
```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();
}
```
Integrate this service into your existing auth flow.

---

## 7️⃣ Configure Cloud Firestore
1. In Firebase console, navigate to **Firestore Database** → **Create database**.
2. Choose **Start in test mode** (or configure proper security rules later).
3. Set up a collection structure, for example:
   - `users/{uid}` – user profile (name, email, avatar).
   - `transactions/{txId}` – transaction data (including split fields).
   - `settle_requests/{reqId}` – settlement request objects.

### Example Firestore Write (split transaction)
```dart
final db = FirebaseFirestore.instance;
await db.collection('transactions').add({
  'title': title,
  'amount': amount,
  'date': Timestamp.now(),
  'categoryId': catId,
  'type': 'expense',
  'isSplit': true,
  'splitWith': otherUserId,
  'splitAmount': amount / 2,
  'createdBy': FirebaseAuth.instance.currentUser!.uid,
});
```

---

## 8️⃣ Enable Firebase Cloud Messaging (FCM)
1. In console, go to **Cloud Messaging** and enable it.
2. For Android, make sure `android/app/src/main/AndroidManifest.xml` contains:
   ```xml
   <service android:name="io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService" android:exported="true" />
   ```
3. For iOS, enable **Push Notifications** and **Background Modes** → **Remote notifications** in Xcode.
4. Add the following initialization (usually in `main.dart` after Firebase.initializeApp):
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;
await messaging.requestPermission();
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // handle foreground notification
});
```
Use this channel to send settlement request/approval notifications.

---

## 9️⃣ Security Rules (Production)
When you move out of test mode, replace the default rules with something like:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /transactions/{txId} {
      allow read, write: if request.auth.uid != null;
    }
    match /settle_requests/{reqId} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```

---

## 📚 Reference
- [FlutterFire documentation](https://firebase.flutter.dev/)
- [Firebase console](https://console.firebase.google.com/)
- [FCM integration guide for Flutter](https://firebase.flutter.dev/docs/messaging/overview)

---

**You are now ready to integrate Firebase into the Budget Tracker app!**
