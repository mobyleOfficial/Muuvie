/// Why a handle cannot be used.
enum HandleProblem { invalid, taken }

/// Answer of the live handle check of the edit screen (F5.3).
class HandleAvailability {
  final String handle;
  final bool available;
  final HandleProblem? problem;

  const HandleAvailability({
    required this.handle,
    required this.available,
    this.problem,
  });

  /// Same rule as the backend: 5 to 30 lowercase letters, digits, dots or underscores.
  static final format = RegExp(r'^[a-z0-9_.]{5,30}$');

  /// The handle as typed, without the leading @ and in lower case.
  static String normalize(String handle) {
    final trimmed = handle.trim();
    return (trimmed.startsWith('@') ? trimmed.substring(1) : trimmed)
        .toLowerCase();
  }
}
