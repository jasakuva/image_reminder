import 'package:intl/intl.dart';

final _dateTimeFormatter = DateFormat('EEE d MMM yyyy, HH:mm');

String formatReminderDate(DateTime dateTime) {
  return _dateTimeFormatter.format(dateTime.toLocal());
}

String formatRelativeReminderTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = dateTime.toLocal().difference(now);

  if (difference.isNegative) {
    return 'Due now';
  }

  if (difference.inMinutes < 1) {
    return 'In less than a minute';
  }
  if (difference.inHours < 1) {
    return 'In ${difference.inMinutes} min';
  }
  if (difference.inDays < 1) {
    return 'In ${difference.inHours} h ${difference.inMinutes % 60} min';
  }
  return 'In ${difference.inDays} d ${difference.inHours % 24} h';
}
