import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/utils/logging/logger.dart';
import 'package:hawiisaac/features/authentication/model/auth_token_response.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class GoogleAuthDebugResult {
  const GoogleAuthDebugResult({
    required this.googleIdToken,
    this.firebaseIdToken = '',
    required this.authSession,
    required this.email,
    this.uid = '',
  });

  final String googleIdToken;
  final String firebaseIdToken;
  final AuthTokenResponse authSession;
  final String email;
  final String uid;
}

class GoogleAuthDebugService {
  GoogleAuthDebugService({GoogleSignIn? googleSignIn, AuthApiClient? apiClient})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
      _apiClient = apiClient ?? const AuthApiClient();

  // HYKX Google Web Client ID (Web application client ID from Google Cloud Console)
  static const String serverClientId =
      '80970139200-trnod70srm72omplmecl00ig6qnb8r1a.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn;
  final AuthApiClient _apiClient;

  bool _isInitialized = false;

  Future<GoogleAuthDebugResult> signInAndLoginToBackend() async {
    await _ensureInitialized();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String googleIdToken = googleAuth.idToken ?? '';

    if (googleIdToken.isEmpty) {
      throw const AuthException(
        message: 'Google sign-in did not return a valid ID token.',
        statusCode: 0,
      );
    }

    final tokenPreview = _tokenPreview(googleIdToken);
    AppLoggerHelper.debug(
      'Google login request pure ID token preview: $tokenPreview',
    );

    // Send pure Google ID token directly to HYKX backend as per API specs
    final Map<String, dynamic> data = await _apiClient.postJson(
      url: ApiEndpoint.googleAuth,
      body: <String, dynamic>{'id_token': googleIdToken},
      logLabel: 'Google Auth',
      showDebugLog: true,
    );

    final authSession = AuthTokenResponse.fromJson(data);
    if (authSession.accessToken.isEmpty || authSession.refreshToken.isEmpty) {
      throw const AuthException(
        message: 'Google login response did not include valid tokens.',
        statusCode: 0,
      );
    }

    debugPrint('Google auth success:');
    debugPrint('Google email: ${googleUser.email}');
    debugPrint('Google ID token: $googleIdToken');
    debugPrint(
      'Backend auth success: tokenType=${authSession.tokenType}, '
      'access=${_tokenPreview(authSession.accessToken)}, '
      'refresh=${_tokenPreview(authSession.refreshToken)}',
    );

    return GoogleAuthDebugResult(
      googleIdToken: googleIdToken,
      firebaseIdToken: '',
      authSession: authSession,
      email: googleUser.email,
      uid: googleUser.id,
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await _googleSignIn.initialize(serverClientId: serverClientId);
    _isInitialized = true;
  }

  String _tokenPreview(String token) {
    if (token.isEmpty) return 'empty';
    if (token.length <= 12) return 'len=${token.length}';

    return '${token.substring(0, 6)}...${token.substring(token.length - 6)} '
        '(len=${token.length})';
  }
}
