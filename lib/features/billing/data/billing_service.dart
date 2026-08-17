import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum BillingAvailabilityState {
  initial,
  available,
  unavailable,
  productNotFound,
  error,
}

class BillingService extends ChangeNotifier {
  BillingService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  static const premiumUnlockProductId =
      'com.jasapart.ireminder.premium_unlock';

  final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? _premiumProduct;
  BillingAvailabilityState _availabilityState = BillingAvailabilityState.initial;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPurchasedPremium = false;

  ProductDetails? get premiumProduct => _premiumProduct;
  BillingAvailabilityState get availabilityState => _availabilityState;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPurchasedPremium => _hasPurchasedPremium;

  Future<void> initialize() async {
    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _availabilityState = BillingAvailabilityState.error;
        _errorMessage = '$error';
        notifyListeners();
      },
    );

    await refreshStoreState();
  }

  Future<void> refreshStoreState() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      _availabilityState = BillingAvailabilityState.unavailable;
      _premiumProduct = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await _inAppPurchase.queryProductDetails({
      premiumUnlockProductId,
    });

    if (response.error != null) {
      _availabilityState = BillingAvailabilityState.error;
      _errorMessage = response.error!.message;
      _premiumProduct = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (response.productDetails.isEmpty) {
      _availabilityState = BillingAvailabilityState.productNotFound;
      _premiumProduct = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _premiumProduct = response.productDetails.first;
    _availabilityState = BillingAvailabilityState.available;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> buyPremiumUnlock() async {
    final product = _premiumProduct;
    if (product == null) {
      return;
    }

    final param = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  void clearPurchasedPremiumFlag() {
    _hasPurchasedPremium = false;
    notifyListeners();
  }

  Future<void> disposeService() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != premiumUnlockProductId) {
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _hasPurchasedPremium = true;
          break;
        case PurchaseStatus.error:
          _errorMessage = purchase.error?.message;
          _availabilityState = BillingAvailabilityState.error;
          break;
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }

    notifyListeners();
  }
}