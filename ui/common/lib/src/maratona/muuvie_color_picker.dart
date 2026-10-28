import 'package:common/app_localizations.dart';
import 'package:flutter/material.dart';

/// Border color picker for shelves (the Maratona "cor da borda").
///
/// The selected swatch shows a check mark, so selection never depends on
/// color alone.
class MuuvieColorPicker extends StatelessWidget {
  static const List<Color> presets = [
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF00897B),
    Color(0xFF039BE5),
    Color(0xFF3949AB),
    Color(0xFF8E24AA),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFF212121),
  ];

  /// Parses `#RRGGBB` (the format the API stores). Returns null when invalid.
  static Color? fromHex(String? hex) {
    final digits = hex?.replaceFirst('#', '');
    if (digits == null || digits.length != 6) return null;
    final value = int.tryParse(digits, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  static String toHex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  final Color? selected;
  final ValueChanged<Color> onChanged;
  final List<Color> colors;

  const MuuvieColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.colors = presets,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final (index, color) in colors.indexed)
          Semantics(
            label: l10n?.colorPickerOption(index + 1, colors.length),
            selected: color == selected,
            button: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onChanged(color),
              // 48×48 touch target around a 36 dp swatch.
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      // Thin outline keeps dark swatches visible on a dark surface.
                      border: color == selected
                          ? Border.all(color: colorScheme.onSurface, width: 3)
                          : Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: color == selected
                        ? Icon(
                            Icons.check,
                            size: 20,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
