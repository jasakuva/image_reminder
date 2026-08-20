import 'package:flutter/material.dart';

import '../../../../core/app_info/app_build_info.dart';
import '../../../../core/theme/motorsport_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../billing/data/premium_access_store.dart';
import '../../../billing/presentation/widgets/upgrade_prompt.dart';
import '../../data/locale_settings_store.dart';

class SettingsInfoScreen extends StatefulWidget {
  const SettingsInfoScreen({
    required this.premiumAccessStore,
    required this.localeSettingsStore,
    super.key,
  });

  final PremiumAccessStore premiumAccessStore;
  final LocaleSettingsStore localeSettingsStore;

  @override
  State<SettingsInfoScreen> createState() => _SettingsInfoScreenState();
}

class _SettingsInfoScreenState extends State<SettingsInfoScreen> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsInfo)),
      body: RaceScaffoldBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const RaceHeader(
              title: AppBuildInfo.appName,
              subtitle: AppBuildInfo.softwareName,
              icon: Icons.image_outlined,
            ),
            const SizedBox(height: 16),
            _InfoSection(
              title: l10n.about,
              children: [
                Text(
                  l10n.aboutDescription(AppBuildInfo.softwareName),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: l10n.versionInformation,
              children: [
                _InfoRow(label: l10n.version, value: AppBuildInfo.version),
                _InfoRow(
                  label: l10n.buildNumber,
                  value: AppBuildInfo.buildNumber,
                ),
                _InfoRow(label: l10n.buildDate, value: AppBuildInfo.buildDate),
                _InfoRow(label: l10n.commit, value: AppBuildInfo.commit),
              ],
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: l10n.settings,
              children: [
                _LanguageCard(
                  localeSettingsStore: widget.localeSettingsStore,
                ),
                const SizedBox(height: 12),
                _PremiumToggleCard(
                  premiumAccessStore: widget.premiumAccessStore,
                  isPremium: widget.premiumAccessStore.isPremium,
                  isUpdating: _isUpdating,
                  onToggle: _togglePremium,
                  onAddCode: _addCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePremium() async {
    setState(() => _isUpdating = true);
    await widget.premiumAccessStore.setPremium(!widget.premiumAccessStore.isPremium);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _addCode() async {
    await showUpgradePrompt(
      context,
      premiumAccessStore: widget.premiumAccessStore,
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MotorsportColors.muted,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumToggleCard extends StatelessWidget {
  const _PremiumToggleCard({
    required this.premiumAccessStore,
    required this.isPremium,
    required this.isUpdating,
    required this.onToggle,
    required this.onAddCode,
  });

  final PremiumAccessStore premiumAccessStore;
  final bool isPremium;
  final bool isUpdating;
  final VoidCallback onToggle;
  final VoidCallback onAddCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MotorsportColors.carbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF383D47)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: MotorsportColors.pitRed,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPremium
                      ? l10n.premiumEnabled
                      : l10n.freePlanActive,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: MotorsportColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isPremium)
                OutlinedButton(
                  onPressed: isUpdating
                      ? null
                      : () => showUpgradePrompt(
                            context,
                            premiumAccessStore: premiumAccessStore,
                          ),
                  child: Text(l10n.upgrade),
                ),
              OutlinedButton(
                onPressed: isUpdating ? null : onAddCode,
                child: Text(l10n.addCode),
              ),
              FilledButton(
                onPressed: isUpdating ? null : onToggle,
                child: Text(isPremium ? l10n.disable : l10n.enable),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.localeSettingsStore});

  final LocaleSettingsStore localeSettingsStore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final currentLabel = switch (localeSettingsStore.locale?.languageCode) {
      'en' => l10n.languageEnglish,
      'fi' => l10n.languageFinnish,
      'sv' => l10n.languageSwedish,
      'ja' => l10n.languageJapanese,
      'de' => l10n.languageGerman,
      _ => l10n.systemDefault,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.language_outlined, color: MotorsportColors.pitRed),
      title: Text(l10n.language),
      subtitle: Text(currentLabel),
      onTap: () => _showLanguagePicker(context),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedCode = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.systemDefault),
              onTap: () => Navigator.of(context).pop(null),
            ),
            ListTile(
              title: Text(l10n.languageEnglish),
              onTap: () => Navigator.of(context).pop('en'),
            ),
            ListTile(
              title: Text(l10n.languageFinnish),
              onTap: () => Navigator.of(context).pop('fi'),
            ),
            ListTile(
              title: Text(l10n.languageSwedish),
              onTap: () => Navigator.of(context).pop('sv'),
            ),
            ListTile(
              title: Text(l10n.languageJapanese),
              onTap: () => Navigator.of(context).pop('ja'),
            ),
            ListTile(
              title: Text(l10n.languageGerman),
              onTap: () => Navigator.of(context).pop('de'),
            ),
          ],
        ),
      ),
    );

    await localeSettingsStore.setLocale(
      selectedCode == null ? null : Locale(selectedCode),
    );
  }
}
