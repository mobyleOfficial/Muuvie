import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// What the user chose to join a maratona with.
class JoinChoice {
  final int? levelId;
  final int? teamId;
  final String? password;

  const JoinChoice({this.levelId, this.teamId, this.password});
}

/// Level, team and password before joining (F7.4).
class JoinSheet extends StatefulWidget {
  final Maratona maratona;

  const JoinSheet({super.key, required this.maratona});

  static Future<JoinChoice?> show(BuildContext context, Maratona maratona) =>
      MuuvieBottomSheet.show<JoinChoice>(
        context: context,
        builder: (_) => JoinSheet(maratona: maratona),
      );

  @override
  State<JoinSheet> createState() => _JoinSheetState();
}

class _JoinSheetState extends State<JoinSheet> {
  late int? _levelId = widget.maratona.levels.firstOrNull?.id;
  int? _teamId;
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final maratona = widget.maratona;

    return Material(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n?.maratonaJoinTitle ?? '',
                    style: textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Text(maratona.title, style: textTheme.bodyMedium),
                if (maratona.levels.length > 1) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n?.maratonaJoinLevel ?? '',
                    style: textTheme.titleSmall,
                  ),
                  RadioGroup<int>(
                    groupValue: _levelId,
                    onChanged: (value) => setState(() => _levelId = value),
                    child: Column(
                      children: [
                        for (final level in maratona.levels)
                          RadioListTile<int>(
                            value: level.id,
                            title: Text(level.name),
                            subtitle: Text(
                              l10n?.maratonaChallengesCount(
                                    level.minChallenges,
                                  ) ??
                                  '',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (maratona.teams.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n?.maratonaJoinTeam ?? '',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n?.maratonaNoTeam ?? ''),
                        selected: _teamId == null,
                        onSelected: (_) => setState(() => _teamId = null),
                      ),
                      for (final team in maratona.teams)
                        ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: maratonaColor(context, team.color),
                          ),
                          label: Text(team.name),
                          selected: _teamId == team.id,
                          onSelected: (_) => setState(() => _teamId = team.id),
                        ),
                    ],
                  ),
                ],
                if (maratona.hasPassword) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l10n?.maratonaPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    JoinChoice(
                      levelId: _levelId,
                      teamId: _teamId,
                      password: maratona.hasPassword ? _password.text : null,
                    ),
                  ),
                  child: Text(l10n?.maratonaJoin ?? ''),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
