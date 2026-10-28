import 'package:cineclubes/cineclubes.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';
import 'package:onboarding_ui/onboarding_bloc.dart';
import 'package:onboarding_ui/onboarding_state.dart';

/// Six panels and the suggestions: swipe or tap "Próximo"; "Pular" ends it.
class OnboardingScreen extends StatefulWidget {
  final OnboardingCubit cubit;
  final VoidCallback onFinish;
  final VoidCallback onImport;
  final ValueChanged<MaratonaSummary> onOpenMaratona;
  final ValueChanged<CineClubeSummary> onOpenCineClube;

  const OnboardingScreen({
    super.key,
    required this.cubit,
    required this.onFinish,
    required this.onImport,
    required this.onOpenMaratona,
    required this.onOpenCineClube,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  var _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Panel> _panels(AppLocalizations? l10n) => [
    _Panel(
      '🎬',
      l10n?.onboardingWelcomeTitle ?? '',
      l10n?.onboardingWelcomeText ?? '',
    ),
    _Panel(
      '📚',
      l10n?.onboardingShelvesTitle ?? '',
      l10n?.onboardingShelvesText ?? '',
    ),
    _Panel(
      '📝',
      l10n?.onboardingLogsTitle ?? '',
      l10n?.onboardingLogsText ?? '',
    ),
    _Panel(
      '🏆',
      l10n?.onboardingProgramacaoTitle ?? '',
      l10n?.onboardingProgramacaoText ?? '',
    ),
    _Panel(
      '🍿',
      l10n?.onboardingSocialTitle ?? '',
      l10n?.onboardingSocialText ?? '',
    ),
    _Panel(
      '📥',
      l10n?.onboardingImportTitle ?? '',
      l10n?.onboardingImportText ?? '',
      import: true,
    ),
  ];

  void _next(int count) {
    if (_page >= count - 1) return;
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final panels = _panels(l10n);
    final count = panels.length + 1;
    final last = _page == count - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onFinish,
                child: Text(l10n?.onboardingSkip ?? ''),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final panel in panels)
                    _PanelView(
                      panel: panel,
                      onImport: panel.import ? widget.onImport : null,
                    ),
                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    bloc: widget.cubit,
                    builder: (context, state) => _Suggestions(
                      state: state,
                      onOpenMaratona: widget.onOpenMaratona,
                      onOpenCineClube: widget.onOpenCineClube,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Semantics(
                label: l10n?.onboardingStep(_page + 1, count),
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < count; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == _page ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _page
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last ? widget.onFinish : () => _next(count),
                  child: Text(
                    last
                        ? l10n?.onboardingStart ?? ''
                        : l10n?.onboardingNext ?? '',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel {
  final String emoji;
  final String title;
  final String text;
  final bool import;

  const _Panel(this.emoji, this.title, this.text, {this.import = false});
}

class _PanelView extends StatelessWidget {
  final _Panel panel;
  final VoidCallback? onImport;

  const _PanelView({required this.panel, this.onImport});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final import = onImport;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      children: [
        ExcludeSemantics(
          child: Text(
            panel.emoji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 96),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            panel.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          panel.text,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        if (import != null) ...[
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: import,
            icon: const Icon(Icons.download_outlined),
            label: Text(l10n?.onboardingImportFilmow ?? ''),
          ),
        ],
      ],
    );
  }
}

class _Suggestions extends StatelessWidget {
  final OnboardingState state;
  final ValueChanged<MaratonaSummary> onOpenMaratona;
  final ValueChanged<CineClubeSummary> onOpenCineClube;

  const _Suggestions({
    required this.state,
    required this.onOpenMaratona,
    required this.onOpenCineClube,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final ready = state;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n?.onboardingSuggestionsTitle ?? '',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.onboardingSuggestionsText ?? '',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (ready is OnboardingLoading)
          const Center(child: MuuvieActivityIndicator())
        else if (ready is OnboardingSuccess) ...[
          if (ready.maratonas.isEmpty && ready.cineclubes.isEmpty)
            Text(
              l10n?.onboardingSuggestionsEmpty ?? '',
              textAlign: TextAlign.center,
            ),
          for (final maratona in ready.maratonas)
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(maratona.title),
              subtitle: Text(
                l10n?.maratonaParticipants(maratona.totalParticipants) ?? '',
              ),
              onTap: () => onOpenMaratona(maratona),
            ),
          for (final cineclube in ready.cineclubes)
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: Text(cineclube.title),
              subtitle: Text(cineclube.movie?.title ?? ''),
              onTap: () => onOpenCineClube(cineclube),
            ),
        ],
      ],
    );
  }
}
