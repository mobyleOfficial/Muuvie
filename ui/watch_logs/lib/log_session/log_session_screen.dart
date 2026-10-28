import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:watch_logs_ui/gif_picker/gif_picker_sheet.dart';
import 'package:watch_logs_ui/log_session/log_session_cubit.dart';
import 'package:watch_logs_ui/log_session/log_session_state.dart';

class LogSessionScreen extends StatefulWidget {
  final LogSessionCubit cubit;
  final String movieTitle;
  final bool isEditing;

  /// Saves and closes; returns false when saving failed.
  final Future<bool> Function() onSave;

  const LogSessionScreen({
    super.key,
    required this.cubit,
    required this.movieTitle,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<LogSessionScreen> createState() => _LogSessionScreenState();
}

class _LogSessionScreenState extends State<LogSessionScreen> {
  late final _providerController = TextEditingController(
    text: widget.cubit.state.providerName,
  );
  late final _commentController = TextEditingController(
    text: widget.cubit.state.comment,
  );

  @override
  void dispose() {
    _providerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) widget.cubit.setDate(picked);
  }

  Future<void> _save(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context)?.watchLogError ?? '';
    if (!await widget.onSave()) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final cubit = widget.cubit;

    return MuuvieModalScreen(
      title: widget.isEditing
          ? l10n?.watchLogEditTitle ?? ''
          : l10n?.watchLogTitle ?? '',
      // The modal paints its own background; list tiles need a Material for splashes.
      body: Material(
        type: MaterialType.transparency,
        child: BlocBuilder<LogSessionCubit, LogSessionState>(
          bloc: cubit,
          builder: (context, state) => Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _Padded(
                      child: Text(
                        widget.movieTitle,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(l10n?.watchLogDate ?? ''),
                      subtitle: Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(state.watchedOn),
                      ),
                      onTap: state.isSaving
                          ? null
                          : () => _pickDate(context, state.watchedOn),
                    ),
                    _Section(title: l10n?.watchLogProgress ?? ''),
                    _Padded(
                      child: _ProgressInput(cubit: cubit, state: state),
                    ),
                    _Section(title: l10n?.watchLogVenue ?? ''),
                    _Padded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final venue in WatchVenue.values)
                            ChoiceChip(
                              label: Text(l10n?.watchVenue(venue) ?? ''),
                              selected: state.venue == venue,
                              onSelected: (_) => cubit.toggleVenue(venue),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Padded(
                      child: TextField(
                        controller: _providerController,
                        maxLength: 255,
                        decoration: InputDecoration(
                          labelText: l10n?.watchLogProvider ?? '',
                          counterText: '',
                        ),
                        onChanged: cubit.setProviderName,
                      ),
                    ),
                    _Section(title: l10n?.watchLogEmotions ?? ''),
                    _Padded(
                      child: MuuvieEmotionPicker(
                        selected: state.emotions,
                        recent: state.recentEmotions,
                        onChanged: cubit.setEmotions,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Padded(
                      child: _GifInput(cubit: cubit, state: state),
                    ),
                    const SizedBox(height: 16),
                    _Padded(
                      child: TextField(
                        controller: _commentController,
                        minLines: 2,
                        maxLines: 6,
                        maxLength: 5000,
                        decoration: InputDecoration(
                          labelText: l10n?.watchLogComment ?? '',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: cubit.setComment,
                      ),
                    ),
                    SwitchListTile(
                      title: Text(l10n?.watchLogSpoiler ?? ''),
                      value: state.hasSpoiler,
                      onChanged: cubit.setSpoiler,
                    ),
                    _Section(title: l10n?.watchLogVisibility ?? ''),
                    _Padded(
                      child: MuuvieVisibilitySelector(
                        value: state.visibility,
                        onChanged: cubit.setVisibility,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: MuuvieButton(
                      onPressed: state.isSaving ? null : () => _save(context),
                      child: state.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n?.watchLogSave ?? ''),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressInput extends StatelessWidget {
  final LogSessionCubit cubit;
  final LogSessionState state;

  const _ProgressInput({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final runtime = cubit.runtime;
    final knownRuntime = runtime != null && runtime > 0 ? runtime : null;

    final minutesLabel = knownRuntime != null
        ? l10n?.movieProgressMinutes(state.minutes, knownRuntime) ?? ''
        : l10n?.watchLogMinutesValue(state.minutes) ?? '';
    final percentLabel = l10n?.watchLogPercentValue(state.percent) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<WatchMode>(
          segments: [
            for (final mode in WatchMode.values)
              ButtonSegment(
                value: mode,
                label: Text(l10n?.watchMode(mode) ?? ''),
              ),
          ],
          selected: {state.mode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => cubit.setMode(selection.single),
        ),
        if (state.mode == WatchMode.minutes) ...[
          Slider(
            value: state.minutes.toDouble(),
            max: cubit.maxMinutes.toDouble(),
            divisions: cubit.maxMinutes,
            label: minutesLabel,
            semanticFormatterCallback: (_) => minutesLabel,
            onChanged: (value) => cubit.setMinutes(value.round()),
          ),
          Text(minutesLabel, textAlign: TextAlign.center),
        ],
        if (state.mode == WatchMode.percent) ...[
          Slider(
            value: state.percent.toDouble(),
            max: 100,
            divisions: 100,
            label: percentLabel,
            semanticFormatterCallback: (_) => percentLabel,
            onChanged: (value) => cubit.setPercent(value.round()),
          ),
          Text(percentLabel, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

class _GifInput extends StatelessWidget {
  final LogSessionCubit cubit;
  final LogSessionState state;

  const _GifInput({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gif = state.gif;

    if (gif == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.gif_box_outlined),
          label: Text(l10n?.watchLogAddGif ?? ''),
          onPressed: () async {
            final picked = await GifPickerSheet.show(context);
            if (picked != null) cubit.setGif(picked);
          },
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: MuuvieRadius.mediumAll,
          child: Semantics(
            label: l10n?.gifLabel ?? '',
            image: true,
            child: CachedNetworkImage(
              imageUrl: gif.previewUrl ?? gif.url,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: l10n?.watchLogRemoveGif ?? '',
          icon: const Icon(Icons.close),
          onPressed: () => cubit.setGif(null),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Semantics(
      header: true,
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

class _Padded extends StatelessWidget {
  final Widget child;

  const _Padded({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}
