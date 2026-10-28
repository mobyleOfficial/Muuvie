import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/diary/diary_bloc.dart';
import 'package:gamification_ui/diary/diary_screen.dart';
import 'package:gamification_ui/diary/diary_state.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';
import 'package:get_it/get_it.dart';
import 'package:stats/stats.dart';

/// The Caderninho do cinéfilo (F10.3): a private diary, over the whole
/// screen. Leaving with unsaved edits asks first.
@RoutePage()
class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late final DiaryCubit _cubit = DiaryCubit(
    getDay: GetIt.I<GetDiaryDay>(),
    saveDay: GetIt.I<SaveDiaryDay>(),
    getMonth: GetIt.I<GetDiaryMonth>(),
    getYear: GetIt.I<GetDiaryYear>(),
    getGoal: GetIt.I<GetYearlyGoal>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  bool get _dirty => switch (_cubit.state) {
    DiaryReady(:final dirty) => dirty,
    _ => false,
  };

  /// Unsaved edits are lost only when the user says so.
  Future<bool> _canLeave() async {
    if (!_dirty) return true;
    final l10n = AppLocalizations.of(context);
    var leave = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.diaryDiscardTitle ?? '',
      content: l10n?.diaryDiscardMessage,
      confirmText: l10n?.diaryDiscard ?? '',
      cancelText: l10n?.maratonaKeep ?? '',
      onConfirm: () => leave = true,
    );
    return leave;
  }

  Future<void> _goTo(DateTime date) async {
    if (await _canLeave()) await _cubit.goTo(date);
  }

  Future<void> _pickDay() async {
    final current = _cubit.state;
    final initial = current is DiaryReady ? current.day.date : _cubit.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: _cubit.today,
    );
    if (picked != null && mounted) await _goTo(picked);
  }

  Future<void> _addTask() async {
    final task = await _TaskDialog.show(context);
    if (task != null) _cubit.addTask(task);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final error = await _cubit.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? l10n?.diarySaved ?? ''
              : l10n?.maratonaSaveError ?? '',
        ),
      ),
    );
  }

  Future<void> _showYear() async {
    final current = _cubit.state;
    final year = current is DiaryReady
        ? current.day.date.year
        : _cubit.today.year;
    final result = await _cubit.year(year);
    if (!mounted || result is! Success<DiaryYear>) return;
    await MuuvieBottomSheet.show<void>(
      context: context,
      builder: (_) => DiaryYearSheet(year: result.data),
    );
  }

  /// Navigator.pop, not maybePop: maybePop would hit the PopScope again and
  /// loop forever.
  Future<void> _close() async {
    if (await _canLeave() && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: MuuvieModalScreen(
        title: l10n?.diaryTitle,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        onClose: _close,
        actions: [
          IconButton(
            tooltip: l10n?.diaryYearTitle,
            icon: const Icon(Icons.insights_outlined),
            onPressed: _showYear,
          ),
        ],
        body: DiaryScreen(
          cubit: _cubit,
          onGoTo: _goTo,
          onPickDay: _pickDay,
          onAddTask: _addTask,
          onSave: _save,
        ),
      ),
    );
  }
}

/// A new goal of the day: category and text.
class _TaskDialog extends StatefulWidget {
  const _TaskDialog();

  static Future<DiaryTask?> show(BuildContext context) => showDialog<DiaryTask>(
    context: context,
    builder: (_) => const _TaskDialog(),
  );

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  final _controller = TextEditingController();
  var _category = DiaryCategory.movie;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.diaryAddGoal ?? ''),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in DiaryCategory.values)
                ChoiceChip(
                  avatar: Icon(category.icon, size: 16),
                  label: Text(category.label(l10n)),
                  selected: category == _category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n?.diaryGoalHint),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => FilledButton(
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(
                    DiaryTask(
                      category: _category,
                      description: _controller.text.trim(),
                    ),
                  ),
            child: Text(l10n?.diaryAdd ?? ''),
          ),
        ),
      ],
    );
  }
}
