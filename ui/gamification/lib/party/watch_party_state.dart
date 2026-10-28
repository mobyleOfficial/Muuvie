import 'package:core/core.dart';
import 'package:gamification/gamification.dart';

sealed class WatchPartyState {
  const WatchPartyState();
}

/// Not in a room yet: create one or join with a code. [error] is the last
/// failure (an unknown code, a full room).
class WatchPartyLobby extends WatchPartyState {
  final bool busy;
  final AppError? error;

  const WatchPartyLobby({this.busy = false, this.error});
}

class WatchPartyRoom extends WatchPartyState {
  final WatchParty party;

  const WatchPartyRoom(this.party);
}

/// The host closed the room, or it expired.
class WatchPartyClosed extends WatchPartyState {
  const WatchPartyClosed();
}
