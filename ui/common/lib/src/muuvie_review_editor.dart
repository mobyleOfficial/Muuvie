import 'package:flutter/material.dart';

import 'package:common/src/muuvie_bottom_sheet.dart';
import 'package:common/src/muuvie_dialog.dart';
import 'package:common/app_localizations.dart';

class MuuvieReviewEditor extends StatefulWidget {
  final String? initialHtml;

  const MuuvieReviewEditor({super.key, this.initialHtml});

  static Future<String?> show(BuildContext context, {String? initialHtml}) =>
      MuuvieBottomSheet.show<String>(
        context: context,
        enableDrag: false,
        isDismissible: false,
        builder: (_) => MuuvieReviewEditor(initialHtml: initialHtml),
      );

  @override
  State<MuuvieReviewEditor> createState() => _MuuvieReviewEditorState();
}

class _MuuvieReviewEditorState extends State<MuuvieReviewEditor>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final TabController _tabController;
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    final initialText = htmlToEditable(widget.initialHtml ?? '');
    _controller = TextEditingController(text: initialText);
    _focusNode = FocusNode();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _wrapSelection(String openTag, String closeTag) {
    final selection = _controller.selection;
    final text = _controller.text;

    if (!selection.isValid || selection.isCollapsed) {
      final offset = selection.baseOffset;
      final newText =
          '${text.substring(0, offset)}$openTag$closeTag${text.substring(offset)}';
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: offset + openTag.length),
      );
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    final newText =
        '${text.substring(0, selection.start)}$openTag$selectedText$closeTag${text.substring(selection.end)}';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            selection.start +
            openTag.length +
            selectedText.length +
            closeTag.length,
      ),
    );
  }

  void _insertBlock(String prefix) {
    final selection = _controller.selection;
    final text = _controller.text;
    final offset = selection.isValid ? selection.baseOffset : text.length;

    final needsNewline = offset > 0 && text[offset - 1] != '\n';
    final insert = '${needsNewline ? '\n' : ''}$prefix';
    final newText =
        '${text.substring(0, offset)}$insert${text.substring(offset)}';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + insert.length),
    );
  }

  void _onClear() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    MuuvieDialog.show(
      context: context,
      title: l10n.reviewEditorClearConfirmTitle,
      content: l10n.reviewEditorClearConfirmContent,
      confirmText: l10n.reviewEditorClear,
      cancelText: l10n.cancel,
      onConfirm: () {
        _controller.clear();
      },
    );
  }

  String? _buildResult() {
    final html = editableToHtml(_controller.text);
    return html.trim().isEmpty ? null : html;
  }

  void _onDone() {
    final result = _buildResult();
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  static String editableToHtml(String text) {
    if (text.trim().isEmpty) return '';

    final lines = text.split('\n');
    final buffer = StringBuffer();
    var inList = false;
    final paragraphLines = <String>[];

    void flushParagraph() {
      if (paragraphLines.isEmpty) return;
      final merged = paragraphLines.join(' ');
      buffer.write('<p>${_applyInlineFormatting(merged)}</p>');
      paragraphLines.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('# ')) {
        flushParagraph();
        if (inList) {
          buffer.write('</ul>');
          inList = false;
        }
        buffer.write(
          '<h1>${_applyInlineFormatting(trimmed.substring(2))}</h1>',
        );
      } else if (trimmed.startsWith('## ')) {
        flushParagraph();
        if (inList) {
          buffer.write('</ul>');
          inList = false;
        }
        buffer.write(
          '<h2>${_applyInlineFormatting(trimmed.substring(3))}</h2>',
        );
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        flushParagraph();
        if (!inList) {
          buffer.write('<ul>');
          inList = true;
        }
        buffer.write(
          '<li>${_applyInlineFormatting(trimmed.substring(2))}</li>',
        );
      } else if (trimmed.isEmpty) {
        flushParagraph();
        if (inList) {
          buffer.write('</ul>');
          inList = false;
        }
      } else {
        if (inList) {
          flushParagraph();
          buffer.write('</ul>');
          inList = false;
        }
        paragraphLines.add(trimmed);
      }
    }

    flushParagraph();

    if (inList) {
      buffer.write('</ul>');
    }

    return buffer.toString();
  }

  static String _applyInlineFormatting(String text) {
    var result = text;
    result = result.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (match) => '<b>${match.group(1)}</b>',
    );
    result = result.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+?)\*(?!\*)'),
      (match) => '<i>${match.group(1)}</i>',
    );
    result = result.replaceAllMapped(
      RegExp(r'~~(.+?)~~'),
      (match) => '<s>${match.group(1)}</s>',
    );
    result = result.replaceAllMapped(
      RegExp(r'\|\|(.+?)\|\|'),
      (match) => '<span class="spoiler">${match.group(1)}</span>',
    );
    return result;
  }

  static String htmlToEditable(String html) {
    if (html.trim().isEmpty) return '';

    var result = html;

    result = result.replaceAllMapped(
      RegExp(r'<b>(.*?)</b>'),
      (match) => '**${match.group(1)}**',
    );
    result = result.replaceAllMapped(
      RegExp(r'<i>(.*?)</i>'),
      (match) => '*${match.group(1)}*',
    );
    result = result.replaceAllMapped(
      RegExp(r'<s>(.*?)</s>'),
      (match) => '~~${match.group(1)}~~',
    );
    result = result.replaceAllMapped(
      RegExp(r'<span class="spoiler">(.*?)</span>'),
      (match) => '||${match.group(1)}||',
    );
    result = result.replaceAllMapped(
      RegExp(r'<h1>(.*?)</h1>'),
      (match) => '# ${match.group(1)}\n',
    );
    result = result.replaceAllMapped(
      RegExp(r'<h2>(.*?)</h2>'),
      (match) => '## ${match.group(1)}\n',
    );
    result = result.replaceAll(RegExp(r'<ul>'), '');
    result = result.replaceAll(RegExp(r'</ul>'), '');
    result = result.replaceAllMapped(
      RegExp(r'<li>(.*?)</li>'),
      (match) => '- ${match.group(1)}\n',
    );
    result = result.replaceAllMapped(
      RegExp(r'<p>(.*?)</p>'),
      (match) => '${match.group(1)}\n\n',
    );

    return result.trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onDone();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _DragHandle(onDismiss: _onDone),
            _EditorTabBar(controller: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Material(
                    color: colorScheme.surfaceBright,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.7,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n?.reviewEditorPlaceholder ?? '',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  _PreviewTab(
                    controller: _controller,
                    tabController: _tabController,
                  ),
                ],
              ),
            ),
            _FormattingToolbar(
              onBold: () => _wrapSelection('**', '**'),
              onItalic: () => _wrapSelection('*', '*'),
              onStrikethrough: () => _wrapSelection('~~', '~~'),
              onSpoiler: () => _wrapSelection('||', '||'),
              onHeading: () => _insertBlock('# '),
              onSubheading: () => _insertBlock('## '),
              onList: () => _insertBlock('- '),
              onParagraph: () => _insertBlock('\n'),
              onClear: _onClear,
              onDone: _onDone,
              clearLabel: l10n?.reviewEditorClear ?? '',
            ),
            SizedBox(height: bottomInset),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final VoidCallback onDismiss;

  const _DragHandle({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          onDismiss();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorTabBar extends StatelessWidget {
  final TabController controller;

  const _EditorTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          dividerHeight: 0,
          labelColor: colorScheme.onPrimaryContainer,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: textTheme.labelMedium,
          splashBorderRadius: BorderRadius.circular(8),
          tabs: const [
            Tab(text: 'Write', height: 30),
            Tab(text: 'Preview', height: 30),
          ],
        ),
      ),
    );
  }
}

