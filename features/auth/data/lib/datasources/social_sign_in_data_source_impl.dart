import 'dart:convert';
import 'dart:math';

import 'package:core/core.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:auth_domain/models/oauth_provider.dart';
import 'package:auth_data/datasources/social_sign_in_data_source.dart';
import 'package:auth_data/models/social_credential_model.dart';

/// Sign in with Apple and Google through the native SDKs.
///
/// Google needs [googleServerClientId] (the web OAuth client: the ID token is
/// issued for it, and the backend lists it in `GOOGLE_CLIENT_IDS`) and, on
/// iOS, [googleIosClientId] unless `GIDClientID` is in Info.plist.
class SocialSignInDataSourceImpl implements SocialSignInDataSource {
  final String? googleServerClientId;
  final String? googleIosClientId;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

  SocialSignInDataSourceImpl({
    this.googleServerClientId,
    this.googleIosClientId,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<Result<SocialCredentialModel?>> signIn(OAuthProvider provider) =>
      switch (provider) {
        OAuthProvider.apple => _signInWithApple(),
        OAuthProvider.google => _signInWithGoogle(),
      };

  Future<Result<SocialCredentialModel?>> _signInWithApple() async {
    final rawNonce = _randomNonce();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      final idToken = credential.identityToken;
      if (idToken == null) return const Failure(AppError.unknown);

      // Apple sends the name only on the first sign-in of this app.
      final name = [credential.givenName, credential.familyName]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ');
      return Success(
        SocialCredentialModel(
          provider: OAuthProvider.apple.wire,
          idToken: idToken,
          nonce: rawNonce,
          displayName: name.isEmpty ? null : name,
        ),
      );
    } on SignInWithAppleAuthorizationException catch (exception) {
      return exception.code == AuthorizationErrorCode.canceled
          ? const Success(null)
          : const Failure(AppError.unknown);
    } catch (_) {
      return const Failure(AppError.unknown);
    }
  }

  Future<Result<SocialCredentialModel?>> _signInWithGoogle() async {
    try {
      await (_googleInitialization ??= _googleSignIn.initialize(
        clientId: _blankToNull(googleIosClientId),
        serverClientId: _blankToNull(googleServerClientId),
      ));
      if (!_googleSignIn.supportsAuthenticate()) {
        return const Failure(AppError.unknown);
      }

      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return const Failure(AppError.unknown);

      return Success(
        SocialCredentialModel(
          provider: OAuthProvider.google.wire,
          idToken: idToken,
          displayName: account.displayName,
        ),
      );
    } on GoogleSignInException catch (exception) {
      return exception.code == GoogleSignInExceptionCode.canceled
          ? const Success(null)
          : const Failure(AppError.unknown);
    } catch (_) {
      return const Failure(AppError.unknown);
    }
  }

  @override
  Future<void> signOut() async {
    if (_googleInitialization == null) return;
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // The session ends locally anyway.
    }
  }

  static String? _blankToNull(String? value) =>
      value == null || value.trim().isEmpty ? null : value;

  static String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
