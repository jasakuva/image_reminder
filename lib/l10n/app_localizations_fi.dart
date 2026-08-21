// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'ImageReminder';

  @override
  String get settingsInfo => 'Asetukset ja tiedot';

  @override
  String get about => 'Tietoja';

  @override
  String aboutDescription(String softwareName) {
    return 'Tämä on $softwareName. Sen avulla voit luoda muistutuksia kuvista ja kuvakaappauksista.';
  }

  @override
  String get versionInformation => 'Versiotiedot';

  @override
  String get version => 'Versio';

  @override
  String get buildNumber => 'Koontinumero';

  @override
  String get buildDate => 'Koontipäivä';

  @override
  String get commit => 'Commit';

  @override
  String get settings => 'Asetukset';

  @override
  String get language => 'Kieli';

  @override
  String get systemDefault => 'Järjestelmän oletus';

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
      'Ilmainen versio käytössä. Enintään 2 aktiivista muistutusta.';

  @override
  String get premiumEnabled => 'Premium käytössä. Rajattomasti muistutuksia.';

  @override
  String get upgrade => 'Päivitä';

  @override
  String get addCode => 'Lisää koodi';

  @override
  String get enable => 'Ota käyttöön';

  @override
  String get disable => 'Poista käytöstä';

  @override
  String get upgradeTitle => 'Päivitä Premiumiin';

  @override
  String get upgradeMessage =>
      'Ilmainen versio tukee enintään 2 aktiivista muistutusta. Premiumissa muistutuksia on rajattomasti.';

  @override
  String get upgradeComingSoon =>
      'Premium-osto on tulossa pian. Tarkista myöhemmin uudelleen. Voit käyttää testaukseen koodia.';

  @override
  String get upgradeUnavailable =>
      'Ostot eivät ole tällä laitteella juuri nyt käytettävissä. Voit käyttää testaukseen koodia.';

  @override
  String purchaseServiceNotReady(String errorMessage) {
    return 'Ostopalvelu ei ole vielä valmis. $errorMessage\n\nVoit silti käyttää koodia testaukseen.';
  }

  @override
  String oneTimePurchase(String price) {
    return 'Kertamaksu: $price';
  }

  @override
  String get cancel => 'Peruuta';

  @override
  String get buyNow => 'Osta nyt';

  @override
  String get purchaseComingSoon => 'Osto tulossa pian';

  @override
  String get addCodeTitle => 'Lisää koodi';

  @override
  String get codeLabel => '6-numeroinen koodi';

  @override
  String get codeHint => 'Anna koodi';

  @override
  String get apply => 'Käytä';

  @override
  String get premiumEnabledSnack => 'Premium käytössä.';

  @override
  String get invalidCode => 'Virheellinen koodi.';

  @override
  String get newReminder => 'Uusi muistutus';

  @override
  String get noImageRemindersYet => 'Ei kuvamuistutuksia vielä';

  @override
  String get createFirstReminderHint =>
      'Luo ensimmäinen muistutus valitsemalla tai ottamalla kuva ja asettamalla aika.';

  @override
  String remindersCount(int count) {
    return '$count muistutusta';
  }

  @override
  String get remindersSubtitle =>
      'Kuvamuistutuksesi yhdessä selkeässä paikassa';

  @override
  String get createImageReminder => 'Luo kuvamuistutus';

  @override
  String get createImageReminderSubtitle =>
      'Valitse kuva, viesti, ääni ja aika';

  @override
  String get reminderTime => 'Muistutusaika';

  @override
  String get tenMinutes => '10 min';

  @override
  String get custom => 'Mukautettu';

  @override
  String get notify => 'Ilmoitus';

  @override
  String get notifyHint => 'Mitä muistutuksessa pitäisi lukea?';

  @override
  String get sound => 'Ääni';

  @override
  String get notification => 'Ilmoitus';

  @override
  String get alarm => 'Hälytys';

  @override
  String get newReminderTitle => 'Uusi muistutus';

  @override
  String get saveReminder => 'Tallenna muistutus';

  @override
  String get choosePictureFirst => 'Valitse tai ota ensin kuva.';

  @override
  String get futureReminderTime => 'Valitse muistutusaika tulevaisuudesta.';

  @override
  String couldNotSaveReminder(String error) {
    return 'Muistutusta ei voitu tallentaa: $error';
  }

  @override
  String get choosePicture => 'Valitse kuva';

  @override
  String get takePhoto => 'Ota kuva';

  @override
  String get scheduled => 'Ajastettu';

  @override
  String get completed => 'Valmis';

  @override
  String get activeImageReminder => 'Aktiivinen kuvamuistutus';

  @override
  String get reminderCompleted => 'Muistutus suoritettu';

  @override
  String get reminderNotFound => 'Muistutusta ei löytynyt';

  @override
  String get reminderNoLongerExists => 'Tätä muistutusta ei enää ole.';

  @override
  String get reminderDetail => 'Muistutuksen tiedot';

  @override
  String get editReminder => 'Muokkaa muistutusta';

  @override
  String get saveChanges => 'Tallenna muutokset';

  @override
  String get reminderUpdatedSnack => 'Muistutus päivitetty.';

  @override
  String get delete => 'Poista';

  @override
  String get markDone => 'Merkitse valmiiksi';

  @override
  String get snoozeRemindAgain => 'Torkuta / muistuta uudelleen';

  @override
  String get reminderCompletedSnack => 'Muistutus merkitty valmiiksi.';

  @override
  String get deleteReminderQuestion => 'Poistetaanko muistutus?';

  @override
  String get deleteReminderDescription =>
      'Tämä poistaa muistutuksen ja sen paikallisesti tallennetun kuvan.';

  @override
  String get soundLabelNotification => 'Ilmoitusääni';

  @override
  String get soundLabelAlarm => 'Hälytysääni';

  @override
  String get snooze5Minutes => '5 minuuttia';

  @override
  String get snooze10Minutes => '10 minuuttia';

  @override
  String get snooze1Hour => '1 tunti';

  @override
  String get tomorrow => 'Huomenna';

  @override
  String get snooze => 'Torkuta';

  @override
  String get reminderSnoozed => 'Muistutus siirretty.';

  @override
  String get dueNow => 'Erääntyy nyt';

  @override
  String get inLessThanMinute => 'Alle minuutin kuluttua';

  @override
  String inMinutes(int minutes) {
    return '$minutes min kuluttua';
  }

  @override
  String inHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min kuluttua';
  }

  @override
  String inDaysHours(int days, int hours) {
    return '$days pv $hours h kuluttua';
  }
}
