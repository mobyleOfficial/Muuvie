import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:shelves/shelves.dart';

/// Asks before deleting a locadora; its shelves stay on the profile.
Future<bool> confirmLocadoraDelete(
  BuildContext context,
  Locadora locadora,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n?.locadoraDeleteConfirmTitle(locadora.name) ?? ''),
      content: Text(l10n?.locadoraDeleteConfirmMessage ?? ''),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n?.cancel ?? ''),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n?.delete ?? ''),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
