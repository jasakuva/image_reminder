// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ImageReminder';

  @override
  String get settingsInfo => '設定と情報';

  @override
  String get about => 'このアプリについて';

  @override
  String aboutDescription(String softwareName) {
    return 'これは$softwareNameです。画像やスクリーンショットからリマインダーを作成できます。';
  }

  @override
  String get versionInformation => 'バージョン情報';

  @override
  String get version => 'バージョン';

  @override
  String get buildNumber => 'ビルド番号';

  @override
  String get buildDate => 'ビルド日';

  @override
  String get commit => 'コミット';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システム設定';

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
  String get freePlanActive => '無料プランです。アクティブなリマインダーは2件までです。';

  @override
  String get premiumEnabled => 'プレミアムが有効です。リマインダー数は無制限です。';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get addCode => 'コードを追加';

  @override
  String get enable => '有効にする';

  @override
  String get disable => '無効にする';

  @override
  String get upgradeTitle => 'プレミアムにアップグレード';

  @override
  String get upgradeMessage =>
      '無料版ではアクティブなリマインダーを2件まで作成できます。プレミアムにアップグレードすると無制限になります。';

  @override
  String get upgradeComingSoon =>
      'プレミアム購入はまもなく開始されます。しばらくしてからもう一度お試しください。テスト用にコードを使用できます。';

  @override
  String get upgradeUnavailable => 'このデバイスでは現在購入を利用できません。テスト用にコードを使用できます。';

  @override
  String purchaseServiceNotReady(String errorMessage) {
    return '購入サービスはまだ準備中です。$errorMessage\n\nテスト用にコードを使用できます。';
  }

  @override
  String oneTimePurchase(String price) {
    return '買い切り: $price';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get buyNow => '今すぐ購入';

  @override
  String get purchaseComingSoon => '購入は近日公開';

  @override
  String get addCodeTitle => 'コードを追加';

  @override
  String get codeLabel => '6桁のコード';

  @override
  String get codeHint => 'コードを入力';

  @override
  String get apply => '適用';

  @override
  String get premiumEnabledSnack => 'プレミアムが有効になりました。';

  @override
  String get invalidCode => '無効なコードです。';

  @override
  String get newReminder => '新しいリマインダー';

  @override
  String get noImageRemindersYet => '画像リマインダーはまだありません';

  @override
  String get createFirstReminderHint => '画像を選ぶか撮影し、時刻を設定して最初のリマインダーを作成してください。';

  @override
  String remindersCount(int count) {
    return '$count 件のリマインダー';
  }

  @override
  String get remindersSubtitle => '画像リマインダーをひとつの見やすい場所にまとめます';

  @override
  String get createImageReminder => '画像リマインダーを作成';

  @override
  String get createImageReminderSubtitle => '画像、メッセージ、音、時刻を選択してください';

  @override
  String get reminderTime => 'リマインダー時刻';

  @override
  String get tenMinutes => '10分';

  @override
  String get custom => 'カスタム';

  @override
  String get notify => '通知内容';

  @override
  String get notifyHint => 'リマインダーに何を表示しますか？';

  @override
  String get sound => '音';

  @override
  String get notification => '通知';

  @override
  String get alarm => 'アラーム';

  @override
  String get newReminderTitle => '新しいリマインダー';

  @override
  String get saveReminder => 'リマインダーを保存';

  @override
  String get choosePictureFirst => '先に画像を選ぶか撮影してください。';

  @override
  String get futureReminderTime => '未来の時刻を選択してください。';

  @override
  String couldNotSaveReminder(String error) {
    return 'リマインダーを保存できませんでした: $error';
  }

  @override
  String get choosePicture => '画像を選ぶ';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get scheduled => '予定時刻';

  @override
  String get completed => '完了';

  @override
  String get activeImageReminder => '有効な画像リマインダー';

  @override
  String get reminderCompleted => 'リマインダー完了';

  @override
  String get reminderNotFound => 'リマインダーが見つかりません';

  @override
  String get reminderNoLongerExists => 'このリマインダーはもう存在しません。';

  @override
  String get reminderDetail => 'リマインダー詳細';

  @override
  String get editReminder => 'リマインダーを編集';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get reminderUpdatedSnack => 'リマインダーを更新しました。';

  @override
  String get delete => '削除';

  @override
  String get markDone => '完了にする';

  @override
  String get snoozeRemindAgain => 'スヌーズ / 再通知';

  @override
  String get reminderCompletedSnack => 'リマインダーを完了にしました。';

  @override
  String get deleteReminderQuestion => 'リマインダーを削除しますか？';

  @override
  String get deleteReminderDescription => 'これにより、リマインダーと端末に保存された画像が削除されます。';

  @override
  String get soundLabelNotification => '通知音';

  @override
  String get soundLabelAlarm => 'アラーム音';

  @override
  String get snooze5Minutes => '5分';

  @override
  String get snooze10Minutes => '10分';

  @override
  String get snooze1Hour => '1時間';

  @override
  String get tomorrow => '明日';

  @override
  String get snooze => 'スヌーズ';

  @override
  String get reminderSnoozed => 'リマインダーをスヌーズしました。';

  @override
  String get dueNow => '今すぐ';

  @override
  String get inLessThanMinute => '1分未満後';

  @override
  String inMinutes(int minutes) {
    return '$minutes分後';
  }

  @override
  String inHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分後';
  }

  @override
  String inDaysHours(int days, int hours) {
    return '$days日$hours時間後';
  }
}
