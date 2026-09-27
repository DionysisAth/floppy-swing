import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ad unit ids. These are Google's public **test** ids, which always serve
/// test ads. Replace them with your own AdMob ids before release (and the app
/// ids in AndroidManifest.xml / Info.plist).
abstract final class AdIds {
  static String get rewarded => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';

  static String get interstitial => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';
}

/// Rewarded video ads (the player chooses to watch them) and occasional
/// interstitials between levels (see [ProgressStore.interstitialDue]).
abstract class AdsService extends ChangeNotifier {
  bool get rewardedReady;

  bool get interstitialReady;

  /// Shows an interstitial if one is loaded; completes when it closes.
  Future<void> showInterstitial();

  /// Whether the privacy options entry point must be shown (GDPR).
  bool get privacyOptionsRequired;

  Future<void> init();

  /// Shows a rewarded ad. Completes with true if the reward was earned.
  Future<bool> showRewarded();

  Future<void> showPrivacyOptions();
}

/// No ads (tests, unsupported platforms, or after "remove ads").
class NoAdsService extends AdsService {
  NoAdsService({this.grantRewards = false});

  /// When true, "watching" an ad instantly grants the reward. Handy in debug.
  final bool grantRewards;

  @override
  bool get rewardedReady => grantRewards;
  @override
  bool get interstitialReady => false;
  @override
  Future<void> showInterstitial() async {}
  @override
  bool get privacyOptionsRequired => false;
  @override
  Future<void> init() async {}
  @override
  Future<bool> showRewarded() async => grantRewards;
  @override
  Future<void> showPrivacyOptions() async {}
}

/// Google Mobile Ads with the User Messaging Platform consent flow (GDPR and,
/// on iOS, the App Tracking Transparency explainer configured in AdMob).
class GoogleAdsService extends AdsService {
  RewardedAd? _rewarded;
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  bool _loading = false;
  bool _canRequest = false;
  bool _privacyRequired = false;
  int _retry = 0;

  @override
  bool get rewardedReady => _rewarded != null;
  @override
  bool get interstitialReady => _interstitial != null;
  @override
  bool get privacyOptionsRequired => _privacyRequired;

  @override
  Future<void> init() async {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) debugPrint('Consent form: ${error.message}');
        });
        if (!done.isCompleted) done.complete();
      },
      (error) {
        debugPrint('Consent info: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
    _canRequest = await ConsentInformation.instance.canRequestAds();
    _privacyRequired =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
    if (_canRequest) {
      await MobileAds.instance.initialize();
      _load();
      _loadInterstitial();
    }
    notifyListeners();
  }

  void _load() {
    if (_loading || _rewarded != null || !_canRequest) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _retry = 0;
          _rewarded = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          debugPrint('Rewarded failed to load: ${error.message}');
          // Back off: 5s, 10s, 20s ... up to a couple of minutes.
          final wait = Duration(seconds: (5 << _retry).clamp(5, 120));
          _retry = (_retry + 1).clamp(0, 5);
          Timer(wait, _load);
        },
      ),
    );
  }

  void _loadInterstitial() {
    if (_loadingInterstitial || _interstitial != null || !_canRequest) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          debugPrint('Interstitial failed to load: ${error.message}');
          Timer(const Duration(seconds: 60), _loadInterstitial);
        },
      ),
    );
  }

  @override
  Future<void> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    _interstitial = null;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
        _loadInterstitial();
      },
    );
    await ad.show();
    return closed.future;
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null) {
      _load();
      return false;
    }
    _rewarded = null;
    notifyListeners();
    final result = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!result.isCompleted) result.complete(earned);
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!result.isCompleted) result.complete(false);
        _load();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return result.future;
  }

  @override
  Future<void> showPrivacyOptions() async {
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('Privacy options: ${error.message}');
    });
    _canRequest = await ConsentInformation.instance.canRequestAds();
    notifyListeners();
  }
}
