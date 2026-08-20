// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ImageReminder';

  @override
  String get settingsInfo => 'Settings & Info';

  @override
  String get about => 'About';

  @override
  String aboutDescription(String softwareName) {
    return 'This is $softwareName. It helps you create reminders from pictures and screenshots.';
  }

  @override
  String get versionInformation => 'Version information';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build number';

  @override
  String get buildDate => 'Build date';

  @override
  String get commit => 'Commit';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFinnish => 'Suomi';

  @override
  String get languageSwedish => 'Svenska';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get freePlanActive =>
      'Free plan active. Up to 2 active reminders allowed.';

  @override
  String get premiumEnabled => 'Premium enabled. Unlimited reminders allowed.';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get addCode => 'Add code';

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get upgradeTitle => 'Upgrade to Premium';

  @override
  String get upgradeMessage =>
      'Free version supports up to 2 active reminders. Upgrade to Premium for unlimited reminders.';

  @override
  String get upgradeComingSoon =>
      'Premium purchase is coming soon. Please check back shortly. You can still use Add code for testing.';

  @override
  String get upgradeUnavailable =>
      'Purchases are temporarily unavailable on this device. You can still use Add code for testing.';

  @override
  String purchaseServiceNotReady(String errorMessage) {
    return 'Purchase service is not ready yet. $errorMessage\n\nYou can still use Add code for testing.';
  }

  @override
  String oneTimePurchase(String price) {
    return 'One-time purchase: $price';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get buyNow => 'Buy now';

  @override
  String get purchaseComingSoon => 'Purchase coming soon';

  @override
  String get addCodeTitle => 'Add code';

  @override
  String get codeLabel => '6-digit code';

  @override
  String get codeHint => 'Enter code';

  @override
  String get apply => 'Apply';

  @override
  String get premiumEnabledSnack => 'Premium enabled.';

  @override
  String get invalidCode => 'Invalid code.';

  @override
  String get newReminder => 'New reminder';

  @override
  String get noImageRemindersYet => 'No image reminders yet';

  @override
  String get createFirstReminderHint =>
      'Create your first reminder by choosing or taking a picture and selecting a time.';

  @override
  String remindersCount(int count) {
    return '$count reminders';
  }

  @override
  String get remindersSubtitle => 'Your image reminders in one clear place';

  @override
  String get createImageReminder => 'Create image reminder';

  @override
  String get createImageReminderSubtitle =>
      'Choose an image, message, sound, and time';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get tenMinutes => '10 min';

  @override
  String get custom => 'Custom';

  @override
  String get notify => 'Notify';

  @override
  String get notifyHint => 'What should the reminder say?';

  @override
  String get sound => 'Sound';

  @override
  String get notification => 'Notification';

  @override
  String get alarm => 'Alarm';

  @override
  String get newReminderTitle => 'New reminder';

  @override
  String get saveReminder => 'Save reminder';

  @override
  String get choosePictureFirst => 'Choose or take a picture first.';

  @override
  String get futureReminderTime => 'Choose a reminder time in the future.';

  @override
  String couldNotSaveReminder(String error) {
    return 'Could not save reminder: $error';
  }

  @override
  String get choosePicture => 'Choose picture';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get completed => 'Completed';

  @override
  String get activeImageReminder => 'Active image reminder';

  @override
  String get reminderCompleted => 'Reminder completed';

  @override
  String get reminderNotFound => 'Reminder not found';

  @override
  String get reminderNoLongerExists => 'This reminder no longer exists.';

  @override
  String get reminderDetail => 'Reminder detail';

  @override
  String get delete => 'Delete';

  @override
  String get markDone => 'Mark done';

  @override
  String get snoozeRemindAgain => 'Snooze / remind again';

  @override
  String get reminderCompletedSnack => 'Reminder completed.';

  @override
  String get deleteReminderQuestion => 'Delete reminder?';

  @override
  String get deleteReminderDescription =>
      'This deletes the reminder and its locally stored picture.';

  @override
  String get soundLabelNotification => 'Notification sound';

  @override
  String get soundLabelAlarm => 'Alarm sound';

  @override
  String get snooze5Minutes => '5 minutes';

  @override
  String get snooze10Minutes => '10 minutes';

  @override
  String get snooze1Hour => '1 hour';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get snooze => 'Snooze';

  @override
  String get reminderSnoozed => 'Reminder snoozed.';

  @override
  String get dueNow => 'Due now';

  @override
  String get inLessThanMinute => 'In less than a minute';

  @override
  String inMinutes(int minutes) {
    return 'In $minutes min';
  }

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'In $hours h $minutes min';
  }

  @override
  String inDaysHours(int days, int hours) {
    return 'In $days d $hours h';
  }
}
