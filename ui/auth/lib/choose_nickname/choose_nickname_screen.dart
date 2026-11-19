import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common/common.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_cubit.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_state.dart';
import 'package:auth_ui/widgets/auth_error_banner.dart';
import 'package:auth_ui/widgets/auth_form_layout.dart';
import 'package:auth_ui/widgets/auth_header.dart';
import 'package:auth_ui/widgets/auth_submit_button.dart';
import 'package:auth_ui/widgets/auth_text_field.dart';

class ChooseNicknameScreen extends StatefulWidget {
  final ChooseNicknameState state;

  /// Prefills the field: the name Apple or Google gave, when there is one.
  final String? suggestedNickname;

  const ChooseNicknameScreen({
    super.key,
    required this.state,
    this.suggestedNickname,
  });

  @override
  State<ChooseNicknameScreen> createState() => _ChooseNicknameScreenState();
}

class _ChooseNicknameScreenState extends State<ChooseNicknameScreen> {
  late final _nicknameController = TextEditingController(
    text: _suggestion(widget.suggestedNickname),
  );
  final _nicknameFocus = FocusNode();

  // The error shows once the user left the field or tried to submit.
  bool _nicknameTouched = false;

  @override
  void initState() {
    super.initState();
    _nicknameFocus.addListener(_onFocusChanged);
    // Checks the suggested nickname once the screen is up.
    if (_nicknameController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ChooseNicknameCubit>().onNicknameChanged(
          _nicknameController.text,
        );
      });
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nicknameFocus.dispose();
    super.dispose();
  }

  static String _suggestion(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.length > ChooseNicknameCubit.maxNicknameLength
        ? trimmed.substring(0, ChooseNicknameCubit.maxNicknameLength).trim()
        : trimmed;
  }

  void _onFocusChanged() => setState(() {
    _nicknameTouched |=
        !_nicknameFocus.hasFocus && _nicknameController.text.isNotEmpty;
  });

  void _submit() {
    setState(() => _nicknameTouched = true);
    context.read<ChooseNicknameCubit>().submit(_nicknameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ChooseNicknameCubit>();

    final formState = widget.state is ChooseNicknameFormState
        ? widget.state as ChooseNicknameFormState
        : const ChooseNicknameFormState(isSubmitting: true);
    final nicknameError = formState.nicknameError;

    // A taken nickname comes from the server: show it right away.
    final showNicknameError = _nicknameTouched || nicknameError == 'taken';

    return AuthFormLayout(
      children: [
        AuthHeader(
          illustration: MuuvieIllustration.signup,
          title: l10n.chooseNicknameTitle,
          subtitle: l10n.chooseNicknameSubtitle,
        ),
        const SizedBox(height: 32),
        AuthTextField(
          label: l10n.signUpNickname,
          hint: l10n.signUpNicknameHint,
          icon: Icons.person_outline,
          controller: _nicknameController,
          focusNode: _nicknameFocus,
          enabled: !formState.isSubmitting,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newUsername],
          inputFormatters: [
            LengthLimitingTextInputFormatter(
              ChooseNicknameCubit.maxNicknameLength,
            ),
          ],
          errorText: showNicknameError
              ? _resolveNicknameError(nicknameError, l10n)
              : null,
          helper: _NicknameStatus(
            isChecking: formState.isCheckingNickname,
            isAvailable: formState.isNicknameAvailable == true,
          ),
          onChanged: (value) => cubit.onNicknameChanged(value.trim()),
          onSubmitted: (_) => _submit(),
        ),
        AuthErrorBanner(
          message: switch (formState.submitError) {
            null => null,
            'bad_request' => l10n.signUpBadRequestError,
            'network' => l10n.signUpNetworkError,
            'server' => l10n.signUpServerError,
            _ => l10n.loginGenericError,
          },
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(
          label: l10n.chooseNicknameButton,
          isLoading: formState.isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }

  String? _resolveNicknameError(String? error, AppLocalizations l10n) =>
      switch (error) {
        'required' => l10n.nicknameValidationError,
        'too_long' => l10n.nicknameTooLongError,
        'taken' => l10n.nicknameTakenError,
        _ => null,
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
