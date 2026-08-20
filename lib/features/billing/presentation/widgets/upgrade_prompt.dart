import 'package:flutter/material.dart';

import '../../data/billing_service.dart';
import '../../data/premium_access_store.dart';
import '../../../../l10n/app_localizations.dart';

const _debugPremiumCode = '126543';

Future<void> showUpgradePrompt(
  BuildContext context, {
  required PremiumAccessStore premiumAccessStore,
}) {
  final billingService = premiumAccessStore.billingService;
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (context) => ListenableBuilder(
      listenable: billingService,
      builder: (context, _) {
        final product = billingService.premiumProduct;
        final availability = billingService.availabilityState;
        final isLoading = billingService.isLoading;

        var message = l10n.upgradeMessage;

        if (availability == BillingAvailabilityState.productNotFound) {
          message = l10n.upgradeComingSoon;
        } else if (availability == BillingAvailabilityState.unavailable) {
          message = l10n.upgradeUnavailable;
        } else if (availability == BillingAvailabilityState.error &&
            billingService.errorMessage != null) {
          message = l10n.purchaseServiceNotReady(
            billingService.errorMessage!,
          );
        }

        return AlertDialog(
          title: Text(l10n.upgradeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              if (product != null)
                Text(
                  l10n.oneTimePurchase(product.price),
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
              child: Text(l10n.cancel),
            ),
            FilledButton.tonal(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showPremiumCodeDialog(
                  context,
                  premiumAccessStore: premiumAccessStore,
                );
              },
              child: Text(l10n.addCode),
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
              child: Text(
                product == null ? l10n.purchaseComingSoon : l10n.buyNow,
              ),
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
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.addCodeTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: l10n.codeLabel,
          hintText: l10n.codeHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () async {
            final code = controller.text.trim();
            Navigator.of(context).pop();
            if (code == _debugPremiumCode) {
              await premiumAccessStore.setPremium(true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.premiumEnabledSnack)),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.invalidCode)),
                );
              }
            }
          },
          child: Text(l10n.apply),
        ),
      ],
    ),
  );
}