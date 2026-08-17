import 'package:flutter/material.dart';

import '../../../../core/app_info/app_build_info.dart';
import '../../../../core/theme/motorsport_theme.dart';
import '../../../billing/data/premium_access_store.dart';
import '../../../billing/presentation/widgets/upgrade_prompt.dart';

class SettingsInfoScreen extends StatefulWidget {
  const SettingsInfoScreen({required this.premiumAccessStore, super.key});

  final PremiumAccessStore premiumAccessStore;

  @override
  State<SettingsInfoScreen> createState() => _SettingsInfoScreenState();
}

class _SettingsInfoScreenState extends State<SettingsInfoScreen> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Info')),
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
              title: 'About',
              children: [
                Text(
                  'This is ${AppBuildInfo.softwareName}. It helps you create reminders from pictures and screenshots.',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _InfoSection(
              title: 'Version information',
              children: [
                _InfoRow(label: 'Version', value: AppBuildInfo.version),
                _InfoRow(
                  label: 'Build number',
                  value: AppBuildInfo.buildNumber,
                ),
                _InfoRow(label: 'Build date', value: AppBuildInfo.buildDate),
                _InfoRow(label: 'Commit', value: AppBuildInfo.commit),
              ],
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: 'Settings',
              children: [
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MotorsportColors.carbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF383D47)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined, color: MotorsportColors.pitRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isPremium
                  ? 'Premium enabled. Unlimited reminders allowed.'
                  : 'Free plan active. Up to 2 active reminders allowed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MotorsportColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (!isPremium)
            OutlinedButton(
              onPressed: isUpdating
                  ? null
                  : () => showUpgradePrompt(
                        context,
                        premiumAccessStore: premiumAccessStore,
                      ),
              child: const Text('Upgrade'),
            ),
          if (!isPremium) const SizedBox(width: 8),
          OutlinedButton(
            onPressed: isUpdating ? null : onAddCode,
            child: const Text('Add code'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: isUpdating ? null : onToggle,
            child: Text(isPremium ? 'Disable' : 'Enable'),
          ),
        ],
      ),
    );
  }
}
