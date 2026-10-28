import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// An outlined counter of the locadora cards and header.
class LocadoraCountChip extends StatelessWidget {
  final String label;

  const LocadoraCountChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MuuvieRadius.pill),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
