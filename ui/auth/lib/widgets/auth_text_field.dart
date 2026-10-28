import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Filled, borderless field with its label above it. The label and the
/// field are merged so screen readers announce them together.
class AuthTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final Widget? helper;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.focusNode,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.errorText,
    this.helper,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    OutlineInputBorder border([Color? color]) => OutlineInputBorder(
      borderRadius: MuuvieRadius.largeAll,
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: 1.5),
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: enabled ? autofillHints : null,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
            cursorColor: colorScheme.primary,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              errorText: errorText,
              errorMaxLines: 2,
              helper: helper,
              prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
              suffixIcon: suffix,
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: border(),
              enabledBorder: border(),
              disabledBorder: border(),
              focusedBorder: border(colorScheme.primary),
              errorBorder: border(colorScheme.error),
              focusedErrorBorder: border(colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Eye toggle for password fields, with a spoken label for each state.
class PasswordVisibilityButton extends StatelessWidget {
  final bool obscured;
  final VoidCallback onPressed;

  const PasswordVisibilityButton({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      onPressed: onPressed,
      tooltip: obscured ? l10n.passwordShow : l10n.passwordHide,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Small icon + text line used as a field helper (requirements, status).
class AuthFieldHint extends StatelessWidget {
  final Widget leading;
  final String text;
  final Color? color;

  const AuthFieldHint({
    super.key,
    required this.leading,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        IconTheme(
          data: IconThemeData(size: 16, color: effectiveColor),
          child: leading,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: effectiveColor),
          ),
        ),
      ],
    );
  }
}

/// Success tone for positive field feedback. The design system has no
/// success colour; these greens keep 4.5:1 on the field surfaces.
Color authSuccessColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.green.shade300
    : Colors.green.shade800;
