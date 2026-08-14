enum ReminderStatus {
  active,
  completed,
  cancelled;

  static ReminderStatus fromName(String name) {
    return ReminderStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => ReminderStatus.active,
    );
  }
}
