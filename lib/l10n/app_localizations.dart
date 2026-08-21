import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fi'),
    Locale('ja'),
    Locale('sv'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ImageReminder'**
  String get appTitle;

  /// No description provided for @settingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Settings & Info'**
  String get settingsInfo;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'This is {softwareName}. It helps you create reminders from pictures and screenshots.'**
  String aboutDescription(String softwareName);

  /// No description provided for @versionInformation.
  ///
  /// In en, this message translates to:
  /// **'Version information'**
  String get versionInformation;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build number'**
  String get buildNumber;

  /// No description provided for @buildDate.
  ///
  /// In en, this message translates to:
  /// **'Build date'**
  String get buildDate;

  /// No description provided for @commit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get commit;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFinnish.
  ///
  /// In en, this message translates to:
  /// **'Suomi'**
  String get languageFinnish;

  /// No description provided for @languageSwedish.
  ///
  /// In en, this message translates to:
  /// **'Svenska'**
  String get languageSwedish;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @freePlanActive.
  ///
  /// In en, this message translates to:
  /// **'Free plan active. Up to 2 active reminders allowed.'**
  String get freePlanActive;

  /// No description provided for @premiumEnabled.
  ///
  /// In en, this message translates to:
  /// **'Premium enabled. Unlimited reminders allowed.'**
  String get premiumEnabled;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @addCode.
  ///
  /// In en, this message translates to:
  /// **'Add code'**
  String get addCode;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @upgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeTitle;

  /// No description provided for @upgradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Free version supports up to 2 active reminders. Upgrade to Premium for unlimited reminders.'**
  String get upgradeMessage;

  /// No description provided for @upgradeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium purchase is coming soon. Please check back shortly. You can still use Add code for testing.'**
  String get upgradeComingSoon;

  /// No description provided for @upgradeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are temporarily unavailable on this device. You can still use Add code for testing.'**
  String get upgradeUnavailable;

  /// No description provided for @purchaseServiceNotReady.
  ///
  /// In en, this message translates to:
  /// **'Purchase service is not ready yet. {errorMessage}\n\nYou can still use Add code for testing.'**
  String purchaseServiceNotReady(String errorMessage);

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase: {price}'**
  String oneTimePurchase(String price);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get buyNow;

  /// No description provided for @purchaseComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Purchase coming soon'**
  String get purchaseComingSoon;

  /// No description provided for @addCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add code'**
  String get addCodeTitle;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeLabel;

  /// No description provided for @codeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get codeHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @premiumEnabledSnack.
  ///
  /// In en, this message translates to:
  /// **'Premium enabled.'**
  String get premiumEnabledSnack;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code.'**
  String get invalidCode;

  /// No description provided for @newReminder.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminder;

  /// No description provided for @noImageRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No image reminders yet'**
  String get noImageRemindersYet;

  /// No description provided for @createFirstReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first reminder by choosing or taking a picture and selecting a time.'**
  String get createFirstReminderHint;

  /// No description provided for @remindersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reminders'**
  String remindersCount(int count);

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your image reminders in one clear place'**
  String get remindersSubtitle;

  /// No description provided for @createImageReminder.
  ///
  /// In en, this message translates to:
  /// **'Create image reminder'**
  String get createImageReminder;

  /// No description provided for @createImageReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an image, message, sound, and time'**
  String get createImageReminderSubtitle;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @tenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get tenMinutes;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @notify.
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get notify;

  /// No description provided for @notifyHint.
  ///
  /// In en, this message translates to:
  /// **'What should the reminder say?'**
  String get notifyHint;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @alarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarm;

  /// No description provided for @newReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminderTitle;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save reminder'**
  String get saveReminder;

  /// No description provided for @choosePictureFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose or take a picture first.'**
  String get choosePictureFirst;

  /// No description provided for @futureReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a reminder time in the future.'**
  String get futureReminderTime;

  /// No description provided for @couldNotSaveReminder.
  ///
  /// In en, this message translates to:
  /// **'Could not save reminder: {error}'**
  String couldNotSaveReminder(String error);

  /// No description provided for @choosePicture.
  ///
  /// In en, this message translates to:
  /// **'Choose picture'**
  String get choosePicture;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @activeImageReminder.
  ///
  /// In en, this message translates to:
  /// **'Active image reminder'**
  String get activeImageReminder;

  /// No description provided for @reminderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder completed'**
  String get reminderCompleted;

  /// No description provided for @reminderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Reminder not found'**
  String get reminderNotFound;

  /// No description provided for @reminderNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This reminder no longer exists.'**
  String get reminderNoLongerExists;

  /// No description provided for @reminderDetail.
  ///
  /// In en, this message translates to:
  /// **'Reminder detail'**
  String get reminderDetail;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @reminderUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated.'**
  String get reminderUpdatedSnack;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @snoozeRemindAgain.
  ///
  /// In en, this message translates to:
  /// **'Snooze / remind again'**
  String get snoozeRemindAgain;

  /// No description provided for @reminderCompletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Reminder completed.'**
  String get reminderCompletedSnack;

  /// No description provided for @deleteReminderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder?'**
  String get deleteReminderQuestion;

  /// No description provided for @deleteReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'This deletes the reminder and its locally stored picture.'**
  String get deleteReminderDescription;

  /// No description provided for @soundLabelNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification sound'**
  String get soundLabelNotification;

  /// No description provided for @soundLabelAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get soundLabelAlarm;

  /// No description provided for @snooze5Minutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get snooze5Minutes;

  /// No description provided for @snooze10Minutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get snooze10Minutes;

  /// No description provided for @snooze1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get snooze1Hour;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @reminderSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Reminder snoozed.'**
  String get reminderSnoozed;

  /// No description provided for @dueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get dueNow;

  /// No description provided for @inLessThanMinute.
  ///
  /// In en, this message translates to:
  /// **'In less than a minute'**
  String get inLessThanMinute;

  /// No description provided for @inMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {minutes} min'**
  String inMinutes(int minutes);

  /// No description provided for @inHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {hours} h {minutes} min'**
  String inHoursMinutes(int hours, int minutes);

  /// No description provided for @inDaysHours.
  ///
  /// In en, this message translates to:
  /// **'In {days} d {hours} h'**
  String inDaysHours(int days, int hours);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fi', 'ja', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fi':
      return AppLocalizationsFi();
    case 'ja':
      return AppLocalizationsJa();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
