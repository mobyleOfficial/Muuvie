import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification_ui/poster/poster_game_bloc.dart';
import 'package:gamification_ui/poster/poster_game_state.dart';

/// The poster starts blurred and gets sharp in [_reveal]; the four options
/// sit under it. After the answer the poster shows whole and the right
/// option is marked.
class PosterGameScreen extends StatelessWidget {
  final PosterGameCubit cubit;

  const PosterGameScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<PosterGameCubit, PosterGameState>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        PosterGameLoading() => const Center(child: MuuvieActivityIndicator()),
        PosterGameError() => MuuvieEmptyState(
          title: l10n?.emptyStateErrorTitle ?? '',
          message: l10n?.emptyStateErrorMessage ?? '',
          action: cubit.next,
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        final PosterGamePlaying playing => _Round(
          key: ValueKey(playing.round.movie.movieId + playing.rounds * 100000),
          state: playing,
          onAnswer: cubit.answer,
          onNext: cubit.next,
        ),
      },
    );
  }
}

class _Round extends StatefulWidget {
  final PosterGamePlaying state;
  final void Function(int movieId, double clarity) onAnswer;
  final VoidCallback onNext;

  const _Round({
    super.key,
    required this.state,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  State<_Round> createState() => _RoundState();
}

class _RoundState extends State<_Round> with SingleTickerProviderStateMixin {
  static const _reveal = Duration(seconds: 12);
  static const _maxBlur = 24.0;

  late final AnimationController _clarity = AnimationController(
    vsync: this,
    duration: _reveal,
  )..forward();

  @override
  void didUpdateWidget(_Round oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.answered) _clarity.stop();
  }

  @override
  void dispose() {
    _clarity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = widget.state;
    final movie = state.round.movie;
    final poster = movie.posterPath;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.posterGameScore(state.score) ?? '',
              style: textTheme.titleMedium,
            ),
            Text(
              l10n?.posterGameStreak(state.streak) ?? '',
              style: textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Semantics(
            label: l10n?.posterGameHint,
            image: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MuuvieRadius.medium),
              child: SizedBox(
                width: 220,
                height: 330,
                child: poster == null
                    ? const ColoredBox(color: Colors.black12)
                    : AnimatedBuilder(
                        animation: _clarity,
                        builder: (context, child) {
                          final blur = state.answered
                              ? 0.0
                              : _maxBlur * (1 - _clarity.value);
                          return ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: blur,
                              sigmaY: blur,
                            ),
                            child: child,
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: TmdbImageUrl.buildPosterLarge(poster),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.posterGameQuestion ?? '',
          textAlign: TextAlign.center,
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        for (final option in state.round.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: !state.answered
                    ? null
                    : option.movieId == movie.movieId
                    ? colorScheme.primaryContainer
                    : option.movieId == state.answer
                    ? colorScheme.errorContainer
                    : null,
                disabledForegroundColor: option.movieId == movie.movieId
                    ? colorScheme.onPrimaryContainer
                    : option.movieId == state.answer
                    ? colorScheme.onErrorContainer
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: state.answered
                  ? null
                  : () => widget.onAnswer(option.movieId, _clarity.value),
              child: Text(
                option.year == null
                    ? option.title
                    : '${option.title} (${option.year})',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (state.answered) ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(
              state.correct
                  ? l10n?.posterGameRight ?? ''
                  : l10n?.posterGameWrong(movie.title) ?? '',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: widget.onNext,
            child: Text(l10n?.posterGameNext ?? ''),
          ),
        ],
      ],
    );
  }
}
