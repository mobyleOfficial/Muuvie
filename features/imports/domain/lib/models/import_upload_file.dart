import 'dart:typed_data';

/// A file the user picked for an import: the CSV from filmow_to_letterboxd,
/// or Letterboxd's export zip or one of its CSVs. [name] is sent to the server,
/// which tells some Letterboxd CSVs apart by it (watched.csv, watchlist.csv).
class ImportUploadFile {
  final String name;
  final Uint8List bytes;

  const ImportUploadFile({required this.name, required this.bytes});
}
