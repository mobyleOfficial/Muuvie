import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:imports/imports.dart';

/// Short status of an import job, colored by outcome.
class ImportStatusLabel extends StatelessWidget {
  final ImportStatus status;

  const ImportStatusLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      ImportStatus.done => colorScheme.primary,
      ImportStatus.failed => colorScheme.error,
      _ => colorScheme.onSurfaceVariant,
    };

    return Text(
      AppLocalizations.of(context)?.importStatusLabel(status.wireValue) ?? '',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    );
  }
}
