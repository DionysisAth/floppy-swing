import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../game/store_products.dart';
import 'progress.dart';

/// Real-money purchases (gem packs, Starter Pack, No Ads, Premium Pass).
///
/// There's no server: purchases are paid out on the device as soon as the
/// store reports them, recorded by transaction id so nothing is paid twice
/// (see [ProgressStore.deliverPurchase]), and only then finished with the
/// store, so a crash mid-purchase gets redelivered instead of lost.
abstract class PurchaseService extends ChangeNotifier {
  /// Whether the store can be reached and products can be bought.
  bool get available;

  /// A purchase is in flight (show a spinner, block double taps).
  bool get busy;

  /// The store's localized price for [p], or its fallback price.
  String priceOf(StoreProduct p);

  /// A short message about the last purchase ("Thanks!", an error...), for a
  /// snackbar. Cleared with [takeMessage].
  String? get message;

  String? takeMessage();

  Future<void> init();

  /// Starts buying [p]. The result arrives later through the store; the
  /// progress store updates when it's paid out.
  Future<void> buy(StoreProduct p);

  /// Restores once-only purchases (App Store review requires a button).
  Future<void> restore();
}

/// No store (tests, desktop). With [instant], buying grants right away,
/// which makes the shop testable in debug builds.
class NoPurchaseService extends PurchaseService {
  NoPurchaseService(this.progress, {this.instant = false});

  final ProgressStore progress;
  final bool instant;
  String? _message;
  var _n = 0;

  @override
  bool get available => instant;
  @override
  bool get busy => false;
  @override
  String priceOf(StoreProduct p) => p.fallbackPrice;
  @override
  String? get message => _message;
  @override
  String? takeMessage() {
    final m = _message;
    _message = null;
    return m;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> buy(StoreProduct p) async {
    if (!instant) return;
    if (progress.deliverPurchase(p, 'debug_${p.id}_${_n++}')) _message = _thanks(p);
    notifyListeners();
  }

  @override
  Future<void> restore() async {}
}

String _thanks(StoreProduct p) => 'Thanks! ${p.name} unlocked.';

/// Google Play Billing / StoreKit through the `in_app_purchase` plugin.
class StorePurchaseService extends PurchaseService {
  StorePurchaseService(this.progress);

  final ProgressStore progress;
  final InAppPurchase _iap = InAppPurchase.instance;
  final Map<String, ProductDetails> _details = {};
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _available = false;
  bool _busy = false;
  String? _message;

  @override
  bool get available => _available && _details.isNotEmpty;
  @override
  bool get busy => _busy;
  @override
  String priceOf(StoreProduct p) => _details[p.id]?.price ?? p.fallbackPrice;
  @override
  String? get message => _message;
  @override
  String? takeMessage() {
    final m = _message;
    _message = null;
    return m;
  }

  @override
  Future<void> init() async {
    // Listen first: the store redelivers unfinished purchases right away.
    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (Object e) => debugPrint('Purchase stream: $e'));
    _available = await _iap.isAvailable();
    if (!_available) {
      notifyListeners();
      return;
    }
    final response = await _iap.queryProductDetails({for (final p in storeProducts) p.id});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Store products not set up yet: ${response.notFoundIDs.join(', ')}');
    }
    for (final d in response.productDetails) {
      _details[d.id] = d;
    }
    // Google Play only reports owned-but-unfinished purchases (e.g. a gem
    // pack paid for just before a crash) when asked.
    if (Platform.isAndroid) {
      unawaited(_iap.restorePurchases().catchError((Object e) => debugPrint('Restore: $e')));
    }
    notifyListeners();
  }

  @override
  Future<void> buy(StoreProduct p) async {
    final details = _details[p.id];
    if (details == null || _busy || !progress.canBuyProduct(p)) return;
    _busy = true;
    notifyListeners();
    try {
      final param = PurchaseParam(productDetails: details);
      // Consumables are consumed by hand after paying out (see _onPurchases).
      final started = p.consumable
          ? await _iap.buyConsumable(purchaseParam: param, autoConsume: false)
          : await _iap.buyNonConsumable(purchaseParam: param);
      if (!started) _busy = false;
    } catch (e) {
      debugPrint('Purchase failed to start: $e');
      _busy = false;
      _message = 'The store is busy. Please try again.';
    }
    notifyListeners();
  }

  @override
  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
      _message = 'Purchases restored.';
    } catch (e) {
      _message = "Couldn't reach the store.";
    }
    notifyListeners();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final pd in purchases) {
      final product = storeProductById(pd.productID);
      switch (pd.status) {
        case PurchaseStatus.pending:
          _busy = true;
        case PurchaseStatus.canceled:
          _busy = false;
        case PurchaseStatus.error:
          _busy = false;
          _message = 'Purchase failed. You have not been charged.';
          debugPrint('Purchase error: ${pd.error}');
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _busy = false;
          if (product != null && progress.deliverPurchase(product, pd.purchaseID)) {
            _message = _thanks(product);
          }
          if (product != null && product.consumable && Platform.isAndroid) {
            final android = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            await android.consumePurchase(pd);
            continue;
          }
      }
      if (pd.pendingCompletePurchase) await _iap.completePurchase(pd);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
