import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common/common.dart';
import 'package:auth/auth.dart';
import 'package:auth_ui/login/login_cubit.dart';
import 'package:auth_ui/login/login_state.dart';
import 'package:auth_ui/widgets/auth_error_banner.dart';
import 'package:auth_ui/widgets/auth_form_layout.dart';
import 'package:auth_ui/widgets/auth_header.dart';
import 'package:auth_ui/widgets/social_sign_in_button.dart';

/// Sign in with Apple (on iOS) or Google. There is no e-mail and password:
/// a new account is created on the first sign-in.
class LoginScreen extends StatelessWidget {
  final LoginState state;

  /// The providers to offer. Defaults to the ones the platform supports.
  final List<OAuthProvider>? providers;

  const LoginScreen({super.key, required this.state, this.providers});

  /// Apple only where its native sheet exists; neither on web for now.
  static List<OAuthProvider> get platformProviders {
    if (kIsWeb) return const [];
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => const [
        OAuthProvider.apple,
        OAuthProvider.google,
      ],
      _ => const [OAuthProvider.google],
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = this.state;

    if (state is LoginLoading ||
        state is LoginAuthenticated ||
        state is LoginNeedsNickname) {
      return const Center(child: MuuvieActivityIndicator());
    }

    final formState = state is LoginFormState ? state : const LoginFormState();
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<LoginCubit>();

    return AuthFormLayout(
      children: [
        AuthHeader(
          illustration: MuuvieIllustration.welcome,
          title: l10n.loginWelcomeTitle,
          subtitle: l10n.loginSubtitle,
        ),
        const SizedBox(height: 32),
        for (final provider in providers ?? platformProviders) ...[
          SocialSignInButton(
            provider: provider,
            label: switch (provider) {
              OAuthProvider.apple => l10n.continueWithApple,
              OAuthProvider.google => l10n.continueWithGoogle,
            },
            isLoading: formState.submittingProvider == provider,
            onPressed: formState.isSubmitting
                ? null
                : () => cubit.signIn(provider),
          ),
          const SizedBox(height: 12),
        ],
        AuthErrorBanner(
          message: formState.loginError == null ? null : l10n.loginGenericError,
        ),
      ],
    );
  }
}
