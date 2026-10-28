import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_job/import_job_cubit.dart';
import 'package:imports_ui/import_job/import_job_screen.dart';
import 'package:imports_ui/imports_router.dart';

/// One import: preview, progress and report. Also opened from the
/// "import finished" snackbar.
@RoutePage()
class ImportJobPage extends StatefulWidget {
  final int jobId;

  const ImportJobPage({super.key, required this.jobId});

  @override
  State<ImportJobPage> createState() => _ImportJobPageState();
}

class _ImportJobPageState extends State<ImportJobPage> {
  late final ImportJobCubit _cubit = ImportJobCubit(
    jobId: widget.jobId,
    getImport: GetIt.I<GetImport>(),
    confirmImport: GetIt.I<ConfirmImport>(),
    cancelImport: GetIt.I<CancelImport>(),
    watchImportProgress: GetIt.I<WatchImportProgress>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ImportJobScreen(
    cubit: _cubit,
    onReviewUnmatched: () =>
        context.router.push(ImportUnmatchedRoute(jobId: widget.jobId)),
    onImportAgain: () => context.router.replace(const ImportStartRoute()),
  );
}
