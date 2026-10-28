import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common/common.dart';
import 'package:auth_ui/sign_up/sign_up_cubit.dart';
import 'package:auth_ui/sign_up/sign_up_state.dart';
import 'package:auth_ui/widgets/auth_error_banner.dart';
import 'package:auth_ui/widgets/auth_footer_link.dart';
import 'package:auth_ui/widgets/auth_form_layout.dart';
import 'package:auth_ui/widgets/auth_header.dart';
import 'package:auth_ui/widgets/auth_submit_button.dart';
import 'package:auth_ui/widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  static const int nicknameMaxLength = 30;

  final SignUpState state;
  final VoidCallback? onLoginTap;

  const SignUpScreen({super.key, required this.state, this.onLoginTap});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  // Field errors only show once the user left the field or tried to submit.
  bool _nicknameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    for (final node in [_nicknameFocus, _emailFocus, _passwordFocus]) {
      node.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {
    _nicknameTouched |=
        !_nicknameFocus.hasFocus && _nicknameController.text.isNotEmpty;
    _emailTouched |= !_emailFocus.hasFocus && _emailController.text.isNotEmpty;
    _passwordTouched |=
        !_passwordFocus.hasFocus && _passwordController.text.isNotEmpty;
  });

  void _submit() {
    setState(() => _nicknameTouched = _emailTouched = _passwordTouched = true);
    TextInput.finishAutofillContext();
    context.read<SignUpCubit>().createAccount(
      _emailController.text.trim(),
      _passwordController.text,
      _nicknameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SignUpCubit>();

    final formState = widget.state;
    String? emailError;
    String? passwordError;
    String? nicknameError;
    bool isSubmitting = false;
    String? signUpError;
    bool isCheckingNickname = false;
    bool? isNicknameAvailable;

    if (formState is SignUpFormState) {
      emailError = formState.emailError;
      passwordError = formState.passwordError;
      nicknameError = formState.nicknameError;
      isSubmitting = formState.isSubmitting;
      signUpError = formState.signUpError;
      isCheckingNickname = formState.isCheckingNickname;
      isNicknameAvailable = formState.isNicknameAvailable;
    }

    // A taken nickname comes from the server: show it right away.
    final showNicknameError = _nicknameTouched || nicknameError == 'taken';

    return AuthFormLayout(
      footer: AuthFooterLink(
        prompt: l10n.signUpHaveAccount,
        action: l10n.loginButton,
        onPressed: isSubmitting ? null : widget.onLoginTap,
      ),
      children: [
        AuthHeader(
          illustration: MuuvieIllustration.signup,
          title: l10n.signUpHeadline,
          subtitle: l10n.signUpSubtitle,
        ),
        const SizedBox(height: 32),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: l10n.signUpNickname,
                hint: l10n.signUpNicknameHint,
                icon: Icons.person_outline,
                controller: _nicknameController,
                focusNode: _nicknameFocus,
                enabled: !isSubmitting,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    SignUpScreen.nicknameMaxLength,
                  ),
                ],
                errorText: showNicknameError
                    ? _resolveNicknameError(nicknameError, l10n)
                    : null,
                helper: _NicknameStatus(
                  isChecking: isCheckingNickname,
                  isAvailable: isNicknameAvailable == true,
                ),
                onChanged: (value) => cubit.onNicknameChanged(value.trim()),
              ),
              const SizedBox(height: 16),
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
                autofillHints: const [AutofillHints.newPassword],
                errorText: _passwordTouched
                    ? _resolvePasswordError(passwordError, l10n)
                    : null,
                helper: _PasswordRequirement(
                  isMet:
                      cubit.validatePassword(_passwordController.text) == null,
                ),
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
          message: signUpError == null
              ? null
              : _resolveSignUpError(signUpError, l10n),
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(
          label: l10n.createAccountButton,
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
        'too_long' => l10n.passwordTooLongError,
        _ => null,
      };

  String? _resolveNicknameError(String? error, AppLocalizations l10n) =>
      switch (error) {
        'required' => l10n.nicknameValidationError,
        'too_long' => l10n.nicknameTooLongError,
        'taken' => l10n.nicknameTakenError,
        _ => null,
      };

  String _resolveSignUpError(String error, AppLocalizations l10n) =>
      switch (error) {
        'conflict' => l10n.signUpConflictError,
        'bad_request' => l10n.signUpBadRequestError,
        'network' => l10n.signUpNetworkError,
        'server' => l10n.signUpServerError,
        _ => l10n.loginGenericError,
      };
}

/// Availability of the nickname while it is checked against the server.
class _NicknameStatus extends StatelessWidget {
  final bool isChecking;
  final bool isAvailable;

  const _NicknameStatus({required this.isChecking, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isChecking) {
      return AuthFieldHint(
        leading: const SizedBox.square(
          dimension: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        text: l10n.signUpNicknameChecking,
      );
    }
    if (isAvailable) {
      return AuthFieldHint(
        leading: const Icon(Icons.check_circle),
        text: l10n.signUpNicknameAvailable,
        color: authSuccessColor(context),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Live "at least 8 characters" requirement under the password field.
class _PasswordRequirement extends StatelessWidget {
  final bool isMet;

  const _PasswordRequirement({required this.isMet});

  @override
  Widget build(BuildContext context) => AuthFieldHint(
    leading: Icon(isMet ? Icons.check_circle : Icons.radio_button_unchecked),
    text: AppLocalizations.of(context)!.signUpPasswordHelper,
    color: isMet ? authSuccessColor(context) : null,
  );
}
