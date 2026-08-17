import 'package:flutter/material.dart';

import '../../data/billing_service.dart';
import '../../data/premium_access_store.dart';

const _debugPremiumCode = '126543';

Future<void> showUpgradePrompt(
  BuildContext context, {
  required PremiumAccessStore premiumAccessStore,
}) {
  final billingService = premiumAccessStore.billingService;

  return showDialog<void>(
    context: context,
    builder: (context) => ListenableBuilder(
      listenable: billingService,
      builder: (context, _) {
        final product = billingService.premiumProduct;
        final availability = billingService.availabilityState;
        final isLoading = billingService.isLoading;

        var message =
            'Free version supports up to 2 active reminders. Upgrade to Premium for unlimited reminders.';

        if (availability == BillingAvailabilityState.productNotFound) {
          message =
              'Premium purchase is coming soon. Please check back shortly. You can still use Add code for testing.';
        } else if (availability == BillingAvailabilityState.unavailable) {
          message =
              'Purchases are temporarily unavailable on this device. You can still use Add code for testing.';
        } else if (availability == BillingAvailabilityState.error &&
            billingService.errorMessage != null) {
          message =
              'Purchase service is not ready yet. ${billingService.errorMessage}\n\nYou can still use Add code for testing.';
        }

        return AlertDialog(
          title: const Text('Upgrade to Premium'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              if (product != null)
                Text(
                  'One-time purchase: ${product.price}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              if (isLoading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
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
              onPressed: product == null ||
                      availability != BillingAvailabilityState.available ||
                      isLoading
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await billingService.buyPremiumUnlock();
                    },
              child: Text(product == null ? 'Purchase coming soon' : 'Buy now'),
            ),
          ],
        );
      },
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