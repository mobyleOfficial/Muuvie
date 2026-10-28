import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:profile_ui/retrospective/retrospective_bloc.dart';
import 'package:profile_ui/retrospective/retrospective_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stats/stats.dart';

/// The year in stories (F9.3), over the whole screen. A story can be shared
/// as an image.
@RoutePage()
class RetrospectivePage extends StatefulWidget {
  final int year;

  const RetrospectivePage({super.key, required this.year});

  @override
  State<RetrospectivePage> createState() => _RetrospectivePageState();
}

class _RetrospectivePageState extends State<RetrospectivePage> {
  late final RetrospectiveCubit _cubit = RetrospectiveCubit(
    year: widget.year,
    getRetrospective: GetIt.I<GetRetrospective>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _share(GlobalKey storyKey) async {
    final l10n = AppLocalizations.of(context);
    final boundary = storyKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null || !mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes.buffer.asUint8List(),
            mimeType: 'image/png',
            name: 'muuvie-${widget.year}.png',
          ),
        ],
        text: l10n?.retrospectiveShareText('${widget.year}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => RetrospectiveScreen(
    cubit: _cubit,
    onClose: () => context.router.maybePop(),
    onShare: _share,
  );
}
