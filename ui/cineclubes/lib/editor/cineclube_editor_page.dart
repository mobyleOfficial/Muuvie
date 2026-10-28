import 'package:auto_route/auto_route.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:cineclubes_ui/editor/cineclube_editor_bloc.dart';
import 'package:cineclubes_ui/editor/cineclube_editor_screen.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';

/// Creates a CineClube, or edits the one of [slug] (F8.5). Editing pops with
/// true after saving; creating opens the new CineClube.
@RoutePage()
class CineClubeEditorPage extends StatefulWidget {
  final String? slug;

  /// The movie of the first session when creating from its detail (F12.1).
  final CineClubeMovie? movie;

  const CineClubeEditorPage({super.key, this.slug, this.movie});

  @override
  State<CineClubeEditorPage> createState() => _CineClubeEditorPageState();
}

class _CineClubeEditorPageState extends State<CineClubeEditorPage> {
  late final CineClubeEditorCubit _cubit = CineClubeEditorCubit(
    slug: widget.slug,
    getCineClube: GetIt.I<GetCineClube>(),
    checkSlug: GetIt.I<CheckCineClubeSlug>(),
    saveCineClube: GetIt.I<SaveCineClube>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _save(CineClubeForm form) async {
    final l10n = AppLocalizations.of(context);
    final result = await _cubit.save(form);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        if (widget.slug != null) {
          context.router.maybePop(true);
        } else {
          context.router.replace(
            CineClubeDetailRoute(slug: data.slug, title: data.title),
          );
        }
      case Failure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error == AppError.conflict
                  ? l10n?.maratonaSlugTaken ?? ''
                  : l10n?.maratonaSaveError ?? '',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<CineClubeEditorCubit, CineClubeEditorState>(
      bloc: _cubit,
      builder: (context, state) => switch (state) {
        CineClubeEditorLoading() => const Center(
          child: MuuvieActivityIndicator(),
        ),
        CineClubeEditorError() => MuuvieEmptyState(
          illustration: MuuvieIllustration.error,
          title: l10n?.emptyStateErrorTitle ?? '',
          message: l10n?.emptyStateErrorMessage ?? '',
          action: _cubit.load,
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        final CineClubeEditorReady ready => CineClubeEditorScreen(
          cineclube: ready.cineclube,
          initialMovie: widget.movie,
          saving: ready.saving,
          searchMovies: GetIt.I<SearchMovies>(),
          onCheckSlug: _cubit.checkSlug,
          onSave: _save,
        ),
      },
    );
  }
}
