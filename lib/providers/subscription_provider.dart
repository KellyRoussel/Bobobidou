import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/models/subscription_status.dart';
import 'package:bobobidou/services/subscription_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum PurchaseOutcome {
  /// The backend now sees the user as a subscriber.
  success,

  /// The user closed the Google Play sheet.
  cancelled,

  /// Paid, but awaiting a confirmation (slow payment method) or the backend
  /// has not seen it yet: it will appear in a moment.
  pending,
  failed,
}

/// Bobobidou Premium: the state seen by the backend (which decides who may send
/// photos) and the purchase through RevenueCat / Google Play.
///
/// The RevenueCat customer is identified by the id the backend gives
/// ([SubscriptionStatus.appUserId], an HMAC of the email): the subscription
/// follows the person, not the account, and RevenueCat never sees the email.
class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();

  SubscriptionStatus? _status;
  bool _isLoading = false;
  bool _signedIn = false;
  Package? _package;
  Future<bool>? _storeReady;

  SubscriptionStatus? get status => _status;
  bool get isLoading => _isLoading;
  bool get isPremium => _status?.premium ?? false;

  /// Price of the monthly subscription as Google Play shows it (local currency),
  /// null until the store answered.
  String? get price => _package?.storeProduct.priceString;

  /// Called by the ProxyProvider each time AuthProvider changes.
  void updateAuth(bool isAuthenticated) {
    if (isAuthenticated == _signedIn) return;
    _signedIn = isAuthenticated;
    // Not during the build that triggered the update
    Future.microtask(isAuthenticated ? load : _signOut);
  }

  /// Reads the state from the backend (and identifies the user to RevenueCat).
  /// Returns null if the backend can't be reached.
  Future<SubscriptionStatus?> load() async {
    if (!_signedIn) return null;
    _isLoading = true;
    notifyListeners();
    try {
      _status = await _service.fetchStatus();
      await _logInStore(_status!.appUserId);
    } catch (e) {
      debugPrint('Subscription status error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _status;
  }

  /// Buys the monthly subscription, then waits for the backend to see it.
  Future<PurchaseOutcome> purchase() async {
    final status = _status ?? await load();
    if (status == null || !await _logInStore(status.appUserId)) return PurchaseOutcome.failed;
    final package = _package ?? await _loadPackage();
    if (package == null) return PurchaseOutcome.failed;

    try {
      await Purchases.purchase(PurchaseParams.package(package));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return PurchaseOutcome.cancelled;
      if (code == PurchasesErrorCode.paymentPendingError) return PurchaseOutcome.pending;
      debugPrint('Purchase error: $code ${e.message}');
      return PurchaseOutcome.failed;
    }
    return await _refreshFromStore() ? PurchaseOutcome.success : PurchaseOutcome.pending;
  }

  /// "Restore my purchases": brings a subscription bought with this Google
  /// account (on another Bobobidou account, or before a reinstall) back here.
  Future<bool> restore() async {
    final status = _status ?? await load();
    if (status == null || !await _logInStore(status.appUserId)) return false;
    try {
      await Purchases.restorePurchases();
    } on PlatformException catch (e) {
      debugPrint('Restore error: ${e.message}');
      return false;
    }
    return _refreshFromStore();
  }

  /// After a purchase or a restore: the backend reads RevenueCat right away.
  Future<bool> _refreshFromStore() async {
    try {
      _status = await _service.refreshStatus();
    } catch (e) {
      debugPrint('Subscription refresh error: $e');
    }
    notifyListeners();
    return isPremium;
  }

  Future<bool> _configureStore() {
    return _storeReady ??= () async {
      final apiKey = AppConfig.revenueCatApiKey;
      if (apiKey.isEmpty || defaultTargetPlatform != TargetPlatform.android) return false;
      try {
        await Purchases.configure(PurchasesConfiguration(apiKey));
        return true;
      } catch (e) {
        debugPrint('RevenueCat configuration error: $e');
        return false;
      }
    }();
  }

  Future<bool> _logInStore(String appUserId) async {
    if (!await _configureStore()) return false;
    try {
      if (await Purchases.appUserID != appUserId) {
        await Purchases.logIn(appUserId);
      }
      _package ??= await _loadPackage();
      return true;
    } on PlatformException catch (e) {
      debugPrint('RevenueCat login error: ${e.message}');
      return false;
    }
  }

  Future<Package?> _loadPackage() async {
    try {
      final offerings = await Purchases.getOfferings();
      _package = offerings.current?.monthly;
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('RevenueCat offerings error: ${e.message}');
    }
    return _package;
  }

  Future<void> _signOut() async {
    _status = null;
    notifyListeners();
    if (_storeReady == null || !await _storeReady!) return;
    try {
      if (!await Purchases.isAnonymous) await Purchases.logOut();
    } on PlatformException catch (e) {
      debugPrint('RevenueCat logout error: ${e.message}');
    }
  }
}
