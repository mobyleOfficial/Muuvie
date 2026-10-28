import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:watch_logs_ui/rating/rate_movie_cubit.dart';

class RateMovieScreen extends StatefulWidget {
  final RateMovieCubit cubit;
  final String movieTitle;
  final bool canRemove;
  final VoidCallback onSave;
  final VoidCallback onRemove;

  const RateMovieScreen({
    super.key,
    required this.cubit,
    required this.movieTitle,
    required this.canRemove,
    required this.onSave,
    required this.onRemove,
  });

  @override
  State<RateMovieScreen> createState() => _RateMovieScreenState();
}

class _RateMovieScreenState extends State<RateMovieScreen> {
  late final _reviewController = TextEditingController(
    text: widget.cubit.state.review,
  );

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = widget.cubit;

    return MuuvieModalScreen(
      title: l10n?.ratingTitle ?? '',
      // The modal paints its own background; list tiles need a Material for splashes.
      body: Material(
        type: MaterialType.transparency,
        child: BlocBuilder<RateMovieCubit, RateMovieState>(
          bloc: cubit,
          builder: (context, state) {
            final rating = state.rating;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(widget.movieTitle, style: textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Text(
                        l10n?.ratingPrompt ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      MuuvieRatingPicker(
                        selected: rating,
                        onChanged: cubit.setRating,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _reviewController,
                        minLines: 3,
                        maxLines: 8,
                        maxLength: 10000,
                        decoration: InputDecoration(
                          labelText: l10n?.ratingReview ?? '',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: cubit.setReview,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n?.watchLogSpoiler ?? ''),
                        value: state.hasSpoiler,
                        onChanged: cubit.setSpoiler,
                      ),
                      // Abandonei and Na geladeira do not finish the movie.
                      if (state.canCreateLog)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n?.ratingCreateLog ?? ''),
                          value: state.createLog,
                          onChanged: cubit.setCreateLog,
                        ),
                      if (state.willCreateLog) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n?.watchLogEmotions ?? '',
                          style: textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        MuuvieEmotionPicker(
                          selected: state.emotions,
                          recent: state.recentEmotions,
                          onChanged: cubit.setEmotions,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.watchLogVisibility ?? '',
                          style: textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        MuuvieVisibilitySelector(
                          value: state.visibility,
                          onChanged: cubit.setVisibility,
                        ),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MuuvieButton(
                          onPressed: rating == null || state.isSaving
                              ? null
                              : widget.onSave,
                          child: state.isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n?.ratingSave ?? ''),
                        ),
                        if (widget.canRemove)
                          TextButton(
                            onPressed: state.isSaving ? null : widget.onRemove,
                            child: Text(l10n?.ratingRemove ?? ''),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
