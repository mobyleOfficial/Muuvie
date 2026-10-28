import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/pick_shelves/pick_shelves_bloc.dart';
import 'package:locadoras_ui/pick_shelves/pick_shelves_screen.dart';
import 'package:locadoras_ui/pick_shelves/pick_shelves_state.dart';

/// Full-screen modal. Pops with the selected shelf ids, or null when closed.
@RoutePage()
class PickLocadoraShelvesPage extends StatefulWidget {
  final List<int> selectedShelfIds;

  const PickLocadoraShelvesPage({super.key, this.selectedShelfIds = const []});

  @override
  State<PickLocadoraShelvesPage> createState() =>
      _PickLocadoraShelvesPageState();
}

class _PickLocadoraShelvesPageState extends State<PickLocadoraShelvesPage> {
  late final PickShelvesCubit _cubit = PickShelvesCubit(
    initialIds: widget.selectedShelfIds,
    getUserShelves: GetIt.I<GetUserShelves>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PickShelvesScreen(
    cubit: _cubit,
    onSave: () {
      final current = _cubit.state;
      if (current is PickShelvesSuccess) {
        context.router.maybePop(current.selectedIds);
      }
    },
  );
}
