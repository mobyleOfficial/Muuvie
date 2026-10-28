import 'package:common/app_localizations.dart';

String formatTimeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

/// Short relative time in the user's language ("agora", "5 min", "3 h",
/// "2 d"), then the date after a week.
String formatRelativeTime(AppLocalizations? l10n, DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) return l10n?.timeNow ?? 'now';
  if (difference.inMinutes < 60) {
    return l10n?.timeMinutes(difference.inMinutes) ??
        '${difference.inMinutes} min';
  }
  if (difference.inHours < 24) {
    return l10n?.timeHours(difference.inHours) ?? '${difference.inHours} h';
  }
  if (difference.inDays < 7) {
    return l10n?.timeDays(difference.inDays) ?? '${difference.inDays} d';
  }
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
