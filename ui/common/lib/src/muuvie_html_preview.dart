import 'package:flutter/material.dart';

class MuuvieHtmlPreview extends StatelessWidget {
  final String html;

  const MuuvieHtmlPreview({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final spans = _parseHtml(html, textTheme, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spans,
    );
  }

  static List<Widget> _parseHtml(
    String html,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final widgets = <Widget>[];
    final tagRegex = RegExp(
      r'<(h1|h2|p|li|ul|/ul)(?:\s[^>]*)?>(.*?)</\1>|<(ul|/ul)>',
      dotAll: true,
    );

    final matches = tagRegex.allMatches(html);
    if (matches.isEmpty) {
      widgets.add(
        Text(
          _stripInlineTags(html),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.6,
          ),
        ),
      );
      return widgets;
    }

    for (final match in matches) {
      final tag = match.group(1) ?? match.group(3) ?? '';
      final content = match.group(2) ?? '';

      switch (tag) {
        case 'h1':
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text.rich(
                _buildInlineSpans(content, colorScheme),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        case 'h2':
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text.rich(
                _buildInlineSpans(content, colorScheme),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        case 'p':
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text.rich(
                _buildInlineSpans(content, colorScheme),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.6,
                ),
              ),
            ),
          );
        case 'li':
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u2022 ',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      _buildInlineSpans(content, colorScheme),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    }

    return widgets;
  }

  static TextSpan _buildInlineSpans(String content, ColorScheme colorScheme) {
    final spans = <InlineSpan>[];
    final inlineRegex = RegExp(
      r'<(b|i|s)>(.*?)</\1>|<span class="spoiler">(.*?)</span>',
      dotAll: true,
    );

    var lastEnd = 0;
    for (final match in inlineRegex.allMatches(content)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: content.substring(lastEnd, match.start)));
      }

      final tag = match.group(1);
      final text = match.group(2) ?? match.group(3) ?? '';

      switch (tag) {
        case 'b':
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        case 'i':
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        case 's':
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          );
        default:
          spans.add(
            TextSpan(
              text: text,
              style: TextStyle(
                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
          );
      }

      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      spans.add(TextSpan(text: content.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }

  static String _stripInlineTags(String text) =>
      text.replaceAll(RegExp(r'<[^>]+>'), '');
}
