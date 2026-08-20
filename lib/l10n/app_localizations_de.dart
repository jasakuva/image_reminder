// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'ImageReminder';

  @override
  String get settingsInfo => 'Einstellungen & Infos';

  @override
  String get about => 'Über';

  @override
  String aboutDescription(String softwareName) {
    return 'Dies ist $softwareName. Es hilft dir, Erinnerungen aus Bildern und Screenshots zu erstellen.';
  }

  @override
  String get versionInformation => 'Versionsinformationen';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build-Nummer';

  @override
  String get buildDate => 'Build-Datum';

  @override
  String get commit => 'Commit';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get systemDefault => 'Systemstandard';

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
      'Kostenlose Version aktiv. Bis zu 2 aktive Erinnerungen erlaubt.';

  @override
  String get premiumEnabled =>
      'Premium aktiviert. Unbegrenzte Erinnerungen erlaubt.';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get addCode => 'Code hinzufügen';

  @override
  String get enable => 'Aktivieren';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get upgradeTitle => 'Auf Premium upgraden';

  @override
  String get upgradeMessage =>
      'Die kostenlose Version unterstützt bis zu 2 aktive Erinnerungen. Upgrade auf Premium für unbegrenzte Erinnerungen.';

  @override
  String get upgradeComingSoon =>
      'Der Premium-Kauf ist bald verfügbar. Bitte versuche es in Kürze erneut. Du kannst weiterhin Code hinzufügen, um zu testen.';

  @override
  String get upgradeUnavailable =>
      'Käufe sind auf diesem Gerät derzeit nicht verfügbar. Du kannst weiterhin Code hinzufügen, um zu testen.';

  @override
  String purchaseServiceNotReady(String errorMessage) {
    return 'Der Kaufdienst ist noch nicht bereit. $errorMessage\n\nDu kannst weiterhin Code hinzufügen, um zu testen.';
  }

  @override
  String oneTimePurchase(String price) {
    return 'Einmalkauf: $price';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get buyNow => 'Jetzt kaufen';

  @override
  String get purchaseComingSoon => 'Kauf bald verfügbar';

  @override
  String get addCodeTitle => 'Code hinzufügen';

  @override
  String get codeLabel => '6-stelliger Code';

  @override
  String get codeHint => 'Code eingeben';

  @override
  String get apply => 'Anwenden';

  @override
  String get premiumEnabledSnack => 'Premium aktiviert.';

  @override
  String get invalidCode => 'Ungültiger Code.';

  @override
  String get newReminder => 'Neue Erinnerung';

  @override
  String get noImageRemindersYet => 'Noch keine Bild-Erinnerungen';

  @override
  String get createFirstReminderHint =>
      'Erstelle deine erste Erinnerung, indem du ein Bild auswählst oder aufnimmst und eine Zeit festlegst.';

  @override
  String remindersCount(int count) {
    return '$count Erinnerungen';
  }

  @override
  String get remindersSubtitle =>
      'Deine Bild-Erinnerungen an einem übersichtlichen Ort';

  @override
  String get createImageReminder => 'Bild-Erinnerung erstellen';

  @override
  String get createImageReminderSubtitle =>
      'Wähle ein Bild, eine Nachricht, einen Ton und eine Uhrzeit';

  @override
  String get reminderTime => 'Erinnerungszeit';

  @override
  String get tenMinutes => '10 Min';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get notify => 'Benachrichtigung';

  @override
  String get notifyHint => 'Was soll die Erinnerung sagen?';

  @override
  String get sound => 'Ton';

  @override
  String get notification => 'Benachrichtigung';

  @override
  String get alarm => 'Alarm';

  @override
  String get newReminderTitle => 'Neue Erinnerung';

  @override
  String get saveReminder => 'Erinnerung speichern';

  @override
  String get choosePictureFirst =>
      'Wähle zuerst ein Bild aus oder nimm eines auf.';

  @override
  String get futureReminderTime => 'Wähle eine Erinnerungszeit in der Zukunft.';

  @override
  String couldNotSaveReminder(String error) {
    return 'Erinnerung konnte nicht gespeichert werden: $error';
  }

  @override
  String get choosePicture => 'Bild auswählen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get scheduled => 'Geplant';

  @override
  String get completed => 'Erledigt';

  @override
  String get activeImageReminder => 'Aktive Bild-Erinnerung';

  @override
  String get reminderCompleted => 'Erinnerung abgeschlossen';

  @override
  String get reminderNotFound => 'Erinnerung nicht gefunden';

  @override
  String get reminderNoLongerExists => 'Diese Erinnerung existiert nicht mehr.';

  @override
  String get reminderDetail => 'Erinnerungsdetails';

  @override
  String get delete => 'Löschen';

  @override
  String get markDone => 'Als erledigt markieren';

  @override
  String get snoozeRemindAgain => 'Schlummern / erneut erinnern';

  @override
  String get reminderCompletedSnack => 'Erinnerung als erledigt markiert.';

  @override
  String get deleteReminderQuestion => 'Erinnerung löschen?';

  @override
  String get deleteReminderDescription =>
      'Dadurch werden die Erinnerung und das lokal gespeicherte Bild gelöscht.';

  @override
  String get soundLabelNotification => 'Benachrichtigungston';

  @override
  String get soundLabelAlarm => 'Alarmton';

  @override
  String get snooze5Minutes => '5 Minuten';

  @override
  String get snooze10Minutes => '10 Minuten';

  @override
  String get snooze1Hour => '1 Stunde';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get snooze => 'Schlummern';

  @override
  String get reminderSnoozed => 'Erinnerung verschoben.';

  @override
  String get dueNow => 'Jetzt fällig';

  @override
  String get inLessThanMinute => 'In weniger als einer Minute';

  @override
  String inMinutes(int minutes) {
    return 'In $minutes Min';
  }

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'In $hours Std $minutes Min';
  }

  @override
  String inDaysHours(int days, int hours) {
    return 'In $days T $hours Std';
  }
}
