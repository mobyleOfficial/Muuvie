import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/editor/criteria_sheet.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

const _minChallenges = 3;
final _slugFormat = RegExp(r'^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$');

/// The maratona editor (F7.7) in four steps: details, challenges, levels and
/// teams, prizes and privacy. A new maratona can start from a template
/// (F7.9). After the start, only texts, color, logo, link and prizes change.
class MaratonaEditorScreen extends StatefulWidget {
  /// Null when creating.
  final Maratona? maratona;
  final List<MaratonaTemplate> templates;
  final bool saving;
  final Future<SlugAvailability?> Function(String slug) onCheckSlug;
  final ValueChanged<MaratonaForm> onSave;

  const MaratonaEditorScreen({
    super.key,
    this.maratona,
    this.templates = const [],
    this.saving = false,
    required this.onCheckSlug,
    required this.onSave,
  });

  @override
  State<MaratonaEditorScreen> createState() => _MaratonaEditorScreenState();
}

class _MaratonaEditorScreenState extends State<MaratonaEditorScreen> {
  var _uid = 0;
  late bool _choosingStart = widget.maratona == null;
  var _step = 0;

  late String _title;
  late String _slug;
  String? _description;
  String? _logoUrl;
  String? _accentColor;
  String? _socialLink;
  late DateTime _startsOn;
  late DateTime _endsOn;
  String _password = '';
  bool _removePassword = false;
  List<_Category> _categories = [];
  List<_Level> _levels = [];
  List<_Team> _teams = [];
  List<_Prize> _prizes = [];

  SlugAvailability? _slugStatus;
  Timer? _slugTimer;
  String? _error;

  bool get _isNew => widget.maratona == null;
  bool get _started => widget.maratona?.status == MaratonaStatus.active;

