import 'dart:async';

import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/editor/movie_search_sheet.dart';
import 'package:cineclubes_ui/widgets/cineclube_labels.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';

final _slugFormat = RegExp(r'^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$');
const _maxSessions = 52;
const _defaultSessionDays = 7;

/// The CineClube editor (F8.5): details, the sessions (one movie, or a
/// cycle with one movie each, F8.6), links and password. Sessions that
/// already started stay as they are.
class CineClubeEditorScreen extends StatefulWidget {
  /// Null when creating.
  final CineClube? cineclube;

  /// The movie of the first session of a new CineClube.
  final CineClubeMovie? initialMovie;
  final bool saving;
  final SearchMovies searchMovies;
  final Future<CineClubeSlug?> Function(String slug) onCheckSlug;
  final ValueChanged<CineClubeForm> onSave;

  const CineClubeEditorScreen({
    super.key,
    this.cineclube,
    this.initialMovie,
    this.saving = false,
    required this.searchMovies,
    required this.onCheckSlug,
    required this.onSave,
  });

  @override
  State<CineClubeEditorScreen> createState() => _CineClubeEditorScreenState();
}

class _CineClubeEditorScreenState extends State<CineClubeEditorScreen> {
  var _uid = 0;
  late String _title;
  late String _slug;
  String? _description;
  String? _accentColor;
  String? _debateLink;
  String? _socialLink;
  String _password = '';
  bool _removePassword = false;
  late List<_Session> _sessions;

  CineClubeSlug? _slugStatus;
  Timer? _slugTimer;
  String? _error;

  final _today = DateUtils.dateOnly(DateTime.now());

  bool get _isNew => widget.cineclube == null;

  @override
  void initState() {
    super.initState();
    final cineclube = widget.cineclube;
    final form = cineclube == null
        ? const CineClubeForm(slug: '', title: '')
        : CineClubeForm.of(cineclube);
    _title = form.title;
    _slug = form.slug;
    _description = form.description;
    _accentColor = form.accentColor;
    _debateLink = form.debateLink;
    _socialLink = form.socialLink;
    _sessions = [
      for (final session in form.sessions)
        _Session(
          uid: _uid++,
          id: session.id,
          movie: session.movie,
          startsOn: session.startsOn,
          endsOn: session.endsOn,
          debateOn: session.debateOn,
          locked: !session.startsOn.isAfter(_today),
        ),
    ];
    if (_sessions.isEmpty) {
      _sessions = [_newSession(_today)..movie = widget.initialMovie];
    }
  }

  @override
  void dispose() {
    _slugTimer?.cancel();
    super.dispose();
  }

  _Session _newSession(DateTime start) {
    final end = start.add(const Duration(days: _defaultSessionDays - 1));
    return _Session(uid: _uid++, startsOn: start, endsOn: end, debateOn: end);
  }

