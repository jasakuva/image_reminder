import 'package:flutter/material.dart';

import '../../../../core/app_info/app_build_info.dart';
import '../../../../core/theme/motorsport_theme.dart';

class SettingsInfoScreen extends StatelessWidget {
  const SettingsInfoScreen({super.key});

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
            const _InfoSection(
              title: 'Settings',
              children: [_PlaceholderSetting()],
            ),
          ],
        ),
      ),
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

class _PlaceholderSetting extends StatelessWidget {
  const _PlaceholderSetting();

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
          const Icon(Icons.tune_outlined, color: MotorsportColors.pitRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'More settings can be added here later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MotorsportColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
