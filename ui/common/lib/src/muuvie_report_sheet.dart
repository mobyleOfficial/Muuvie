import 'package:common/app_localizations.dart';
import 'package:common/src/muuvie_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Asks why something is reported and sends it with [onSend], which gets the
/// reason's wire value (`spam`, `harassment`, `hate`, `sexual`, `violence`,
/// `impersonation`, `spoiler`, `other`) and the optional details, and answers
/// whether the report went through. Shows the outcome in a snackbar.
abstract final class MuuvieReportSheet {
  static const reasons = [
    'spam',
    'harassment',
    'hate',
    'sexual',
    'violence',
    'impersonation',
    'spoiler',
    'other',
  ];

  static Future<void> show({
    required BuildContext context,
    required Future<bool> Function(String reason, String? details) onSend,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final sent = await MuuvieBottomSheet.show<bool>(
      context: context,
      builder: (_) => _ReportForm(onSend: onSend),
    );
    if (sent == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          (sent ? l10n?.reportSent : l10n?.reportError) ?? '',
        ),
      ),
    );
  }

  static String label(AppLocalizations? l10n, String reason) =>
      switch (reason) {
        'spam' => l10n?.reportReasonSpam,
        'harassment' => l10n?.reportReasonHarassment,
        'hate' => l10n?.reportReasonHate,
        'sexual' => l10n?.reportReasonSexual,
        'violence' => l10n?.reportReasonViolence,
        'impersonation' => l10n?.reportReasonImpersonation,
        'spoiler' => l10n?.reportReasonSpoiler,
        _ => l10n?.reportReasonOther,
      } ??
      reason;
}

class _ReportForm extends StatefulWidget {
  final Future<bool> Function(String reason, String? details) onSend;

  const _ReportForm({required this.onSend});

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _details = TextEditingController();
  String? _reason;
  var _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null || _sending) return;
    setState(() => _sending = true);
    final details = _details.text.trim();
    final sent = await widget.onSend(reason, details.isEmpty ? null : details);
    if (mounted) Navigator.of(context).pop(sent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n?.reportTitle ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: _reason,
                  onChanged: (value) => setState(() => _reason = value),
                  child: Column(
                    children: [
                      for (final reason in MuuvieReportSheet.reasons)
                        RadioListTile<String>(
                          value: reason,
                          contentPadding: EdgeInsets.zero,
                          title: Text(MuuvieReportSheet.label(l10n, reason)),
                        ),
                    ],
                  ),
                ),
                TextField(
                  controller: _details,
                  maxLength: 1000,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n?.reportDetailsHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _reason == null || _sending ? null : _send,
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n?.reportSend ?? ''),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
