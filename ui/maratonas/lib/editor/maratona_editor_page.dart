import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/editor/maratona_editor_bloc.dart';
import 'package:maratonas_ui/editor/maratona_editor_screen.dart';
import 'package:maratonas_ui/maratonas_router.dart';

/// Creates a maratona, or edits the one of [slug] (F7.7). Editing pops with
/// true after saving; creating opens the new maratona.
@RoutePage()
class MaratonaEditorPage extends StatefulWidget {
  final String? slug;

  const MaratonaEditorPage({super.key, this.slug});

  @override
  State<MaratonaEditorPage> createState() => _MaratonaEditorPageState();
}

class _MaratonaEditorPageState extends State<MaratonaEditorPage> {
  late final MaratonaEditorCubit _cubit = MaratonaEditorCubit(
    slug: widget.slug,
    getMaratona: GetIt.I<GetMaratona>(),
    getTemplates: GetIt.I<GetMaratonaTemplates>(),
    checkSlug: GetIt.I<CheckMaratonaSlug>(),
    saveMaratona: GetIt.I<SaveMaratona>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _save(MaratonaForm form) async {
    final l10n = AppLocalizations.of(context);
    final result = await _cubit.save(form);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        if (widget.slug != null) {
          context.router.maybePop(true);
        } else {
          context.router.replace(
            MaratonaDetailRoute(slug: data.slug, title: data.title),
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

    return BlocBuilder<MaratonaEditorCubit, MaratonaEditorState>(
      bloc: _cubit,
      builder: (context, state) => switch (state) {
        MaratonaEditorLoading() => const Center(
          child: MuuvieActivityIndicator(),
        ),
        MaratonaEditorError() => MuuvieEmptyState(
          illustration: MuuvieIllustration.error,
          title: l10n?.emptyStateErrorTitle ?? '',
          message: l10n?.emptyStateErrorMessage ?? '',
          action: _cubit.load,
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        final MaratonaEditorReady ready => MaratonaEditorScreen(
          maratona: ready.maratona,
          templates: ready.templates,
          saving: ready.saving,
          onCheckSlug: _cubit.checkSlug,
          onSave: _save,
        ),
      },
    );
  }
}
