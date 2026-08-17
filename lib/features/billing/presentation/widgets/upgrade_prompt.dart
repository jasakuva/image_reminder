import 'package:flutter/material.dart';

import '../../data/premium_access_store.dart';

const _debugPremiumCode = '126543';

Future<void> showUpgradePrompt(
  BuildContext context, {
  required PremiumAccessStore premiumAccessStore,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Upgrade to Premium'),
      content: const Text(
        'Free version supports up to 2 active reminders. Upgrade to Premium for unlimited reminders.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _showPremiumCodeDialog(
              context,
              premiumAccessStore: premiumAccessStore,
            );
          },
          child: const Text('Add code'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Upgrade'),
                content: const Text(
                  'Real store purchase flow is not connected yet in this debug phase. Use Add code for testing Premium unlock.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Upgrade'),
        ),
      ],
    ),
  );
}

Future<void> _showPremiumCodeDialog(
  BuildContext context, {
  required PremiumAccessStore premiumAccessStore,
}) {
  final controller = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add code'),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(
          labelText: '6-digit code',
          hintText: 'Enter code',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final code = controller.text.trim();
            Navigator.of(context).pop();
            if (code == _debugPremiumCode) {
              await premiumAccessStore.setPremium(true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium enabled.')),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid code.')),
                );
              }
            }
          },
          child: const Text('Apply'),
        ),
      ],
    ),
  );
}