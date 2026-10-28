import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/locadoras_list/locadoras_list_bloc.dart';
import 'package:locadoras_ui/locadoras_list/locadoras_list_screen.dart';
import 'package:locadoras_ui/locadoras_router.dart';

/// The Locadoras tab of a profile (F4.5). Editable only on my own profile.
class LocadorasListPage extends StatefulWidget {
  /// Owner of the locadoras, or `me` for the current user.
  final String userId;

  /// Opens a shelf from the locadora detail; null hides the action.
  final void Function(BuildContext context, Shelf shelf)? onOpenShelf;

  const LocadorasListPage({super.key, this.userId = 'me', this.onOpenShelf});

  @override
  State<LocadorasListPage> createState() => _LocadorasListPageState();
}

class _LocadorasListPageState extends State<LocadorasListPage> {
  late final LocadorasListCubit _cubit = LocadorasListCubit(
    userId: widget.userId,
    getUserLocadoras: GetIt.I<GetUserLocadoras>(),
    saveLocadora: GetIt.I<SaveLocadora>(),
    deleteLocadora: GetIt.I<DeleteLocadora>(),
    reorderLocadoras: GetIt.I<ReorderLocadoras>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _openLocadora(Locadora locadora) async {
    await context.router.push(
      LocadoraDetailRoute(
        locadoraId: locadora.id,
        locadoraName: locadora.name,
        onOpenShelf: widget.onOpenShelf,
      ),
    );
    // Shelves, counters and posters may have changed inside the locadora.
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) => LocadorasListScreen(
    cubit: _cubit,
    onOpenLocadora: _openLocadora,
    onCreated: _openLocadora,
  );
}
