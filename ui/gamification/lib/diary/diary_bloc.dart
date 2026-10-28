import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/diary/diary_state.dart';
import 'package:stats/stats.dart';

/// The Caderninho (F10.3): the mood of the day, up to six goals and a note.
/// Opening a day never saves it; only [save] does, and an empty day is
/// deleted by the server.
class DiaryCubit extends Cubit<DiaryState> {
  final GetDiaryDay _getDay;
  final SaveDiaryDay _saveDay;
  final GetDiaryMonth _getMonth;
  final GetDiaryYear _getYear;
  final GetYearlyGoal _getGoal;
  final DateTime Function() _now;

  DiaryCubit({
    required GetDiaryDay getDay,
    required SaveDiaryDay saveDay,
    required GetDiaryMonth getMonth,
    required GetDiaryYear getYear,
    required GetYearlyGoal getGoal,
    DateTime Function()? now,
  }) : _getDay = getDay,
       _saveDay = saveDay,
       _getMonth = getMonth,
       _getYear = getYear,
       _getGoal = getGoal,
       _now = now ?? DateTime.now,
       super(const DiaryLoading());

  DateTime get today {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> load([DateTime? date]) async {
    final day = date ?? today;
    final previous = state;
    final results = await Future.wait([
      _getDay(day),
      _getMonth(DiaryMonthParams(year: day.year, month: day.month)),
      if (previous is! DiaryReady || previous.day.date.year != day.year)
        _getGoal(StatsYearParams(userId: 'me', year: day.year)),
    ]);
    if (isClosed) return;
    final result = results[0] as Result<DiaryDay>;
    final month = results[1] as Result<List<DiaryDaySummary>>;
    final goal = results.length > 2
        ? switch (results[2] as Result<YearlyGoal>) {
            Success(:final data) => data,
            Failure() => null,
          }
        : (previous as DiaryReady).goal;
    emit(switch (result) {
      Success(:final data) => DiaryReady(
        day: data,
        month: switch (month) {
          Success(data: final days) => days,
          Failure() => const [],
        },
        goal: goal,
      ),
      Failure() => const DiaryError(),
    });
  }

  Future<void> goTo(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isAfter(today)) return Future.value();
    return load(day);
  }

  void setMood(DiaryMood? mood) => _edit(
    (day) => DiaryDay(
      date: day.date,
      mood: day.mood == mood ? null : mood,
      note: day.note,
      tasks: day.tasks,
      saved: day.saved,
    ),
  );

  void setNote(String note) => _edit(
    (day) => DiaryDay(
      date: day.date,
      mood: day.mood,
      note: note.trim().isEmpty ? null : note,
      tasks: day.tasks,
      saved: day.saved,
    ),
  );

  void addTask(DiaryTask task) => _tasks((tasks) {
    if (tasks.length < DiaryDay.maxTasks) tasks.add(task);
  });

  void toggleTask(int index) => _tasks(
    (tasks) => tasks[index] = tasks[index].copyWith(done: !tasks[index].done),
  );

  void removeTask(int index) => _tasks((tasks) => tasks.removeAt(index));

  void moveTask(int from, int to) => _tasks((tasks) {
    final task = tasks.removeAt(from);
    tasks.insert(to.clamp(0, tasks.length), task);
  });

  /// Saves the day; answers the error, or null when it worked.
  Future<AppError?> save() async {
    final current = state;
    if (current is! DiaryReady) return null;
    emit(current.copyWith(saving: true));
    final result = await _saveDay(current.day);
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        final month = await _getMonth(
          DiaryMonthParams(year: data.date.year, month: data.date.month),
        );
        if (isClosed) return null;
        final latest = state is DiaryReady ? state as DiaryReady : current;
        emit(
          latest.copyWith(
            day: data,
            dirty: false,
            saving: false,
            month: switch (month) {
              Success(data: final days) => days,
              Failure() => latest.month,
            },
          ),
        );
        return null;
      case Failure(:final error):
        emit(current.copyWith(saving: false));
        return error;
    }
  }

  Future<Result<DiaryYear>> year(int year) => _getYear(year);

  void _tasks(void Function(List<DiaryTask> tasks) change) => _edit((day) {
    final tasks = [...day.tasks];
    change(tasks);
    return DiaryDay(
      date: day.date,
      mood: day.mood,
      note: day.note,
      tasks: tasks,
      saved: day.saved,
    );
  });

  void _edit(DiaryDay Function(DiaryDay day) change) {
    final current = state;
    if (current is! DiaryReady) return;
    emit(current.copyWith(day: change(current.day), dirty: true));
  }
}
