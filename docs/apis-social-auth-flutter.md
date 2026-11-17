# HYKX Social Authentication Guide: Google & Apple Sign-In for Flutter

A complete, production-ready specification and implementation guide for Flutter developers integrating **Sign in with Google** and **Sign in with Apple** with the HYKX backend.

---

## 1. Overview & Authentication Architecture

HYKX uses a unified token-based authentication system. The mobile Flutter application handles native authentication sheets via Google and Apple SDKs, retrieves signed cryptographic tokens (`id_token` / `identity_token`), and sends them to the HYKX backend.

The backend verifies the token directly with Google or Apple, creates or links the user account, ensures default profiles and unit preferences are initialized, and returns standard JWT tokens (`access` and `refresh`).

```mermaid
sequenceDiagram
    autonumber
    actor User as User (Mobile Device)
    participant Flutter as Flutter App
    participant Provider as Google / Apple SDK
    participant Backend as HYKX Backend (Django API)

    User->>Flutter: Taps "Sign in with Google / Apple"
    Flutter->>Provider: Request Native Sign-In Sheet
    Provider->>User: Displays Native Account Sheet
    User->>Provider: Confirms Biometrics / Selection
    Provider-->>Flutter: Returns Tokens (id_token / identity_token, name, email)
    Flutter->>Backend: POST /api/auth/google/ or /api/auth/apple/
    Backend->>Provider: Cryptographically Verifies Token Signature & Expiry
    Provider-->>Backend: Token Valid (sub, email, email_verified)
    Backend->>Backend: Get or Create User & Generate JWT
    Backend-->>Flutter: 200 OK (access, refresh, user_id, username, role)
    Flutter->>Flutter: Securely Stores JWT Tokens in Keychain/Keystore
    Flutter-->>User: Navigates to Dashboard
```

---

## 2. API Endpoints Reference

### 2.1 Sign in with Google

- **Endpoint**: `POST {{baseurl}}/api/auth/google/`
- **Content-Type**: `application/json`
- **Authentication**: Public (No auth required)

#### Request Payload
The endpoint accepts `id_token` (recommended for Flutter), `access_token`, or `code`.

```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmODRh..."
}
```

*Alternative formats also supported:*
```json
// With access_token
{
  "access_token": "ya29.a0AfH6SMBx..."
}

// With authorization code
{
  "code": "4/0AeanS0..."
}
```

#### Demo Request (cURL)
```bash
curl -X POST "https://api.hykxapp.com/api/auth/google/" \
     -H "Content-Type: application/json" \
     -d '{
       "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmODRh..."
     }'
```

#### Response `200 OK`
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzI5MTY2ODAwLCJpYXQiOjE3MjkxNjMyMDAsImp0aSI6ImE2YTU5YjEyYmM0M2RmZTg4YjRlMGQ4YzZmM2NmZTIwIiwidXNlcl9pZCI6NDJ9.xxxxxxxxxxxxxxxxxxxxxx",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcyOTc2ODAwMCwiaWF0IjoxNzI5MTYzMjAwLCJqdGkiOiJmMzVjYWEyZTkyMWVhNjg0YmM4ZTI5ZGFmOGIwYTlkZSIsInVzZXJfaWQiOjQyfQ.xxxxxxxxxxxxxxxxxxxxxx",
  "username": "johndoe",
  "role": "user",
  "created": true,
  "user_id": 42,
  "email": "johndoe@gmail.com"
}
```

#### Error Responses
- **`400 Bad Request`**: Token invalid, expired, or missing:
  ```json
  {
    "detail": "Invalid Google ID token."
  }
  ```

---

### 2.2 Sign in with Apple

- **Endpoint**: `POST {{baseurl}}/api/auth/apple/`
- **Content-Type**: `application/json`
- **Authentication**: Public (No auth required)

#### Request Payload

| Field | Type | Required | Description |
|---|---|---|---|
| `identity_token` | `string` | **Yes** | Apple signed identity JWT (`credential.identityToken`) |
| `authorization_code` | `string` | No | Optional code for server-to-server token refresh |
| `full_name` | `string` | No | User's full name (sent on first sign-in) |
| `email` | `string` | No | User's email (sent on first sign-in) |

```json
{
  "identity_token": "eyJraWQiOiJBSURIUzEiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmh5a3hhcHAuaHlreCIsImV4cCI6MTcyOTIwMDAwMCwiaWF0IjoxNzI5MTYzMjAwLCJzdWIiOiIwMDEyMzQuYWJjZGVmZ2hpamtsbW5vcC5hcHBsZSIsImVtYWlsIjoidXNlckBwcml2YXRlcmVsYXkuYXBwbGVpZC5jb20iLCJlbWFpbF92ZXJpZmllZCI6InRydWUiLCJhdXRoX3RpbWUiOjE3MjkxNjMyMDB9.xxxxxxxxxxxxxxxxxxxxxx",
  "authorization_code": "c71a3982e0bf44588828945cf45924559.0.srrrx.xxxxxxxxxxxx",
  "full_name": "John Appleseed",
  "email": "user@privaterelay.appleid.com"
}
```

#### Demo Request (cURL)
```bash
curl -X POST "https://api.hykxapp.com/api/auth/apple/" \
     -H "Content-Type: application/json" \
     -d '{
       "identity_token": "eyJraWQiOiJBSURIUzEiLCJhbGciOiJSUzI1NiJ9...",
       "authorization_code": "c71a3982e0bf4...",
       "full_name": "John Appleseed",
       "email": "user@privaterelay.appleid.com"
     }'
