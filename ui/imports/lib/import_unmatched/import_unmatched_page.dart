import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_unmatched/import_unmatched_cubit.dart';
import 'package:imports_ui/import_unmatched/import_unmatched_screen.dart';

/// Confirmation queue of an import (F3.4).
@RoutePage()
class ImportUnmatchedPage extends StatefulWidget {
  final int jobId;

  const ImportUnmatchedPage({super.key, required this.jobId});

  @override
  State<ImportUnmatchedPage> createState() => _ImportUnmatchedPageState();
}

class _ImportUnmatchedPageState extends State<ImportUnmatchedPage> {
  late final ImportUnmatchedCubit _cubit = ImportUnmatchedCubit(
    jobId: widget.jobId,
    getUnmatchedItems: GetIt.I<GetUnmatchedItems>(),
    resolveUnmatchedItem: GetIt.I<ResolveUnmatchedItem>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ImportUnmatchedScreen(cubit: _cubit);
}
