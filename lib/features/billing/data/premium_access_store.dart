import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'billing_service.dart';

class PremiumAccessStore extends ChangeNotifier {
  PremiumAccessStore({BillingService? billingService})
    : _billingService = billingService ?? BillingService() {
    _billingService.addListener(_handleBillingUpdates);
  }

  static const freeActiveReminderLimit = 2;
  static const _premiumKey = 'is_premium_user';

  bool _isPremium = false;
  final BillingService _billingService;

  BillingService get billingService => _billingService;

  bool get isPremium => _isPremium;

  Future<void> initializeBilling() async {
    await _billingService.initialize();
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _isPremium = preferences.getBool(_premiumKey) ?? false;
  }

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_premiumKey, value);
    notifyListeners();
  }

  @override
  void dispose() {
    _billingService.removeListener(_handleBillingUpdates);
    _billingService.disposeService();
    super.dispose();
  }

  void _handleBillingUpdates() {
    if (_billingService.hasPurchasedPremium && !_isPremium) {
      setPremium(true);
      _billingService.clearPurchasedPremiumFlag();
    } else {
      notifyListeners();
    }
  }
}