class _PreviewTab extends StatefulWidget {
  final TextEditingController controller;
  final TabController tabController;

  const _PreviewTab({required this.controller, required this.tabController});

  @override
  State<_PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends State<_PreviewTab> {
  final _revealedSpoilers = <int>{};

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabController.index != 1 && _revealedSpoilers.isNotEmpty) {
      setState(() => _revealedSpoilers.clear());
    }
  }

  void _toggleSpoiler(int index) => setState(() {
    if (_revealedSpoilers.contains(index)) {
      _revealedSpoilers.remove(index);
    } else {
      _revealedSpoilers.add(index);
    }
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: colorScheme.surfaceBright,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final html = _MuuvieReviewEditorState.editableToHtml(
            widget.controller.text,
          );

          if (html.trim().isEmpty) {
            return Center(
              child: Text(
                'Nothing to preview yet',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: _HtmlPreviewWithSpoilers(
              html: html,
              revealedSpoilers: _revealedSpoilers,
              onSpoilerDoubleTap: _toggleSpoiler,
            ),
          );
        },
      ),
    );
  }
}

class _HtmlPreviewWithSpoilers extends StatelessWidget {
  final String html;
  final Set<int> revealedSpoilers;
  final ValueChanged<int> onSpoilerDoubleTap;

