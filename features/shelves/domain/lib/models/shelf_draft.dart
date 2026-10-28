import 'package:core/core.dart';

/// Editable fields of a shelf.
class ShelfDraft {
  final String name;
  final String? description;
  final String? color;
  final ContentVisibility visibility;

  const ShelfDraft({
    required this.name,
    this.description,
    this.color,
    this.visibility = ContentVisibility.public,
  });
}