  void _addSession() {
    final last = _sessions
        .map((s) => s.endsOn)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    var start = last.add(const Duration(days: 1));
    if (!_isNew && !start.isAfter(_today)) {
      start = _today.add(const Duration(days: 1));
    }
    setState(() => _sessions.add(_newSession(start)));
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

  /// The first problem of the form, or null when it can be saved.
  String? _validate(AppLocalizations? l10n) {
    if (_title.trim().isEmpty) return l10n?.maratonaRequired;
    if (_isNew && !_slugFormat.hasMatch(_slug.trim().toLowerCase())) {
      return l10n?.maratonaSlugInvalid;
    }
    if (_isNew && _slugStatus?.available == false) {
      return l10n?.maratonaSlugTaken;
    }
    if (_sessions.any((session) => session.movie == null)) {
      return l10n?.cineclubeMovieRequired;
    }
    if (_sessions.any(
      (s) => s.endsOn.isBefore(s.startsOn) || s.debateOn.isBefore(s.startsOn),
    )) {
      return l10n?.maratonaPeriodError;
    }
    final ordered = [..._sessions]
      ..sort((a, b) => a.startsOn.compareTo(b.startsOn));
    for (var i = 1; i < ordered.length; i++) {
      if (!ordered[i].startsOn.isAfter(ordered[i - 1].endsOn)) {
        return l10n?.cineclubeOverlapError;
      }
    }
    if (!_isNew &&
        _sessions.any((s) => !s.locked && !s.startsOn.isAfter(_today))) {
      return l10n?.cineclubeFutureSessionError;
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
      CineClubeForm(
        slug: _slug.trim().toLowerCase(),
        title: _title.trim(),
        description: _optional(_description),
        accentColor: _accentColor,
        password: _password.isEmpty ? null : _password,
        removePassword: _removePassword,
        debateLink: _optional(_debateLink),
        socialLink: _optional(_socialLink),
        sessions: [
          for (final session in _sessions)
            SessionForm(
              id: session.id,
              movie: session.movie!,
              startsOn: session.startsOn,
              endsOn: session.endsOn,
              debateOn: session.debateOn,
            ),
        ],
      ),
    );
  }

  Future<void> _pickMovie(_Session session) async {
    final movie = await MovieSearchSheet.show(context, widget.searchMovies);
    if (movie == null || !mounted) return;
    setState(() => session.movie = movie);
  }

  Future<void> _pickDate(_Session session, _Day day) async {
    final initial = switch (day) {
      _Day.start => session.startsOn,
      _Day.end => session.endsOn,
      _Day.debate => session.debateOn,
    };
    final first = switch (day) {
      _Day.start => _isNew ? _today : _today.add(const Duration(days: 1)),
      _ => session.startsOn,
    };
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: _today.add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      switch (day) {
        case _Day.start:
          final length = session.endsOn.difference(session.startsOn);
          final debateGap = session.debateOn.difference(session.endsOn);
          session.startsOn = picked;
          session.endsOn = picked.add(length);
          session.debateOn = session.endsOn.add(debateGap);
        case _Day.end:
          final followsEnd = session.debateOn == session.endsOn;
          session.endsOn = picked;
          if (followsEnd || session.debateOn.isBefore(picked)) {
            session.debateOn = picked;
          }
        case _Day.debate:
          session.debateOn = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final slugStatus = _slugStatus;
    final hadPassword = widget.cineclube?.hasPassword ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        TextFormField(
          initialValue: _title,
          maxLength: 100,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n?.maratonaFieldTitle),
          onChanged: (value) => _title = value,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _slug,
          enabled: _isNew,
          maxLength: 50,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n?.maratonaFieldSlug,
            helperText: l10n?.cineclubeSlugHelp(_slug.isEmpty ? '…' : _slug),
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
          initialValue: _description,
          maxLength: 2000,
          minLines: 2,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n?.maratonaFieldDescription,
          ),
          onChanged: (value) => _description = value,
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            _sessions.length > 1
                ? l10n?.cineclubeSessions ?? ''
                : l10n?.cineclubeMovieAndDates ?? '',
            style: textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        for (final (index, session) in _sessions.indexed)
          _SessionCard(
            key: ValueKey('session-${session.uid}'),
            session: session,
            number: _sessions.length > 1 ? index + 1 : null,
            onPickMovie: () => _pickMovie(session),
            onPickDate: (day) => _pickDate(session, day),
            onRemove: _sessions.length > 1 && !session.locked
                ? () => setState(() => _sessions.remove(session))
                : null,
          ),
        if (_sessions.length < _maxSessions)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addSession,
              icon: const Icon(Icons.add),
              label: Text(l10n?.cineclubeAddSession ?? ''),
            ),
          ),
        Text(l10n?.cineclubeCycleHelp ?? '', style: textTheme.bodySmall),
        const SizedBox(height: 16),
        Text(l10n?.maratonaFieldColor ?? '', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        MuuvieColorPicker(
          selected: MuuvieColorPicker.fromHex(_accentColor),
          onChanged: (color) =>
              setState(() => _accentColor = MuuvieColorPicker.toHex(color)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _debateLink,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(labelText: l10n?.cineclubeDebateLink),
          onChanged: (value) => _debateLink = value,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _socialLink,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(labelText: l10n?.maratonaFieldSocial),
          onChanged: (value) => _socialLink = value,
        ),
        const SizedBox(height: 12),
        TextFormField(
          obscureText: true,
          maxLength: 72,
          decoration: InputDecoration(
            labelText: l10n?.maratonaPassword,
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
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.saving ? null : _save,
          child: Text(
            _isNew ? l10n?.cineclubeCreate ?? '' : l10n?.cineclubeSave ?? '',
          ),
        ),
      ],
    );
  }
}

enum _Day { start, end, debate }

class _SessionCard extends StatelessWidget {
  final _Session session;

  /// Shown in a cycle.
  final int? number;
  final VoidCallback onPickMovie;
  final ValueChanged<_Day> onPickDate;
  final VoidCallback? onRemove;

  const _SessionCard({
    super.key,
    required this.session,
    required this.number,
    required this.onPickMovie,
    required this.onPickDate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final movie = session.movie;
    final locked = session.locked;
    final position = number;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (position != null)
                  Text(
                    l10n?.cineclubeSessionNumber(position) ?? '$position',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                const Spacer(),
                if (locked)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      l10n?.cineclubeSessionStarted ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (onRemove != null)
                  IconButton(
                    tooltip: l10n?.maratonaRemove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onRemove,
                  ),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !locked,
              leading: CineClubePoster(
                posterPath: movie?.posterPath,
                width: 36,
              ),
              title: Text(movie?.title ?? l10n?.cineclubePickMovie ?? ''),
              subtitle: movie?.year == null ? null : Text('${movie!.year}'),
              trailing: locked ? null : const Icon(Icons.search),
              onTap: locked ? null : onPickMovie,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: l10n?.maratonaFieldStart ?? '',
                      value: cineclubeDay(session.startsOn),
                      compact: true,
                      onTap: locked ? null : () => onPickDate(_Day.start),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DateField(
                      label: l10n?.maratonaFieldEnd ?? '',
                      value: cineclubeDay(session.endsOn),
                      compact: true,
                      onTap: locked ? null : () => onPickDate(_Day.end),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _DateField(
                label: l10n?.cineclubeFieldDebate ?? '',
                value: cineclubeDay(session.debateOn),
                onTap: locked ? null : () => onPickDate(_Day.debate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  /// Half width: no calendar icon, so the whole date fits.
  final bool compact;

  const _DateField({
    required this.label,
    required this.value,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      isEmpty: false,
      decoration: InputDecoration(
        labelText: label,
        enabled: onTap != null,
        suffixIcon: compact ? null : const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}

class _Session {
  final int uid;
  final int? id;
  CineClubeMovie? movie;
  DateTime startsOn;
  DateTime endsOn;
  DateTime debateOn;

  /// It started: the server keeps it as it is.
  final bool locked;

  _Session({
    required this.uid,
    this.id,
    this.movie,
    required this.startsOn,
    required this.endsOn,
    required this.debateOn,
    this.locked = false,
  });
}