  @override
  void initState() {
    super.initState();
    final maratona = widget.maratona;
    if (maratona != null) {
      _fill(MaratonaForm.of(maratona));
    } else {
      final today = DateUtils.dateOnly(DateTime.now());
      _fill(
        MaratonaForm(
          slug: '',
          title: '',
          startsOn: today,
          endsOn: today.add(const Duration(days: 29)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _slugTimer?.cancel();
    super.dispose();
  }

  void _fill(MaratonaForm form) {
    _title = form.title;
    _slug = form.slug;
    _description = form.description;
    _logoUrl = form.logoUrl;
    _accentColor = form.accentColor;
    _socialLink = form.socialLink;
    _startsOn = form.startsOn;
    _endsOn = form.endsOn;
    _categories = [
      for (final category in form.categories)
        _Category(
          uid: _uid++,
          id: category.id,
          name: category.name,
          teamOnly: category.teamOnly,
          challenges: [
            for (final challenge in category.challenges)
              _Challenge(
                uid: _uid++,
                id: challenge.id,
                description: challenge.description,
                criteria: challenge.criteria,
                daily: challenge.daily,
              ),
          ],
        ),
    ];
    _levels = [
      for (final level in form.levels)
        _Level(
          uid: _uid++,
          id: level.id,
          name: level.name,
          minChallenges: level.minChallenges,
        ),
    ];
    _teams = [
      for (final team in form.teams)
        _Team(uid: _uid++, id: team.id, name: team.name, color: team.color),
    ];
    _prizes = [
      for (final prize in form.prizes)
        _Prize(uid: _uid++, title: prize.title, description: prize.description),
    ];
  }

  void _useTemplate(MaratonaTemplate? template) {
    setState(() {
      _choosingStart = false;
      if (template == null) {
        _categories = [_Category(uid: _uid++, name: '', challenges: [])];
        return;
      }
      final today = DateUtils.dateOnly(DateTime.now());
      _fill(
        MaratonaForm(
          slug: _slugOf(template.title),
          title: template.title,
          description: template.description,
          accentColor: template.accentColor,
          startsOn: today,
          endsOn: today.add(Duration(days: template.days - 1)),
          categories: template.categories,
        ),
      );
      _checkSlug(_slug);
    });
  }

  /// "Volta ao mundo em 30 filmes" → "volta-ao-mundo-em-30-filmes".
  static String _slugOf(String title) {
    const accents = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'é': 'e', 'ê': 'e', //
      'è': 'e', 'í': 'i', 'ì': 'i', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ò': 'o',
      'ú': 'u', 'ü': 'u', 'ù': 'u', 'ç': 'c', 'ñ': 'n',
    };
    final plain = title.toLowerCase().split('').map((c) => accents[c] ?? c);
    final slug = plain
        .join()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.length > 50 ? slug.substring(0, 50) : slug;
  }

  void _checkSlug(String value) {
    _slugTimer?.cancel();
    if (!_isNew) return;
    final slug = value.trim().toLowerCase();
    if (!_slugFormat.hasMatch(slug)) {
      setState(() => _slugStatus = null);
      return;
    }
    _slugTimer = Timer(const Duration(milliseconds: 400), () async {
      final status = await widget.onCheckSlug(slug);
      if (mounted && _slug.trim().toLowerCase() == slug) {
        setState(() => _slugStatus = status);
      }
    });
  }

  int get _totalChallenges => _categories.fold(
    0,
    (total, category) => total + category.challenges.length,
  );

  /// The first problem of the form, or null when it can be saved.
  String? _validate(AppLocalizations? l10n) {
    if (_title.trim().isEmpty) return l10n?.maratonaRequired;
    if (_isNew && !_slugFormat.hasMatch(_slug.trim().toLowerCase())) {
      return l10n?.maratonaSlugInvalid;
    }
    if (_isNew && _slugStatus?.available == false) {
      return l10n?.maratonaSlugTaken;
    }
    if (_endsOn.isBefore(_startsOn)) return l10n?.maratonaPeriodError;
    if (_totalChallenges < _minChallenges) {
      return l10n?.maratonaMinChallengesError(_minChallenges);
    }
    final blank =
        _categories.any((category) => category.name.trim().isEmpty) ||
        _categories.any(
          (category) => category.challenges.any(
            (challenge) => challenge.description.trim().isEmpty,
          ),
        ) ||
        _levels.any((level) => level.name.trim().isEmpty) ||
        _teams.any((team) => team.name.trim().isEmpty) ||
        _prizes.any((prize) => prize.title.trim().isEmpty);
    if (blank) return l10n?.maratonaRequired;
    if (_levels.any(
      (level) =>
          level.minChallenges < 1 || level.minChallenges > _totalChallenges,
    )) {
      return l10n?.maratonaMinChallenges;
    }
    return null;
  }

  String? _optional(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final error = _validate(l10n);
    setState(() => _error = error);
    if (error != null) return;
    widget.onSave(
      MaratonaForm(
        slug: _slug.trim().toLowerCase(),
        title: _title.trim(),
        description: _optional(_description),
        logoUrl: _optional(_logoUrl),
        accentColor: _accentColor,
        startsOn: _startsOn,
        endsOn: _endsOn,
        password: _password.isEmpty ? null : _password,
        removePassword: _removePassword,
        socialLink: _optional(_socialLink),
        categories: [
          for (final category in _categories)
            CategoryForm(
              id: category.id,
              name: category.name.trim(),
              teamOnly: category.teamOnly,
              challenges: [
                for (final challenge in category.challenges)
                  ChallengeForm(
                    id: challenge.id,
                    description: challenge.description.trim(),
                    criteria: challenge.criteria,
                    daily: challenge.daily,
                  ),
              ],
            ),
        ],
        levels: [
          for (final level in _levels)
            LevelForm(
              id: level.id,
              name: level.name.trim(),
              minChallenges: level.minChallenges,
            ),
        ],
        teams: [
          for (final team in _teams)
            TeamForm(id: team.id, name: team.name.trim(), color: team.color),
        ],
        prizes: [
          for (final prize in _prizes)
            PrizeForm(
              title: prize.title.trim(),
              description: _optional(prize.description),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_choosingStart) return _start(context);
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n?.maratonaStepDetails ?? '',
      l10n?.maratonaTabChallenges ?? '',
      l10n?.maratonaStepLevels ?? '',
      l10n?.maratonaStepPrizes ?? '',
    ];
    final last = _step == steps.length - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              for (final (index, step) in steps.indexed)
                Expanded(
                  child: Semantics(
                    selected: index == _step,
                    button: true,
                    child: InkWell(
                      onTap: () => setState(() => _step = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              step,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: index == _step
                                        ? FontWeight.bold
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 3,
                              color: index <= _step
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_started)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n?.maratonaStartedNote ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: ListView(
            key: ValueKey(_step),
            padding: const EdgeInsets.all(16),
            children: switch (_step) {
              0 => _details(context),
              1 => _challenges(context),
              2 => _levelsAndTeams(context),
              _ => _prizesAndPrivacy(context),
            },
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: () => setState(() => _step--),
                    child: Text(l10n?.maratonaBack ?? ''),
                  ),
                const Spacer(),
                if (!last)
                  OutlinedButton(
                    onPressed: () => setState(() => _step++),
                    child: Text(l10n?.maratonaNext ?? ''),
                  ),
                if (last || !_isNew) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: widget.saving ? null : _save,
                    child: widget.saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isNew
                                ? l10n?.maratonaCreate ?? ''
                                : l10n?.maratonaSave ?? '',
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _start(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.edit_note),
            title: Text(l10n?.maratonaEditorFromScratch ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _useTemplate(null),
          ),
        ),
        if (widget.templates.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                l10n?.maratonaEditorTemplates ?? '',
                style: textTheme.titleSmall,
              ),
            ),
          ),
          for (final template in widget.templates)
            Card(
              child: ListTile(
                leading: MaratonaLogo(
                  title: template.title,
                  accentColor: template.accentColor,
                  size: 40,
                ),
                title: Text(template.title),
                subtitle: Text(
                  '${template.description}\n'
                  '${l10n?.maratonaChallengesCount(template.totalChallenges) ?? ''}'
                  ' · ${l10n?.maratonaTemplateDays(template.days) ?? ''}',
                ),
                isThreeLine: true,
                onTap: () => _useTemplate(template),
              ),
            ),
        ],
      ],
    );
  }

  List<Widget> _details(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat.yMMMd(Intl.getCurrentLocale());
    final slugStatus = _slugStatus;

    return [
      TextFormField(
        key: const ValueKey('title'),
        initialValue: _title,
        maxLength: 100,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l10n?.maratonaFieldTitle),
        onChanged: (value) => _title = value,
      ),
      const SizedBox(height: 8),
      TextFormField(
        key: ValueKey('slug-$_uid'),
        initialValue: _slug,
        enabled: _isNew,
        maxLength: 50,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: l10n?.maratonaFieldSlug,
          helperText: l10n?.maratonaSlugHelp(_slug.isEmpty ? '…' : _slug),
          suffixIcon: slugStatus == null || !_isNew
              ? null
              : Icon(
                  slugStatus.available ? Icons.check_circle : Icons.error,
                  semanticLabel: slugStatus.available
                      ? l10n?.maratonaSlugAvailable
                      : l10n?.maratonaSlugTaken,
                  color: slugStatus.available
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
        ),
        onChanged: (value) {
          setState(() => _slug = value);
          _checkSlug(value);
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        key: const ValueKey('description'),
        initialValue: _description,
        maxLength: 2000,
        minLines: 3,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l10n?.maratonaFieldDescription),
        onChanged: (value) => _description = value,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _DateField(
              label: l10n?.maratonaFieldStart ?? '',
              value: format.format(_startsOn),
              onTap: _started ? null : () => _pickDate(start: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DateField(
              label: l10n?.maratonaFieldEnd ?? '',
              value: format.format(_endsOn),
              onTap: _started ? null : () => _pickDate(start: false),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        l10n?.maratonaFieldColor ?? '',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 8),
      MuuvieColorPicker(
        selected: MuuvieColorPicker.fromHex(_accentColor),
        onChanged: (color) =>
            setState(() => _accentColor = MuuvieColorPicker.toHex(color)),
      ),
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('logo'),
        initialValue: _logoUrl,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(labelText: l10n?.maratonaFieldLogo),
        onChanged: (value) => _logoUrl = value,
      ),
      const SizedBox(height: 12),
      TextFormField(
        key: const ValueKey('social'),
        initialValue: _socialLink,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(labelText: l10n?.maratonaFieldSocial),
        onChanged: (value) => _socialLink = value,
      ),
    ];
  }

  Future<void> _pickDate({required bool start}) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = start ? _startsOn : _endsOn;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: start ? today.subtract(const Duration(days: 365)) : _startsOn,
      lastDate: today.add(const Duration(days: 365 * 3)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _startsOn = picked;
        if (_endsOn.isBefore(picked)) _endsOn = picked;
      } else {
        _endsOn = picked;
      }
    });
  }

