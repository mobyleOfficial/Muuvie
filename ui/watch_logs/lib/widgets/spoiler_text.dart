import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Text hidden behind a "spoiler" label until tapped.
class SpoilerText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const SpoilerText({super.key, required this.text, this.style});

  @override
  State<SpoilerText> createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<SpoilerText> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    if (_revealed) return Text(widget.text, style: widget.style);

    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => setState(() => _revealed = true),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_off_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)?.spoilerReveal ?? '',
                style: (widget.style ?? Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
