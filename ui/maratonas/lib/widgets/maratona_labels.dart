import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maratonas/maratonas.dart';

/// Texts and colors shared by the maratona screens.
extension MaratonaStatusLabel on MaratonaStatus {
  String label(AppLocalizations? l10n) => switch (this) {
    MaratonaStatus.upcoming => l10n?.maratonaStatusUpcoming ?? '',
    MaratonaStatus.active => l10n?.maratonaStatusActive ?? '',
    MaratonaStatus.finished => l10n?.maratonaStatusFinished ?? '',
    MaratonaStatus.cancelled => l10n?.maratonaStatusCancelled ?? '',
  };
}

/// "1 de out. de 2026 – 31 de out. de 2026", in the app's language.
String maratonaPeriod(AppLocalizations? l10n, DateTime start, DateTime end) {
  final format = DateFormat.yMMMd(Intl.getCurrentLocale());
  return l10n?.maratonaPeriod(format.format(start), format.format(end)) ?? '';
}

/// The maratona color, or the theme's primary when it has none.
Color maratonaColor(BuildContext context, String? accentColor) =>
    MuuvieColorPicker.fromHex(accentColor) ??
    Theme.of(context).colorScheme.primary;

/// Round logo of a maratona, or its initial on its color.
class MaratonaLogo extends StatelessWidget {
  final String title;
  final String? logoUrl;
  final String? accentColor;
  final double size;

  const MaratonaLogo({
    super.key,
    required this.title,
    this.logoUrl,
    this.accentColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = maratonaColor(context, accentColor);
    final onColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    final url = logoUrl;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 4),
        child: SizedBox.square(
          dimension: size,
          child: url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initial(color, onColor),
                )
              : _initial(color, onColor),
        ),
      ),
    );
  }

  Widget _initial(Color color, Color onColor) => ColoredBox(
    color: color,
    child: Center(
      child: Text(
        title.trim().isEmpty ? '?' : title.trim()[0].toUpperCase(),
        style: TextStyle(
          color: onColor,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.45,
        ),
      ),
    ),
  );
}

/// Small rounded label (status, "Com senha", "Curadoria").
class MaratonaBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool highlighted;

  const MaratonaBadge({
    super.key,
    required this.label,
    this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = highlighted
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = highlighted
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
