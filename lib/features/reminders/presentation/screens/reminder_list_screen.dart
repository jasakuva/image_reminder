import 'package:flutter/material.dart';

import '../../../../core/theme/motorsport_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../billing/data/premium_access_store.dart';
import '../../../billing/presentation/widgets/upgrade_prompt.dart';
import '../../../settings/data/locale_settings_store.dart';
import '../../data/reminder_store.dart';
import '../../../settings/presentation/screens/settings_info_screen.dart';
import 'create_reminder_screen.dart';
import 'reminder_detail_screen.dart';
import '../widgets/reminder_card.dart';

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({
    required this.reminderStore,
    required this.premiumAccessStore,
    required this.localeSettingsStore,
    super.key,
  });

  final ReminderStore reminderStore;
  final PremiumAccessStore premiumAccessStore;
  final LocaleSettingsStore localeSettingsStore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsInfo,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsInfoScreen(
                    premiumAccessStore: premiumAccessStore,
                    localeSettingsStore: localeSettingsStore,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RaceScaffoldBackground(
        child: ListenableBuilder(
          listenable: reminderStore,
          builder: (context, _) {
            final reminders = reminderStore.reminders;

            if (reminders.isEmpty) {
              return const _EmptyReminderList();
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: reminders.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return RaceHeader(
                    title: l10n.remindersCount(reminders.length),
                    subtitle: l10n.remindersSubtitle,
                  );
                }

                final reminder = reminders[index - 1];
                return ReminderCard(
                  reminder: reminder,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReminderDetailScreen(
                          reminderStore: reminderStore,
                          reminderId: reminder.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (reminderStore.hasReachedFreeReminderLimit(premiumAccessStore.isPremium)) {
            showUpgradePrompt(
              context,
              premiumAccessStore: premiumAccessStore,
            );
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreateReminderScreen(
                reminderStore: reminderStore,
                premiumAccessStore: premiumAccessStore,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.newReminder),
      ),
    );
  }
}

class _EmptyReminderList extends StatelessWidget {
  const _EmptyReminderList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 72,
              color: MotorsportColors.pitRed,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noImageRemindersYet,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createFirstReminderHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MotorsportColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
