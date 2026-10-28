import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/gif_picker/gif_picker_cubit.dart';

/// Bottom sheet that searches GIFs and pops with the picked one (F2.2).
class GifPickerSheet extends StatefulWidget {
  const GifPickerSheet({super.key});

  static Future<Gif?> show(BuildContext context) => MuuvieBottomSheet.show<Gif>(
    context: context,
    builder: (_) => const GifPickerSheet(),
  );

  @override
  State<GifPickerSheet> createState() => _GifPickerSheetState();
}

class _GifPickerSheetState extends State<GifPickerSheet> {
  late final GifPickerCubit _cubit = GifPickerCubit(
    searchGifs: GetIt.I<SearchGifs>(),
    getRecentGifs: GetIt.I<GetRecentGifs>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: BlocBuilder<GifPickerCubit, GifPickerState>(
          bloc: _cubit,
          builder: (context, state) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n?.gifPickerTitle ?? '',
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n?.gifSearchHint ?? '',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _cubit.setQuery,
                ),
              ),
              if (state.query.trim().isEmpty && state.recent.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n?.gifRecent ?? '',
                      style: textTheme.labelLarge,
                    ),
                  ),
                ),
              if (state.unavailable)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n?.gifSearchUnavailable ?? '',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 200) {
                      _cubit.loadMore();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 140,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: state.visible.length,
                    itemBuilder: (context, index) {
                      final gif = state.visible[index];
                      return Semantics(
                        button: true,
                        label: l10n?.gifLabel ?? '',
                        child: InkWell(
                          borderRadius: MuuvieRadius.mediumAll,
                          onTap: () => Navigator.of(context).pop(gif),
                          child: ClipRRect(
                            borderRadius: MuuvieRadius.mediumAll,
                            child: CachedNetworkImage(
                              imageUrl: gif.previewUrl ?? gif.url,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => ColoredBox(
                                color: colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (state.isLoading) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
