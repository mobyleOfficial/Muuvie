import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';

/// An actor or director with the movies of the catalog they are in (F5.7).
@RoutePage()
class PersonDetailPage extends StatefulWidget {
  /// Database id of the person, or 0 when only [tmdbPersonId] is known.
  final int personId;
  final int? tmdbPersonId;
  final String personName;

  const PersonDetailPage({
    super.key,
    required this.personId,
    this.tmdbPersonId,
    required this.personName,
  });

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  late Future<Result<PersonDetail>> _detail = _load();

  Future<Result<PersonDetail>> _load() => GetIt.I<GetPersonDetail>()(
    GetPersonDetailParams(
      personId: widget.personId,
      tmdbPersonId: widget.tmdbPersonId,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Result<PersonDetail>>(
      future: _detail,
      builder: (context, snapshot) => switch (snapshot.data) {
        null => const Center(child: CircularProgressIndicator()),
        Failure(:final error) => MuuvieEmptyState(
          title: l10n?.emptyStateErrorTitle ?? '',
          message: error.message,
          action: () => setState(() => _detail = _load()),
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        Success(:final data) => _PersonBody(detail: data),
      },
    );
  }
}

class _PersonBody extends StatelessWidget {
  final PersonDetail detail;

  const _PersonBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final photo = detail.person.profilePath;
    final directed = detail.directed;
    final acted = detail.acted;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: photo == null
                    ? null
                    : CachedNetworkImageProvider(
                        TmdbImageUrl.buildPosterMedium(photo),
                      ),
                child: photo == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    detail.person.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (directed.isEmpty && acted.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n?.personNoCredits ?? ''),
          ),
        if (directed.isNotEmpty)
          _Credits(title: l10n?.personDirected ?? '', credits: directed),
        if (acted.isNotEmpty)
          _Credits(title: l10n?.personActed ?? '', credits: acted),
      ],
    );
  }
}

class _Credits extends StatelessWidget {
  final String title;
  final List<PersonCredit> credits;

  const _Credits({required this.title, required this.credits});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.52,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: credits.length,
          itemBuilder: (context, index) {
            final credit = credits[index];
            final poster = credit.posterPath;
            final year = credit.year;
            final character = credit.character;
            return InkWell(
              borderRadius: MuuvieRadius.smallAll,
              onTap: () => context.router.push(
                MovieDetailRoute(
                  movieId: credit.movieId,
                  movieTitle: credit.title,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: MuuvieRadius.smallAll,
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: poster == null
                          ? ColoredBox(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.movie),
                            )
                          : CachedNetworkImage(
                              imageUrl: TmdbImageUrl.buildPosterMedium(poster),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    year == null ? credit.title : '${credit.title} ($year)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium,
                  ),
                  if (character != null && character.isNotEmpty)
                    Text(
                      character,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
