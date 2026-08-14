enum ReminderSoundMode {
  notification,
  alarm;

  static ReminderSoundMode fromName(String? name) {
    return ReminderSoundMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ReminderSoundMode.notification,
    );
  }
}
