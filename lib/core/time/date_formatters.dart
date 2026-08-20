import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

final _dateTimeFormatter = DateFormat('EEE d MMM yyyy, HH:mm');

String formatReminderDate(DateTime dateTime) {
  return _dateTimeFormatter.format(dateTime.toLocal());
}

String formatRelativeReminderTime(DateTime dateTime, AppLocalizations l10n) {
  final now = DateTime.now();
  final difference = dateTime.toLocal().difference(now);

  if (difference.isNegative) {
    return l10n.dueNow;
  }

  if (difference.inMinutes < 1) {
    return l10n.inLessThanMinute;
  }
  if (difference.inHours < 1) {
    return l10n.inMinutes(difference.inMinutes);
  }
  if (difference.inDays < 1) {
    return l10n.inHoursMinutes(
      difference.inHours,
      difference.inMinutes % 60,
    );
  }
  return l10n.inDaysHours(
    difference.inDays,
    difference.inHours % 24,
  );
}
