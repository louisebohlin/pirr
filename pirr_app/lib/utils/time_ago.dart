String formatTimeAgo(DateTime dateTime, {DateTime? now}) {
  final DateTime current = now ?? DateTime.now();
  final Duration diff = current.difference(dateTime);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final int weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return '${weeks}w ago';
  final int months = (diff.inDays / 30).floor();
  if (months < 12) return '${months}mo ago';
  final int years = (diff.inDays / 365).floor();
  return '${years}y ago';
}