```

#### Response `200 OK`
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzI5MTY2ODAwLCJpYXQiOjE3MjkxNjMyMDAsImp0aSI6ImIzYzc1YjEzYmM0M2RmZTg4YjRlMGQ4YzZmM2NmZTIwIiwidXNlcl9pZCI6NDN9.xxxxxxxxxxxxxxxxxxxxxx",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcyOTc2ODAwMCwiaWF0IjoxNzI5MTYzMjAwLCJqdGkiOiJmNDVjYWEyZTkyMWVhNjg0YmM4ZTI5ZGFmOGIwYTlkZSIsInVzZXJfaWQiOjQzfQ.xxxxxxxxxxxxxxxxxxxxxx",
  "username": "apple_001234",
  "role": "user",
  "created": true,
  "user_id": 43,
  "email": "user@privaterelay.appleid.com"
}
```

#### Error Responses
- **`400 Bad Request`**: Token expired, signature check failed, or invalid audience:
  ```json
  {
    "detail": "Invalid Apple identity token: Signature has expired"
  }
  ```

---

## 3. Flutter Configuration & Setup

### 3.1 Dependencies (`pubspec.yaml`)

Add these packages to your Flutter app:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Social Sign-In packages
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.4

  # Networking & Secure Storage
  http: ^1.2.2
  flutter_secure_storage: ^9.2.2
```

Run:
```bash
flutter pub get
```

---

### 3.2 Google Sign-In Setup

#### 1. Android Configuration
- In `android/app/build.gradle`:
  ```gradle
  defaultConfig {
      applicationId "com.hykx.app"
      minSdkVersion 21
      ...
  }
  ```
- Place `google-services.json` inside `android/app/`.
- Ensure your debug & release SHA-1 fingerprints are registered in Google Cloud Console under your Android OAuth 2.0 Client.
  - To generate SHA-1 on macOS / Linux:
    ```bash
    keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
    ```
  - To generate SHA-1 on Windows:
    ```cmd
    keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
    ```

#### 2. iOS Configuration
- In Google Cloud Console, create an **iOS OAuth Client ID** with Bundle ID `com.hykx.app`.
- In `ios/Runner/Info.plist`, add your `CFBundleURLTypes` with the **REVERSED_CLIENT_ID**:
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
      <dict>
          <key>CFBundleTypeRole</key>
          <string>Editor</string>
          <key>CFBundleURLSchemes</key>
          <array>
              <!-- Reversed client ID from GoogleService-Info.plist -->
              <string>com.googleusercontent.apps.80970139200-trnod70srm72omplmecl00ig6qnb8r1a</string>
          </array>
      </dict>
  </array>
  ```

---

### 3.3 Apple Sign-In Setup

#### 1. Apple Developer Portal
- Ensure your App ID `com.hykx.app` has the **Sign In with Apple** capability enabled.
- Create a **Key** for Sign In with Apple (Key ID: `D22C7B6QCK`) under Keys.

#### 2. Xcode Configuration
1. Open the `ios/` folder in Xcode.
2. Select your Runner target -> **Signing & Capabilities**.
3. Click `+ Capability` and select **Sign In with Apple**.
4. This adds `Runner.entitlements`:
   ```xml
   <key>com.apple.developer.applesignin</key>
   <array>
       <string>Default</string>
   </array>
   ```

---

## 4. Production Flutter Implementation (Dart Code)

Here is a complete, copy-pasteable implementation with token models, secure storage, and exception handling.

### 4.1 Auth Models (`lib/models/auth_response.dart`)

```dart
class AuthResponse {
  final String access;
  final String refresh;
  final String username;
  final String role;
  final bool created;
  final int userId;
  final String email;

  AuthResponse({
    required this.access,
    required this.refresh,
    required this.username,
    required this.role,
    required this.created,
    required this.userId,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      created: json['created'] as bool? ?? false,
      userId: json['user_id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      'username': username,
      'role': role,
      'created': created,
      'user_id': userId,
      'email': email,
    };
  }
}
```

---

### 4.2 Auth Service (`lib/services/social_auth_service.dart`)

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/auth_response.dart';

