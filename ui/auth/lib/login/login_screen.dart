import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common/common.dart';
import 'package:auth_ui/login/login_cubit.dart';
import 'package:auth_ui/login/login_state.dart';
import 'package:auth_ui/widgets/auth_error_banner.dart';
import 'package:auth_ui/widgets/auth_footer_link.dart';
import 'package:auth_ui/widgets/auth_form_layout.dart';
import 'package:auth_ui/widgets/auth_header.dart';
import 'package:auth_ui/widgets/auth_submit_button.dart';
import 'package:auth_ui/widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  final LoginState state;
  final VoidCallback? onSignUpTap;

  const LoginScreen({super.key, required this.state, this.onSignUpTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  // Field errors only show once the user left the field or tried to submit,
  // so nobody is told their e-mail is invalid while still typing it.
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChanged);
    _passwordFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {
    _emailTouched |= !_emailFocus.hasFocus && _emailController.text.isNotEmpty;
    _passwordTouched |=
        !_passwordFocus.hasFocus && _passwordController.text.isNotEmpty;
  });

  void _submit() {
    setState(() => _emailTouched = _passwordTouched = true);
    TextInput.finishAutofillContext();
    context.read<LoginCubit>().loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state is LoginLoading || state is LoginAuthenticated) {
      return const Center(child: MuuvieActivityIndicator());
    }

    String? emailError;
    String? passwordError;
    bool isSubmitting = false;
    String? loginError;

    if (state is LoginFormState) {
      emailError = state.emailError;
      passwordError = state.passwordError;
      isSubmitting = state.isSubmitting;
      loginError = state.loginError;
    } else if (state is LoginError) {
      loginError = state.message;
    }

    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<LoginCubit>();

    return AuthFormLayout(
      footer: AuthFooterLink(
        prompt: l10n.loginNoAccount,
        action: l10n.loginCreateAccountLink,
        onPressed: isSubmitting ? null : widget.onSignUpTap,
      ),
      children: [
        AuthHeader(
          illustration: MuuvieIllustration.welcome,
          title: l10n.loginWelcomeTitle,
          subtitle: l10n.loginSubtitle,
        ),
        const SizedBox(height: 32),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: l10n.loginEmail,
                hint: l10n.loginEmailHint,
                icon: Icons.alternate_email,
                controller: _emailController,
                focusNode: _emailFocus,
                enabled: !isSubmitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                errorText: _emailTouched
                    ? _resolveEmailError(emailError, l10n)
                    : null,
                onChanged: (value) => cubit.onEmailChanged(value.trim()),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: l10n.loginPassword,
                hint: l10n.loginPasswordHint,
                icon: Icons.lock_outline,
                controller: _passwordController,
                focusNode: _passwordFocus,
                enabled: !isSubmitting,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                errorText: _passwordTouched
                    ? _resolvePasswordError(passwordError, l10n)
                    : null,
                suffix: PasswordVisibilityButton(
                  obscured: _obscurePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                onChanged: cubit.onPasswordChanged,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        AuthErrorBanner(
          message: switch (loginError) {
            null => null,
            'invalid_credentials' => l10n.loginError,
            _ => l10n.loginGenericError,
          },
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(
          label: l10n.loginButton,
          isLoading: isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }

  String? _resolveEmailError(String? error, AppLocalizations l10n) =>
      switch (error) {
        'required' => l10n.fieldRequired,
        'invalid' => l10n.emailValidationError,
        _ => null,
      };

  String? _resolvePasswordError(String? error, AppLocalizations l10n) =>
      switch (error) {
        'required' => l10n.fieldRequired,
        'too_short' => l10n.passwordValidationError,
        _ => null,
      };
}
