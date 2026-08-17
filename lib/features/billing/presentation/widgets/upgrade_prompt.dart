import 'package:flutter/material.dart';

Future<void> showUpgradePrompt(BuildContext context) {
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
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Upgrade'),
        ),
      ],
    ),
  );
}