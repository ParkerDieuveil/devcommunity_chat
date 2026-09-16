/// Formats relative / short timestamps for chat lists and bubbles.
String formatChatTimestamp(
  DateTime? dateTime, {
  DateTime? now,
  String yesterdayLabel = 'Yesterday',
  List<String>? weekdayLabels,
}) {
  if (dateTime == null) return '';

  final current = now ?? DateTime.now();
  final local = dateTime.toLocal();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(local.year, local.month, local.day);
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

  if (day == today) {
    return time;
  }

  final yesterday = today.subtract(const Duration(days: 1));
  if (day == yesterday) {
    return yesterdayLabel;
  }

  if (current.difference(local).inDays < 7) {
    final weekdays = weekdayLabels ??
        const <String>[
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ];
    return weekdays[local.weekday - 1];
  }

  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  return '$dd/$mm';
}

String formatMessageTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
