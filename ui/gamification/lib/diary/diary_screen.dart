import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/diary/diary_bloc.dart';
import 'package:gamification_ui/diary/diary_state.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';
import 'package:intl/intl.dart';

/// A day of the Caderninho: the days of the month, the yearly goal, the
/// mood, the goals (checked, reordered, removed) and the note.
class DiaryScreen extends StatelessWidget {
  final DiaryCubit cubit;
  final ValueChanged<DateTime> onGoTo;
  final VoidCallback onPickDay;
  final VoidCallback onAddTask;
  final VoidCallback onSave;

  const DiaryScreen({
    super.key,
    required this.cubit,
    required this.onGoTo,
    required this.onPickDay,
    required this.onAddTask,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<DiaryCubit, DiaryState>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        DiaryLoading() => const Center(child: MuuvieActivityIndicator()),
        DiaryError() => MuuvieEmptyState(
          illustration: MuuvieIllustration.error,
          title: l10n?.emptyStateErrorTitle ?? '',
          message: l10n?.emptyStateErrorMessage ?? '',
          action: cubit.load,
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        final DiaryReady ready => _Day(
          state: ready,
          today: cubit.today,
          cubit: cubit,
          onGoTo: onGoTo,
          onPickDay: onPickDay,
          onAddTask: onAddTask,
          onSave: onSave,
        ),
      },
    );
  }
}

class _Day extends StatelessWidget {
  final DiaryReady state;
  final DateTime today;
  final DiaryCubit cubit;
  final ValueChanged<DateTime> onGoTo;
  final VoidCallback onPickDay;
  final VoidCallback onAddTask;
  final VoidCallback onSave;

  const _Day({
    required this.state,
    required this.today,
    required this.cubit,
    required this.onGoTo,
    required this.onPickDay,
    required this.onAddTask,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final day = state.day;
    final date = day.date;
    final isToday = date == today;
    final goal = state.goal;
    final locale = Intl.getCurrentLocale();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n?.diaryPreviousDay,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onGoTo(date.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: TextButton(
                onPressed: onPickDay,
                child: Text(
                  isToday
                      ? l10n?.diaryToday ?? ''
                      : DateFormat.yMMMMEEEEd(locale).format(date),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n?.diaryNextDay,
              icon: const Icon(Icons.chevron_right),
              onPressed: isToday
                  ? null
                  : () => onGoTo(date.add(const Duration(days: 1))),
            ),
          ],
        ),
        _MonthStrip(
          date: date,
          today: today,
          month: state.month,
          onTap: onGoTo,
        ),
        if (goal != null)
          Card(
            margin: const EdgeInsets.only(top: 12),
            child: ListTile(
              leading: Icon(
                goal.reached ? Icons.emoji_events : Icons.flag_outlined,
              ),
              title: Text(
                l10n?.chartsGoalProgress(
                      goal.watched,
                      goal.targetMovies,
                      '${goal.year}',
                    ) ??
                    '',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(l10n?.diaryMood ?? '', style: textTheme.titleSmall),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final mood in DiaryMood.values)
              _MoodButton(
                mood: mood,
                selected: day.mood == mood,
                onTap: () => cubit.setMood(mood),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n?.diaryGoals(day.tasks.length, DiaryDay.maxTasks) ?? '',
                  style: textTheme.titleSmall,
                ),
              ),
            ),
            if (day.tasks.length < DiaryDay.maxTasks)
              TextButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: Text(l10n?.diaryAddGoal ?? ''),
              ),
          ],
        ),
        if (day.tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n?.diaryNoGoals ?? '', style: textTheme.bodySmall),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: cubit.moveTask,
            children: [
              for (final (index, task) in day.tasks.indexed)
                ListTile(
                  key: ValueKey('task-$index-${task.description}'),
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: task.done,
                    onChanged: (_) => cubit.toggleTask(index),
                  ),
                  title: Text(
                    task.description,
                    style: task.done
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  subtitle: Row(
                    children: [
                      Icon(task.category.icon, size: 14),
                      const SizedBox(width: 4),
                      Text(task.category.label(l10n)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n?.maratonaRemove,
                        icon: const Icon(Icons.close),
                        onPressed: () => cubit.removeTask(index),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Semantics(
                          label: l10n?.diaryReorder,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(l10n?.diaryNote ?? '', style: textTheme.titleSmall),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('note-$date'),
          initialValue: day.note,
          minLines: 3,
          maxLines: 10,
          maxLength: 5000,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l10n?.diaryNoteHint),
          onChanged: cubit.setNote,
        ),
        Text(l10n?.diaryPrivate ?? '', style: textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: state.dirty && !state.saving ? onSave : null,
          child: Text(l10n?.cineclubeSave ?? ''),
        ),
      ],
    );
  }
}

class _MoodButton extends StatelessWidget {
  final DiaryMood mood;
  final bool selected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: mood.label(l10n),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            border: selected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: ExcludeSemantics(
            child: Text(mood.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
    );
  }
}

/// The days of the month with their mood; tapping one opens it.
class _MonthStrip extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final List<DiaryDaySummary> month;
  final ValueChanged<DateTime> onTap;

  const _MonthStrip({
    required this.date,
    required this.today,
    required this.month,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final days = DateUtils.getDaysInMonth(date.year, date.month);
    final written = {for (final day in month) day.date.day: day};

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days,
        controller: ScrollController(
          initialScrollOffset: ((date.day - 4).clamp(0, days) * 44).toDouble(),
        ),
        itemBuilder: (context, index) {
          final day = DateTime(date.year, date.month, index + 1);
          final summary = written[index + 1];
          final future = day.isAfter(today);
          final selected = day == date;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(MuuvieRadius.small),
              onTap: future ? null : () => onTap(day),
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  color: selected ? colorScheme.primaryContainer : null,
                  borderRadius: BorderRadius.circular(MuuvieRadius.small),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: future
                            ? colorScheme.outline
                            : selected
                            ? colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      summary?.mood?.emoji ?? (summary != null ? '•' : ' '),
                      style: TextStyle(
                        color: selected ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The year of moods (F10.3): how many days of each mood per month.
class DiaryYearSheet extends StatelessWidget {
  final DiaryYear year;

  const DiaryYearSheet({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Intl.getCurrentLocale();
    final top = year.topMood;

    return Material(
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n?.diaryYearOf('${year.year}') ?? '',
                style: textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              top == null
                  ? l10n?.diaryYearDays(year.days) ?? ''
                  : '${l10n?.diaryYearDays(year.days) ?? ''} · ${l10n?.diaryYearTop(top.label(l10n)) ?? ''} ${top.emoji}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            for (final (index, moods) in year.months.indexed)
              if (moods.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    DateFormat.MMMM(
                      locale,
                    ).format(DateTime(year.year, index + 1)),
                  ),
                  subtitle: Text(
                    [
                      for (final mood in DiaryMood.values)
                        if ((moods[mood] ?? 0) > 0)
                          '${mood.emoji} ${moods[mood]}',
                    ].join('   '),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