  List<Widget> _challenges(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locked = _started;

    return [
      Text(
        l10n?.maratonaChallengesCount(_totalChallenges) ?? '',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 8),
      for (final category in _categories)
        Card(
          key: ValueKey('category-${category.uid}'),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: category.name,
                        enabled: !locked,
                        maxLength: 80,
                        decoration: InputDecoration(
                          labelText: l10n?.maratonaCategoryName,
                        ),
                        onChanged: (value) => category.name = value,
                      ),
                    ),
                    if (!locked)
                      IconButton(
                        tooltip: l10n?.maratonaRemove,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            setState(() => _categories.remove(category)),
                      ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n?.maratonaTeamOnly ?? ''),
                  value: category.teamOnly,
                  onChanged: locked
                      ? null
                      : (value) => setState(() => category.teamOnly = value),
                ),
                for (final challenge in category.challenges)
                  _ChallengeEditor(
                    key: ValueKey('challenge-${challenge.uid}'),
                    challenge: challenge,
                    locked: locked,
                    onEditCriteria: () async {
                      final choice = await CriteriaSheet.show(
                        context,
                        challenge.criteria,
                      );
                      if (choice != null && mounted) {
                        setState(() => challenge.criteria = choice.criteria);
                      }
                    },
                    onDaily: (value) => setState(() => challenge.daily = value),
                    onRemove: () =>
                        setState(() => category.challenges.remove(challenge)),
                  ),
                if (!locked)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(
                        () => category.challenges.add(
                          _Challenge(uid: _uid++, description: ''),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(l10n?.maratonaAddChallenge ?? ''),
                    ),
                  ),
              ],
            ),
          ),
        ),
      if (!locked)
        OutlinedButton.icon(
          onPressed: () => setState(
            () => _categories.add(
              _Category(
                uid: _uid++,
                name: '',
                challenges: [_Challenge(uid: _uid++, description: '')],
              ),
            ),
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n?.maratonaAddCategory ?? ''),
        ),
    ];
  }

  List<Widget> _levelsAndTeams(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locked = _started;

    return [
      Semantics(
        header: true,
        child: Text(l10n?.maratonaLevels ?? '', style: textTheme.titleSmall),
      ),
      if (_levels.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l10n?.maratonaDefaultLevel ?? '',
            style: textTheme.bodySmall,
          ),
        ),
      for (final level in _levels)
        Row(
          key: ValueKey('level-${level.uid}'),
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: level.name,
                enabled: !locked,
                maxLength: 50,
                decoration: InputDecoration(labelText: l10n?.maratonaLevelName),
                onChanged: (value) => level.name = value,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: '${level.minChallenges}',
                enabled: !locked,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n?.maratonaMinChallenges,
                ),
                onChanged: (value) =>
                    level.minChallenges = int.tryParse(value) ?? 0,
              ),
            ),
            if (!locked)
              IconButton(
                tooltip: l10n?.maratonaRemove,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _levels.remove(level)),
              ),
          ],
        ),
      if (!locked)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(
              () => _levels.add(
                _Level(
                  uid: _uid++,
                  name: '',
                  minChallenges: _totalChallenges.clamp(1, 200),
                ),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n?.maratonaAddLevel ?? ''),
          ),
        ),
      const SizedBox(height: 16),
      Semantics(
        header: true,
        child: Text(l10n?.maratonaTeams ?? '', style: textTheme.titleSmall),
      ),
      for (final team in _teams)
        Padding(
          key: ValueKey('team-${team.uid}'),
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: team.name,
                      enabled: !locked,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: l10n?.maratonaTeamName,
                      ),
                      onChanged: (value) => team.name = value,
                    ),
                  ),
                  if (!locked)
                    IconButton(
                      tooltip: l10n?.maratonaRemove,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _teams.remove(team)),
                    ),
                ],
              ),
              if (!locked)
                MuuvieColorPicker(
                  selected: MuuvieColorPicker.fromHex(team.color),
                  onChanged: (color) => setState(
                    () => team.color = MuuvieColorPicker.toHex(color),
                  ),
                ),
            ],
          ),
        ),
      if (!locked)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () =>
                setState(() => _teams.add(_Team(uid: _uid++, name: ''))),
            icon: const Icon(Icons.add),
            label: Text(l10n?.maratonaAddTeam ?? ''),
          ),
        ),
    ];
  }

  List<Widget> _prizesAndPrivacy(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final hadPassword = widget.maratona?.hasPassword ?? false;

    return [
      Semantics(
        header: true,
        child: Text(l10n?.maratonaPrizes ?? '', style: textTheme.titleSmall),
      ),
      for (final prize in _prizes)
        Card(
          key: ValueKey('prize-${prize.uid}'),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 4, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: prize.title,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: l10n?.maratonaPrizeTitle,
                        ),
                        onChanged: (value) => prize.title = value,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n?.maratonaRemove,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _prizes.remove(prize)),
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: prize.description,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: l10n?.maratonaFieldDescription,
                  ),
                  onChanged: (value) => prize.description = value,
                ),
              ],
            ),
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () =>
              setState(() => _prizes.add(_Prize(uid: _uid++, title: ''))),
          icon: const Icon(Icons.add),
          label: Text(l10n?.maratonaAddPrize ?? ''),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('password'),
        obscureText: true,
        enabled: !_removePassword,
        decoration: InputDecoration(
          labelText: l10n?.maratonaFieldPassword,
          helperText: hadPassword ? l10n?.maratonaKeepPassword : null,
          prefixIcon: const Icon(Icons.lock_outline),
        ),
        onChanged: (value) => _password = value,
      ),
      if (hadPassword)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n?.maratonaRemovePassword ?? ''),
          value: _removePassword,
          onChanged: (value) => setState(() => _removePassword = value),
        ),
    ];
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DateField({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      isEmpty: false,
      decoration: InputDecoration(
        labelText: label,
        enabled: onTap != null,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(value),
    ),
  );
}