class SocialAuthService {
  static const String baseUrl = 'https://api.hykxapp.com';
  // Use http://10.0.2.2:8000 for Android Emulator local testing

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // HYKX Google Web Client ID (Required to obtain valid id_token)
  static const String _googleWebClientId =
      '80970139200-trnod70srm72omplmecl00ig6qnb8r1a.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _googleWebClientId,
  );

  // ─────────────────────────────────────────────────────────────
  // 1. Sign In with Google
  // ─────────────────────────────────────────────────────────────
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 1. Trigger native Google Sign-In sheet
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('User cancelled Google sign in.');
      }

      // 2. Obtain authentication credentials (idToken and accessToken)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        throw Exception('Google sign in did not return valid tokens.');
      }

      // 3. Send payload to HYKX backend
      final Map<String, dynamic> requestBody = {};
      if (idToken != null && idToken.isNotEmpty) {
        requestBody['id_token'] = idToken;
      } else {
        requestBody['access_token'] = accessToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final AuthResponse auth = AuthResponse.fromJson(responseData);

        // 4. Save tokens securely
        await _saveTokens(auth);
        return auth;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Google authentication failed');
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 2. Sign In with Apple
  // ─────────────────────────────────────────────────────────────
  Future<AuthResponse> signInWithApple() async {
    try {
      // 1. Trigger native Apple ID Authorization Sheet
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('Apple did not provide an identity token.');
      }

      // Build full name from credentials if provided (first login only)
      String fullName = '';
      if (credential.givenName != null || credential.familyName != null) {
        fullName = [
          credential.givenName ?? '',
          credential.familyName ?? '',
        ].join(' ').trim();
      }

      // 2. Send payload to HYKX backend
      final Map<String, dynamic> requestBody = {
        'identity_token': identityToken,
        'authorization_code': credential.authorizationCode,
        'full_name': fullName,
        'email': credential.email ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/apple/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final AuthResponse auth = AuthResponse.fromJson(responseData);

        // 3. Save tokens securely
        await _saveTokens(auth);
        return auth;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Apple authentication failed');
      }
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Token Storage Helpers
  // ─────────────────────────────────────────────────────────────
  Future<void> _saveTokens(AuthResponse auth) async {
    await _storage.write(key: 'access_token', value: auth.access);
    await _storage.write(key: 'refresh_token', value: auth.refresh);
    await _storage.write(key: 'user_id', value: auth.userId.toString());
    await _storage.write(key: 'username', value: auth.username);
    await _storage.write(key: 'email', value: auth.email);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _storage.deleteAll();
  }
}
```

---

### 4.3 UI Button Integration Example (`lib/screens/login_screen.dart`)

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/social_auth_service.dart';

class SocialLoginButtons extends StatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  final SocialAuthService _authService = SocialAuthService();
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final auth = await _authService.signInWithGoogle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${auth.username}!')),
      );
      // Navigate to Home / Dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAppleLogin() async {
    setState(() => _isLoading = true);
    try {
      final auth = await _authService.signInWithApple();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${auth.username}!')),
      );
      // Navigate to Home / Dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple Sign-In failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Google Sign-In Button
        ElevatedButton.icon(
          onPressed: _handleGoogleLogin,
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text('Continue with Google'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),

        // Apple Sign-In Button (Display only on iOS / macOS)
        if (Platform.isIOS || Platform.isMacOS)
          ElevatedButton.icon(
            onPressed: _handleAppleLogin,
            icon: const Icon(Icons.apple, size: 28),
            label: const Text('Continue with Apple'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}
```

---

## 5. Important Apple Sign-In Rules for Flutter

1. **First-Time vs Subsequent Sign-Ins**:
   - Apple **ONLY** sends `credential.givenName`, `credential.familyName`, and `credential.email` the **very first time** the user logs into your app.
   - On all subsequent sign-ins, `credential.email` and name fields will be `null` in Flutter.
   - **HYKX Backend handles this automatically**: On subsequent logins, the backend cryptographically verifies the `sub` (Apple unique identifier) inside `identity_token` and matches the existing account without needing the email or name again.
2. **Hide My Email (Private Relay)**:
   - When a user chooses "Hide My Email", Apple generates an alias like `ab12cd34@privaterelay.appleid.com`.
   - The backend records this relay address and associates all workouts and subscriptions with it normally.
3. **App Store Guidelines Requirement**:
   - Apple requires that if you offer any third-party social login (such as Google), you **MUST** also offer **Sign in with Apple** on iOS apps with equal prominence.

---

## 6. Troubleshooting & Common Pitfalls

| Issue | Cause | Solution |
|---|---|---|
| `ApiException: 10` (Google) | SHA-1 fingerprint mismatch in Google Cloud Console | Add your debug and release SHA-1 to Google Cloud Console OAuth Client. |
| `idToken is null` (Google) | Missing `serverClientId` in Flutter `GoogleSignIn` constructor | Set `serverClientId: '80970139200-trnod70srm72omplmecl00ig6qnb8r1a.apps.googleusercontent.com'` in `GoogleSignIn(...)`. |
| `Invalid Google ID token` (400) | Expired or malformed ID token | Ensure Flutter is sending fresh `googleAuth.idToken`. |
| `Invalid Apple identity token: Signature has expired` | Identity token passed 10-minute expiry | Call `SignInWithApple.getAppleIDCredential` immediately before sending to API. |
| `Sign in with Apple failed on Simulator` | Apple ID not signed in on iOS Simulator | Log in to an Apple ID in iOS Simulator Settings, or test on a physical iPhone. |
| `405 Method Not Allowed` | Calling with `GET` instead of `POST` | Use `POST /api/auth/google/` and `POST /api/auth/apple/`. |

