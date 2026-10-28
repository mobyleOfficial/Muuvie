import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';

import 'package:profile_ui/tabs/participations/participations_state.dart';

/// The "Participações" tab: maratonas the profile joined, newest first.
class ParticipationsCubit extends Cubit<ParticipationsState> {
  /// The profile owner, or `me`.
  final String userId;
  final GetMaratonas _getMaratonas;

  ParticipationsCubit({
    required this.userId,
    required GetMaratonas getMaratonas,
  }) : _getMaratonas = getMaratonas,
       super(const ParticipationsLoading());

  MaratonaFilter get _filter => MaratonaFilter(participant: userId);

  Future<void> load() async {
    final result = await _getMaratonas(GetMaratonasParams(filter: _filter));
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => ParticipationsSuccess(
        maratonas: data.maratonas,
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure(:final error) => ParticipationsError(error.message),
    });
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ParticipationsSuccess ||
        !current.hasNext ||
        current.loadingMore) {
      return;
    }
    emit(current.copyWith(loadingMore: true));
    final result = await _getMaratonas(
      GetMaratonasParams(filter: _filter, page: current.page + 1),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => current.copyWith(
        maratonas: [...current.maratonas, ...data.maratonas],
        page: data.page,
        hasNext: data.hasNext,
        loadingMore: false,
      ),
      Failure() => current.copyWith(loadingMore: false),
    });
  }
}
