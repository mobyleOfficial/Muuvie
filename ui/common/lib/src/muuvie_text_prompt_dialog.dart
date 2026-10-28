import 'package:common/app_localizations.dart';
import 'package:flutter/material.dart';

/// Asks for one line of text. [parse] turns what was typed into the value to
/// return, or null while it is not valid; [errorText] then shows under the field.
///
/// The dialog owns its controller, so it is only disposed after the closing
/// animation ends.
class MuuvieTextPromptDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String? hintText;
  final String? prefixText;
  final String? errorText;
  final String confirmLabel;
  final TextInputType? keyboardType;
  final String? Function(String text) parse;

  const MuuvieTextPromptDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.parse,
    this.initialValue,
    this.hintText,
    this.prefixText,
    this.errorText,
    this.keyboardType,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    required String? Function(String text) parse,
    String? initialValue,
    String? hintText,
    String? prefixText,
    String? errorText,
    TextInputType? keyboardType,
  }) => showDialog<String>(
    context: context,
    builder: (_) => MuuvieTextPromptDialog(
      title: title,
      confirmLabel: confirmLabel,
      parse: parse,
      initialValue: initialValue,
      hintText: hintText,
      prefixText: prefixText,
      errorText: errorText,
      keyboardType: keyboardType,
    ),
  );

  @override
  State<MuuvieTextPromptDialog> createState() => _MuuvieTextPromptDialogState();
}

class _MuuvieTextPromptDialogState extends State<MuuvieTextPromptDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    final value = widget.parse(text);

    void confirm() {
      if (value != null) Navigator.of(context).pop(value);
    }

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        autocorrect: false,
        keyboardType: widget.keyboardType,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => confirm(),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixText: widget.prefixText,
          errorText: text.isEmpty || value != null ? null : widget.errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? ''),
        ),
        TextButton(
          onPressed: value == null ? null : confirm,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
