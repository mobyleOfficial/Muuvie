import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Texts shared by the CineClube screens.
extension CineClubeStatusLabel on CineClubeStatus {
  String label(AppLocalizations? l10n) => switch (this) {
    CineClubeStatus.upcoming => l10n?.maratonaStatusUpcoming ?? '',
    CineClubeStatus.active => l10n?.maratonaStatusActive ?? '',
    CineClubeStatus.finished => l10n?.maratonaStatusFinished ?? '',
    CineClubeStatus.cancelled => l10n?.maratonaStatusCancelled ?? '',
  };
}

extension SessionProgressLabel on SessionProgress {
  String label(AppLocalizations? l10n) => switch (this) {
    SessionProgress.pending => l10n?.cineclubeProgressPending ?? '',
    SessionProgress.watching => l10n?.cineclubeProgressWatching ?? '',
    SessionProgress.completed => l10n?.cineclubeProgressCompleted ?? '',
  };

  IconData get icon => switch (this) {
    SessionProgress.pending => Icons.schedule,
    SessionProgress.watching => Icons.play_circle_outline,
    SessionProgress.completed => Icons.check_circle,
  };
}

/// "5 de out. de 2026", in the app's language.
String cineclubeDay(DateTime day) =>
    DateFormat.yMMMd(Intl.getCurrentLocale()).format(day);

/// "5 de out. – 12 de out. de 2026".
String cineclubePeriod(AppLocalizations? l10n, DateTime start, DateTime end) =>
    l10n?.maratonaPeriod(cineclubeDay(start), cineclubeDay(end)) ?? '';

/// The CineClube color, or the theme's primary when it has none.
Color cineclubeColor(BuildContext context, String? accentColor) =>
    MuuvieColorPicker.fromHex(accentColor) ??
    Theme.of(context).colorScheme.primary;

/// Poster of a session movie, or a movie icon on the CineClube color.
class CineClubePoster extends StatelessWidget {
  final String? posterPath;
  final String? accentColor;
  final double width;

  const CineClubePoster({
    super.key,
    this.posterPath,
    this.accentColor,
    this.width = 56,
  });

  @override
  Widget build(BuildContext context) {
    final path = posterPath;
    final placeholder = ColoredBox(
      color: cineclubeColor(context, accentColor).withValues(alpha: 0.25),
      child: const Center(child: Icon(Icons.movie_outlined)),
    );

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MuuvieRadius.small),
        child: SizedBox(
          width: width,
          height: width * 1.5,
          child: path == null || path.isEmpty
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: TmdbImageUrl.buildPosterMedium(path),
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => placeholder,
                ),
        ),
      ),
    );
  }
}
