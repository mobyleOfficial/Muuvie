/// Which push notifications the user wants (F6.7). Everything is on until
/// turned off.
class NotificationPrefs {
  final bool messages;
  final bool newFollowers;
  final bool loves;
  final bool maratonas;
  final bool cineclubes;

  const NotificationPrefs({
    this.messages = true,
    this.newFollowers = true,
    this.loves = true,
    this.maratonas = true,
    this.cineclubes = true,
  });

  NotificationPrefs copyWith({
    bool? messages,
    bool? newFollowers,
    bool? loves,
    bool? maratonas,
    bool? cineclubes,
  }) => NotificationPrefs(
    messages: messages ?? this.messages,
    newFollowers: newFollowers ?? this.newFollowers,
    loves: loves ?? this.loves,
    maratonas: maratonas ?? this.maratonas,
    cineclubes: cineclubes ?? this.cineclubes,
  );
}
