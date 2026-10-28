import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/party/watch_party_state.dart';

/// A watch party (F10.4): the lobby, then the room, read again whenever the
/// WebSocket says something changed.
class WatchPartyCubit extends Cubit<WatchPartyState> {
  final WatchPartyActions _actions;
  StreamSubscription<PartyEvent>? _events;

  WatchPartyCubit({required WatchPartyActions actions})
    : _actions = actions,
      super(const WatchPartyLobby());

  WatchParty? get _party => switch (state) {
    WatchPartyRoom(:final party) => party,
    _ => null,
  };

  Future<void> create({String? title, int? movieId}) =>
      _enter(() => _actions.create(title: title, movieId: movieId));

  Future<void> join(String code) => _enter(() => _actions.join(code));

  Future<void> refresh() async {
    final party = _party;
    if (party == null) return;
    final result = await _actions.get(party.code);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(WatchPartyRoom(data));
      case Failure(:final error):
        if (error == AppError.notFound || error == AppError.forbidden) {
          await _events?.cancel();
          emit(const WatchPartyClosed());
        }
    }
  }

  Future<AppError?> start(int inSeconds) =>
      _act((code) => _actions.start(code, inSeconds));

  Future<AppError?> send(String body) =>
      _act((code) => _actions.send(code, body));

  Future<void> leave() async {
    final party = _party;
    await _events?.cancel();
    if (party != null) await _actions.leave(party.code);
  }

  Future<void> _enter(Future<Result<WatchParty>> Function() action) async {
    emit(const WatchPartyLobby(busy: true));
    final result = await action();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(WatchPartyRoom(data));
        await _events?.cancel();
        _events = _actions.events(data.code).listen((event) {
          if (event.event == 'closed') {
            _events?.cancel();
            emit(const WatchPartyClosed());
          } else {
            refresh();
          }
        });
      case Failure(:final error):
        emit(WatchPartyLobby(error: error));
    }
  }

  Future<AppError?> _act(
    Future<Result<WatchParty>> Function(String code) action,
  ) async {
    final party = _party;
    if (party == null) return null;
    final result = await action(party.code);
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        emit(WatchPartyRoom(data));
        return null;
      case Failure(:final error):
        return error;
    }
  }

  @override
  Future<void> close() async {
    await _events?.cancel();
    return super.close();
  }
}
