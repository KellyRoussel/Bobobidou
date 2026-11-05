import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/models/subscription_status.dart';
import 'package:bobobidou/providers/auth_provider.dart';
import 'package:bobobidou/services/auth_service.dart';
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

enum RestoreOutcome {
  /// The backend now sees the user as a subscriber.
  restored,

  /// The store answered: no subscription on this Google Play account.
  nothingToRestore,

  /// The store or the backend could not be reached.
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
  AuthProvider? _auth;
  // Incremented at each sign-in / sign-out: a request started for a previous
  // session must not write its result into the current one
  int _session = 0;
  Package? _package;
  Future<bool>? _storeReady;

  SubscriptionStatus? get status => _status;
  bool get isLoading => _isLoading;
  bool get isPremium => _status?.premium ?? false;

  /// Price of the monthly subscription as Google Play shows it (local currency),
  /// null until the store answered.
  String? get price => _package?.storeProduct.priceString;

  /// Called by the ProxyProvider each time AuthProvider changes.
  void updateAuth(AuthProvider auth) {
    _auth = auth;
    if (auth.isAuthenticated == _signedIn) return;
    _signedIn = auth.isAuthenticated;
    _session++;
    _status = null;
    _isLoading = false;
    // Not during the build that triggered the update
    Future.microtask(_signedIn ? load : _signOut);
  }

  /// Reads the state from the backend (and identifies the user to RevenueCat).
  /// Returns null if the backend can't be reached: the caller must not act on
  /// an older state.
  Future<SubscriptionStatus?> load() async {
    if (!_signedIn) return null;
    final session = _session;
    _isLoading = true;
    notifyListeners();
    SubscriptionStatus? status;
    try {
      status = await _service.fetchStatus();
      if (session != _session) return null;
      _status = status;
      await _logInStore(status.appUserId, session);
    } on SessionExpiredException {
      if (session == _session) _sessionLost();
      status = null;
    } catch (e) {
      debugPrint('Subscription status error: $e');
      status = null;
    } finally {
      if (session == _session) {
        _isLoading = false;
        notifyListeners();
      }
    }
    return session == _session ? status : null;
  }

  /// The backend refused the session: tokens are already cleared, the whole
  /// app goes back to signed out.
  void _sessionLost() {
    _auth?.sessionExpired();
  }

  /// Buys the monthly subscription, then waits for the backend to see it.
  Future<PurchaseOutcome> purchase() async {
    final status = _status ?? await load();
    if (status == null || !await _logInStore(status.appUserId, _session)) return PurchaseOutcome.failed;
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
  Future<RestoreOutcome> restore() async {
    final status = _status ?? await load();
    if (status == null || !await _logInStore(status.appUserId, _session)) return RestoreOutcome.failed;
    final CustomerInfo customerInfo;
    try {
      customerInfo = await Purchases.restorePurchases();
    } on PlatformException catch (e) {
      debugPrint('Restore error: ${e.message}');
      return RestoreOutcome.failed;
    }
    if (await _refreshFromStore()) return RestoreOutcome.restored;
    // Not premium for the backend: either really nothing to restore, or the
    // backend could not be asked (then it's a failure, not "nothing")
    if (_refreshFailed) return RestoreOutcome.failed;
    return customerInfo.entitlements.active.isEmpty ? RestoreOutcome.nothingToRestore : RestoreOutcome.failed;
  }

  bool _refreshFailed = false;

  /// After a purchase or a restore: the backend reads RevenueCat right away.
  Future<bool> _refreshFromStore() async {
    final session = _session;
    _refreshFailed = false;
    try {
      final status = await _service.refreshStatus();
      if (session != _session) return false;
      _status = status;
    } on SessionExpiredException {
      _refreshFailed = true;
      if (session == _session) _sessionLost();
      return false;
    } catch (e) {
      debugPrint('Subscription refresh error: $e');
      _refreshFailed = true;
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

  Future<bool> _logInStore(String appUserId, int session) async {
    if (!await _configureStore()) return false;
    // Signed out meanwhile: don't log the previous user back in to RevenueCat
    if (session != _session || !_signedIn) return false;
    try {
      if (await Purchases.appUserID != appUserId) {
        await Purchases.logIn(appUserId);
        if (session != _session || !_signedIn) {
          // Signed out while logging in: undo it
          await Purchases.logOut();
          return false;
        }
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
    notifyListeners();
    if (_storeReady == null || !await _storeReady!) return;
    try {
      if (!await Purchases.isAnonymous) await Purchases.logOut();
    } on PlatformException catch (e) {
      debugPrint('RevenueCat logout error: ${e.message}');
    }
  }
}
