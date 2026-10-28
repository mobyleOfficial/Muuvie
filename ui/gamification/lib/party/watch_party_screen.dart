import 'dart:async';

import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/party/watch_party_bloc.dart';
import 'package:gamification_ui/party/watch_party_state.dart';

/// The lobby (create or join with a code) and the room: the code to share,
/// who is in, the countdown and the chat.
class WatchPartyScreen extends StatelessWidget {
  final WatchPartyCubit cubit;
  final String? movieTitle;
  final ValueChanged<String?> onCreate;
  final ValueChanged<String> onJoin;
  final VoidCallback onStart;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onCopyCode;
  final String? Function(AppError error) errorText;

  const WatchPartyScreen({
    super.key,
    required this.cubit,
    this.movieTitle,
    required this.onCreate,
    required this.onJoin,
    required this.onStart,
    required this.onSend,
    required this.onCopyCode,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<WatchPartyCubit, WatchPartyState>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        WatchPartyLobby(:final busy, :final error) => _Lobby(
          busy: busy,
          error: error == null ? null : errorText(error),
          movieTitle: movieTitle,
          onCreate: onCreate,
          onJoin: onJoin,
        ),
        WatchPartyClosed() => MuuvieEmptyState(
          title: l10n?.partyClosed ?? '',
          message: '',
        ),
        WatchPartyRoom(:final party) => _Room(
          party: party,
          onStart: onStart,
          onSend: onSend,
          onCopyCode: onCopyCode,
        ),
      },
    );
  }
}

class _Lobby extends StatefulWidget {
  final bool busy;
  final String? error;
  final String? movieTitle;
  final ValueChanged<String?> onCreate;
  final ValueChanged<String> onJoin;

  const _Lobby({
    required this.busy,
    required this.error,
    required this.movieTitle,
    required this.onCreate,
    required this.onJoin,
  });

  @override
  State<_Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<_Lobby> {
  late final _title = TextEditingController(text: widget.movieTitle);
  final _code = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final error = widget.error;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n?.partyIntro ?? '', style: textTheme.bodyLarge),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(l10n?.partyCreate ?? '', style: textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _title,
          maxLength: 100,
          decoration: InputDecoration(labelText: l10n?.partyFieldTitle),
        ),
        FilledButton(
          onPressed: widget.busy
              ? null
              : () => widget.onCreate(
                  _title.text.trim().isEmpty ? null : _title.text.trim(),
                ),
          child: Text(l10n?.partyCreate ?? ''),
        ),
        const SizedBox(height: 32),
        Semantics(
          header: true,
          child: Text(l10n?.partyJoin ?? '', style: textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _code,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: l10n?.partyFieldCode,
            errorText: error,
          ),
        ),
        ListenableBuilder(
          listenable: _code,
          builder: (context, _) => OutlinedButton(
            onPressed: widget.busy || _code.text.trim().length != 6
                ? null
                : () => widget.onJoin(_code.text.trim()),
            child: Text(l10n?.partyJoin ?? ''),
          ),
        ),
      ],
    );
  }
}

class _Room extends StatefulWidget {
  final WatchParty party;
  final VoidCallback onStart;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onCopyCode;

  const _Room({
    required this.party,
    required this.onStart,
    required this.onSend,
    required this.onCopyCode,
  });

  @override
  State<_Room> createState() => _RoomState();
}

class _RoomState extends State<_Room> {
  final _message = TextEditingController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && widget.party.startAt != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _message.dispose();
    super.dispose();
  }

  void _send() {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final party = widget.party;
    final remaining = party.remaining(DateTime.now().toUtc());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              Text(
                party.title,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => widget.onCopyCode(party.code),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        party.code,
                        semanticsLabel: l10n?.partyCodeLabel(
                          party.code.split('').join(' '),
                        ),
                        style: textTheme.headlineSmall?.copyWith(
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.copy,
                        size: 18,
                        semanticLabel: l10n?.partyCopyCode,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                l10n?.partyMembers(party.members.length) ?? '',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _Countdown(remaining: remaining, isHost: party.isHost),
              if (party.isHost)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton.icon(
                    onPressed: widget.onStart,
                    icon: const Icon(Icons.timer_outlined),
                    label: Text(
                      remaining == null
                          ? l10n?.partyStart ?? ''
                          : l10n?.partyRestart ?? '',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 24),
        Expanded(
          child: party.messages.isEmpty
              ? Center(
                  child: Text(
                    l10n?.partyNoMessages ?? '',
                    style: textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: party.messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        party.messages[party.messages.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${message.user.name}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: message.body),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: l10n?.partyMessageHint,
                      counterText: '',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n?.partySend,
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Countdown extends StatelessWidget {
  final Duration? remaining;
  final bool isHost;

  const _Countdown({required this.remaining, required this.isHost});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final left = remaining;
    if (left == null) {
      return Text(
        (isHost ? l10n?.partyWaitingHost : l10n?.partyWaiting) ?? '',
        style: textTheme.bodyMedium,
      );
    }
    if (left <= Duration.zero) {
      return Semantics(
        liveRegion: true,
        child: Text(
          l10n?.partyPlay ?? '',
          style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }
    final seconds = (left.inMilliseconds / 1000).ceil();
    final text = seconds >= 60
        ? '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'
        : '$seconds';
    return Text(
      text,
      semanticsLabel: l10n?.partySecondsLeft(seconds),
      style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