  const _HtmlPreviewWithSpoilers({
    required this.html,
    required this.revealedSpoilers,
    required this.onSpoilerDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final widgets = _parseHtml(html, textTheme, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> _parseHtml(
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
          _stripTags(html),
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
                _buildSpans(content, colorScheme),
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
                _buildSpans(content, colorScheme),
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
                _buildSpans(content, colorScheme),
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
                      _buildSpans(content, colorScheme),
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

  TextSpan _buildSpans(String content, ColorScheme colorScheme) {
    final spans = <InlineSpan>[];
    final inlineRegex = RegExp(
      r'<(b|i|s)>(.*?)</\1>|<span class="spoiler">(.*?)</span>',
      dotAll: true,
    );

    var lastEnd = 0;
    var spoilerIndex = 0;

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
          final currentIndex = spoilerIndex++;
          final revealed = revealedSpoilers.contains(currentIndex);
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _SpoilerChip(
                text: text,
                revealed: revealed,
                onDoubleTap: () => onSpoilerDoubleTap(currentIndex),
                colorScheme: colorScheme,
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

  static String _stripTags(String text) =>
      text.replaceAll(RegExp(r'<[^>]+>'), '');
}

class _SpoilerChip extends StatelessWidget {
  final String text;
  final bool revealed;
  final VoidCallback onDoubleTap;
  final ColorScheme colorScheme;

  const _SpoilerChip({
    required this.text,
    required this.revealed,
    required this.onDoubleTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: revealed
              ? colorScheme.tertiaryContainer
              : colorScheme.onSurface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          revealed ? text : 'Spoiler',
          style: textTheme.bodyMedium?.copyWith(
            color: revealed
                ? colorScheme.onTertiaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _FormattingToolbar extends StatelessWidget {
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onStrikethrough;
  final VoidCallback onSpoiler;
  final VoidCallback onHeading;
  final VoidCallback onSubheading;
  final VoidCallback onList;
  final VoidCallback onParagraph;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final String clearLabel;

  const _FormattingToolbar({
    required this.onBold,
    required this.onItalic,
    required this.onStrikethrough,
    required this.onSpoiler,
    required this.onHeading,
    required this.onSubheading,
    required this.onList,
    required this.onParagraph,
    required this.onClear,
    required this.onDone,
    required this.clearLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                _ToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: 'Bold',
                  onPressed: onBold,
                ),
                const SizedBox(width: 2),
                _ToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: 'Italic',
                  onPressed: onItalic,
                ),
                const SizedBox(width: 2),
                _ToolbarButton(
                  icon: Icons.format_strikethrough,
                  tooltip: 'Strikethrough',
                  onPressed: onStrikethrough,
                ),
                const SizedBox(width: 2),
                _ToolbarButton(
                  icon: Icons.visibility_off_outlined,
                  tooltip: 'Spoiler',
                  onPressed: onSpoiler,
                ),
                _ToolbarDivider(),
                _ToolbarButton(
                  icon: Icons.title,
                  tooltip: 'Heading',
                  onPressed: onHeading,
                ),
                const SizedBox(width: 2),
                _ToolbarButton(
                  icon: Icons.text_fields,
                  tooltip: 'Subheading',
                  onPressed: onSubheading,
                ),
                const SizedBox(width: 2),
                _ToolbarButton(
                  icon: Icons.format_list_bulleted,
                  tooltip: 'List',
                  onPressed: onList,
                ),
                const SizedBox(width: 2),
                _ToolbarButton(
                  icon: Icons.segment,
                  tooltip: 'Paragraph',
                  onPressed: onParagraph,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: onClear,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(clearLabel),
                ),
                const Spacer(),
                Semantics(
                  label: 'Done',
                  button: true,
                  child: FilledButton.tonal(
                    onPressed: onDone,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Done',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