class _ChallengeEditor extends StatelessWidget {
  final _Challenge challenge;
  final bool locked;
  final VoidCallback onEditCriteria;
  final ValueChanged<bool> onDaily;
  final VoidCallback onRemove;

  const _ChallengeEditor({
    super.key,
    required this.challenge,
    required this.locked,
    required this.onEditCriteria,
    required this.onDaily,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8, right: 8),
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: challenge.description,
                  enabled: !locked,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n?.maratonaChallengeDescription,
                  ),
                  onChanged: (value) => challenge.description = value,
                ),
              ),
              if (!locked)
                IconButton(
                  tooltip: l10n?.maratonaRemove,
                  icon: const Icon(Icons.close),
                  onPressed: onRemove,
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ActionChip(
                avatar: Icon(
                  challenge.criteria != null
                      ? Icons.auto_awesome
                      : Icons.touch_app_outlined,
                  size: 18,
                ),
                label: Text(
                  challenge.criteria != null
                      ? l10n?.maratonaChallengeAuto ?? ''
                      : l10n?.maratonaCriteriaNone ?? '',
                ),
                onPressed: locked ? null : onEditCriteria,
              ),
              FilterChip(
                label: Text(l10n?.maratonaChallengeDaily ?? ''),
                selected: challenge.daily,
                onSelected: locked ? null : onDaily,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Category {
  final int uid;
  final int? id;
  String name;
  bool teamOnly;
  final List<_Challenge> challenges;

  _Category({
    required this.uid,
    this.id,
    required this.name,
    this.teamOnly = false,
    required this.challenges,
  });
}

class _Challenge {
  final int uid;
  final int? id;
  String description;
  ChallengeCriteria? criteria;
  bool daily;

  _Challenge({
    required this.uid,
    this.id,
    required this.description,
    this.criteria,
    this.daily = false,
  });
}

class _Level {
  final int uid;
  final int? id;
  String name;
  int minChallenges;

  _Level({
    required this.uid,
    this.id,
    required this.name,
    required this.minChallenges,
  });
}

class _Team {
  final int uid;
  final int? id;
  String name;
  String? color;

  _Team({required this.uid, this.id, required this.name, this.color});
}

class _Prize {
  final int uid;
  String title;
  String? description;

  _Prize({required this.uid, required this.title, this.description});
}
