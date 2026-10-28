import 'package:common/src/muuvie_tab_bar.dart';
import 'package:flutter/material.dart';

/// Title block followed by tabs: maratona, CineClube and shelf headers.
///
/// Must sit under a [DefaultTabController] (or receive [controller]).
class MuuvieTabbedHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Optional color stripe on the left (e.g. the shelf border color).
  final Color? accentColor;
  final Widget? trailing;
  final List<String> tabs;
  final TabController? controller;

  const MuuvieTabbedHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor,
    this.trailing,
    required this.tabs,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (accentColor != null) ...[
                  ExcludeSemantics(
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: textTheme.titleLarge),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
        MuuvieTabBar(tabs: tabs, controller: controller),
      ],
    );
  }
}
