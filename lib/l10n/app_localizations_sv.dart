// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'ImageReminder';

  @override
  String get settingsInfo => 'Inställningar och info';

  @override
  String get about => 'Om';

  @override
  String aboutDescription(String softwareName) {
    return 'Det här är $softwareName. Det hjälper dig att skapa påminnelser från bilder och skärmdumpar.';
  }

  @override
  String get versionInformation => 'Versionsinformation';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Buildnummer';

  @override
  String get buildDate => 'Builddatum';

  @override
  String get commit => 'Commit';

  @override
  String get settings => 'Inställningar';

  @override
  String get language => 'Språk';

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
      'Gratisversion aktiv. Upp till 2 aktiva påminnelser.';

  @override
  String get premiumEnabled => 'Premium aktiverat. Obegränsade påminnelser.';

  @override
  String get upgrade => 'Uppgradera';

  @override
  String get addCode => 'Lägg till kod';

  @override
  String get enable => 'Aktivera';

  @override
  String get disable => 'Inaktivera';

  @override
  String get upgradeTitle => 'Uppgradera till Premium';

  @override
  String get upgradeMessage =>
      'Gratisversionen stöder upp till 2 aktiva påminnelser. Uppgradera till Premium för obegränsade påminnelser.';

  @override
  String get upgradeComingSoon =>
      'Premiumköp kommer snart. Kom tillbaka om en stund. Du kan fortfarande använda Lägg till kod för testning.';

  @override
  String get upgradeUnavailable =>
      'Köp är tillfälligt inte tillgängliga på den här enheten. Du kan fortfarande använda Lägg till kod för testning.';

  @override
  String purchaseServiceNotReady(String errorMessage) {
    return 'Köptjänsten är inte klar ännu. $errorMessage\n\nDu kan fortfarande använda Lägg till kod för testning.';
  }

  @override
  String oneTimePurchase(String price) {
    return 'Engångsköp: $price';
  }

  @override
  String get cancel => 'Avbryt';

  @override
  String get buyNow => 'Köp nu';

  @override
  String get purchaseComingSoon => 'Köp kommer snart';

  @override
  String get addCodeTitle => 'Lägg till kod';

  @override
  String get codeLabel => '6-siffrig kod';

  @override
  String get codeHint => 'Ange kod';

  @override
  String get apply => 'Använd';

  @override
  String get premiumEnabledSnack => 'Premium aktiverat.';

  @override
  String get invalidCode => 'Ogiltig kod.';

  @override
  String get newReminder => 'Ny påminnelse';

  @override
  String get noImageRemindersYet => 'Inga bildpåminnelser än';

  @override
  String get createFirstReminderHint =>
      'Skapa din första påminnelse genom att välja eller ta en bild och ställa in en tid.';

  @override
  String remindersCount(int count) {
    return '$count påminnelser';
  }

  @override
  String get remindersSubtitle => 'Dina bildpåminnelser på ett tydligt ställe';

  @override
  String get createImageReminder => 'Skapa bildpåminnelse';

  @override
  String get createImageReminderSubtitle =>
      'Välj en bild, ett meddelande, ljud och tid';

  @override
  String get reminderTime => 'Påminnelsetid';

  @override
  String get tenMinutes => '10 min';

  @override
  String get custom => 'Anpassad';

  @override
  String get notify => 'Meddelande';

  @override
  String get notifyHint => 'Vad ska påminnelsen säga?';

  @override
  String get sound => 'Ljud';

  @override
  String get notification => 'Notis';

  @override
  String get alarm => 'Alarm';

  @override
  String get newReminderTitle => 'Ny påminnelse';

  @override
  String get saveReminder => 'Spara påminnelse';

  @override
  String get choosePictureFirst => 'Välj eller ta först en bild.';

  @override
  String get futureReminderTime => 'Välj en påminnelsetid i framtiden.';

  @override
  String couldNotSaveReminder(String error) {
    return 'Kunde inte spara påminnelsen: $error';
  }

  @override
  String get choosePicture => 'Välj bild';

  @override
  String get takePhoto => 'Ta foto';

  @override
  String get scheduled => 'Schemalagd';

  @override
  String get completed => 'Slutförd';

  @override
  String get activeImageReminder => 'Aktiv bildpåminnelse';

  @override
  String get reminderCompleted => 'Påminnelsen slutförd';

  @override
  String get reminderNotFound => 'Påminnelsen hittades inte';

  @override
  String get reminderNoLongerExists => 'Den här påminnelsen finns inte längre.';

  @override
  String get reminderDetail => 'Påminnelsedetalj';

  @override
  String get delete => 'Ta bort';

  @override
  String get markDone => 'Markera som klar';

  @override
  String get snoozeRemindAgain => 'Snooza / påminn igen';

  @override
  String get reminderCompletedSnack => 'Påminnelsen markerades som klar.';

  @override
  String get deleteReminderQuestion => 'Ta bort påminnelsen?';

  @override
  String get deleteReminderDescription =>
      'Detta tar bort påminnelsen och dess lokalt sparade bild.';

  @override
  String get soundLabelNotification => 'Notisljud';

  @override
  String get soundLabelAlarm => 'Alarmljud';

  @override
  String get snooze5Minutes => '5 minuter';

  @override
  String get snooze10Minutes => '10 minuter';

  @override
  String get snooze1Hour => '1 timme';

  @override
  String get tomorrow => 'I morgon';

  @override
  String get snooze => 'Snooza';

  @override
  String get reminderSnoozed => 'Påminnelsen uppskjuten.';

  @override
  String get dueNow => 'Förfaller nu';

  @override
  String get inLessThanMinute => 'Om mindre än en minut';

  @override
  String inMinutes(int minutes) {
    return 'Om $minutes min';
  }

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'Om $hours h $minutes min';
  }

  @override
  String inDaysHours(int days, int hours) {
    return 'Om $days d $hours h';
  }
}
