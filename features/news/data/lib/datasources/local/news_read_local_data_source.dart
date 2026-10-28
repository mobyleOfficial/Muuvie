import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';

/// Ids of the articles opened on this device, in a small JSON file. Only the
/// most recent [_maxIds] are kept; older articles fall off the list anyway.
class NewsReadLocalDataSource {
  static const _maxIds = 500;

  final LocalClient _localClient;
  final File _file;

  List<int>? _cache;

  NewsReadLocalDataSource(this._localClient, this._file);

  Result<Set<int>> readIds() => _localClient.execute(() => _ids().toSet());

  Result<void> markRead(int articleId) => _localClient.execute(() {
    final ids = _ids()..remove(articleId);
    ids.add(articleId);
    if (ids.length > _maxIds) ids.removeRange(0, ids.length - _maxIds);
    _file.writeAsStringSync(jsonEncode(ids), flush: true);
  });

  List<int> _ids() => _cache ??= _file.existsSync()
      ? (jsonDecode(_file.readAsStringSync()) as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList()
      : <int>[];
}
