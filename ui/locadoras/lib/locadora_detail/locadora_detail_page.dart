import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/locadora_detail/locadora_detail_bloc.dart';
import 'package:locadoras_ui/locadora_detail/locadora_detail_screen.dart';
import 'package:locadoras_ui/locadora_form/locadora_form_bottom_sheet.dart';
import 'package:locadoras_ui/locadoras_router.dart';
import 'package:locadoras_ui/widgets/confirm_locadora_delete.dart';

/// A locadora: header with owner and progress, then its shelves as corridors (F4.4).
@RoutePage()
class LocadoraDetailPage extends StatefulWidget {
  final int locadoraId;
  final String locadoraName;

  /// Opens a shelf of the locadora; null hides the action.
  final void Function(BuildContext context, Shelf shelf)? onOpenShelf;

  /// Opens the owner's profile (F14.6); null keeps the owner line static.
  final void Function(BuildContext context, Locadora locadora)? onOpenOwner;

  const LocadoraDetailPage({
    super.key,
    required this.locadoraId,
    required this.locadoraName,
    this.onOpenShelf,
    this.onOpenOwner,
  });

  @override
  State<LocadoraDetailPage> createState() => _LocadoraDetailPageState();
}

class _LocadoraDetailPageState extends State<LocadoraDetailPage> {
  late final LocadoraDetailCubit _cubit = LocadoraDetailCubit(
    locadoraId: widget.locadoraId,
    getLocadora: GetIt.I<GetLocadora>(),
    getLocadoraShelves: GetIt.I<GetLocadoraShelves>(),
    saveLocadora: GetIt.I<SaveLocadora>(),
    deleteLocadora: GetIt.I<DeleteLocadora>(),
    setLocadoraShelves: GetIt.I<SetLocadoraShelves>(),
    reorderLocadoraShelves: GetIt.I<ReorderLocadoraShelves>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showError() => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)?.shelfActionError ?? ''),
    ),
  );

  Future<void> _chooseShelves() async {
    final selected = await context.router.root.push<List<int>>(
      PickLocadoraShelvesRoute(selectedShelfIds: _cubit.shelfIds),
    );
    if (selected == null) return;
    if (!await _cubit.setShelves(selected) && mounted) _showError();
  }

  Future<void> _delete(Locadora locadora) async {
    if (!await confirmLocadoraDelete(context, locadora)) return;
    if (await _cubit.deleteLocadora()) {
      if (mounted) context.router.maybePop(true);
    } else if (mounted) {
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) => LocadoraDetailScreen(
    cubit: _cubit,
    onMovieTap: (movie) => context.router.push(
      MovieDetailRoute(movieId: movie.movieId, movieTitle: movie.title),
    ),
    onOpenShelf: widget.onOpenShelf == null
        ? null
        : (shelf) => widget.onOpenShelf!(context, shelf),
    onOpenOwner: widget.onOpenOwner == null
        ? null
        : (locadora) => widget.onOpenOwner!(context, locadora),
    onEdit: (locadora) => LocadoraFormBottomSheet.show(
      context,
      locadora: locadora,
      onSave: _cubit.saveLocadora,
    ),
    onDelete: _delete,
    onChooseShelves: _chooseShelves,
    onReorderSaved: (saved) {
      if (!saved) _showError();
    },
  );
}
