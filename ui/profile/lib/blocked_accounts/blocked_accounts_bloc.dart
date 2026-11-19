import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network/social_network.dart';

sealed class BlockedAccountsState {
  const BlockedAccountsState();
}

class BlockedAccountsLoading extends BlockedAccountsState {
  const BlockedAccountsLoading();
}

class BlockedAccountsError extends BlockedAccountsState {
  const BlockedAccountsError();
}

/// The accounts blocked so far; [busy] holds the ids being unblocked.
class BlockedAccountsReady extends BlockedAccountsState {
  final List<BlockedUser> users;
  final bool hasNext;
  final int page;
  final Set<String> busy;

  const BlockedAccountsReady({
    required this.users,
    required this.hasNext,
    required this.page,
    this.busy = const {},
  });

  BlockedAccountsReady copyWith({
    List<BlockedUser>? users,
    bool? hasNext,
    int? page,
    Set<String>? busy,
  }) => BlockedAccountsReady(
    users: users ?? this.users,
    hasNext: hasNext ?? this.hasNext,
    page: page ?? this.page,
    busy: busy ?? this.busy,
  );
}

/// Configurações › Contas bloqueadas: lists the blocked accounts and unblocks them.
class BlockedAccountsCubit extends Cubit<BlockedAccountsState> {
  final GetBlockedUsers _getBlockedUsers;
  final SetBlocked _setBlocked;

  BlockedAccountsCubit({
    required GetBlockedUsers getBlockedUsers,
    required SetBlocked setBlocked,
  }) : _getBlockedUsers = getBlockedUsers,
       _setBlocked = setBlocked,
       super(const BlockedAccountsLoading());

  Future<void> load() async {
    emit(const BlockedAccountsLoading());
    final result = await _getBlockedUsers(1);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => BlockedAccountsReady(
        users: data.users,
        hasNext: data.hasNext,
        page: data.page,
      ),
      Failure() => const BlockedAccountsError(),
    });
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! BlockedAccountsReady || !current.hasNext) return;
    final result = await _getBlockedUsers(current.page + 1);
    if (isClosed) return;
    if (result case Success(:final data)) {
      final latest = state;
      if (latest is! BlockedAccountsReady) return;
      emit(
        latest.copyWith(
          users: [...latest.users, ...data.users],
          hasNext: data.hasNext,
          page: data.page,
        ),
      );
    }
  }

  /// Answers the error when the server refused it; the row stays then.
  Future<AppError?> unblock(String userId) async {
    final current = state;
    if (current is! BlockedAccountsReady || current.busy.contains(userId)) {
      return null;
    }
    emit(current.copyWith(busy: {...current.busy, userId}));
    final result = await _setBlocked(
      SetBlockedParams(userId: userId, blocked: false),
    );
    if (isClosed) return null;
    final latest = state;
    if (latest is! BlockedAccountsReady) return null;
    final busy = {...latest.busy}..remove(userId);
    switch (result) {
      case Success():
        emit(
          latest.copyWith(
            users: latest.users.where((row) => row.user.id != userId).toList(),
            busy: busy,
          ),
        );
        return null;
      case Failure(:final error):
        emit(latest.copyWith(busy: busy));
        return error;
    }
  }
}
