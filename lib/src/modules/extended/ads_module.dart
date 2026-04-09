import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs google_mobile_ads with an AdsService contract.
class AdsModule implements AgenticModule {
  const AdsModule();

  @override
  String get name => 'ads';

  @override
  String get description =>
      'google_mobile_ads — AdMob banner, interstitial, and rewarded ads.';

  @override
  List<String> get dependencies => ['google_mobile_ads'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'iOS: add GADApplicationIdentifier to Info.plist.',
    'Android: add com.google.android.gms.ads.APPLICATION_ID meta-data to AndroidManifest.xml.',
    'Replace test ad unit IDs in AdsServiceImpl with production IDs before release.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/ads/ads_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/ads/admob_ads_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/ads/ads_service.dart')
      ..deleteFile('lib/core/ads/admob_ads_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Ad type selector.
enum AdType { banner, interstitial, rewarded }

/// Ads service contract.
abstract class AdsService {
  /// Initialise the Mobile Ads SDK.
  Future<void> initialize();

  /// Load an interstitial ad for [adUnitId].
  Future<void> loadInterstitial(String adUnitId);

  /// Show the loaded interstitial ad.
  Future<void> showInterstitial();

  /// Load a rewarded ad for [adUnitId].
  Future<void> loadRewarded(String adUnitId);

  /// Show the loaded rewarded ad; calls [onReward] when the user earns a reward.
  Future<void> showRewarded({required void Function(String type, int amount) onReward});
}
''';

  String _implContent(String pkg) => '''
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:$pkg/core/ads/ads_service.dart';

/// AdMob implementation of [AdsService].
class AdmobAdsService implements AdsService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  @override
  Future<void> showInterstitial() async {
    await _interstitialAd?.show();
    _interstitialAd = null;
  }

  @override
  Future<void> loadRewarded(String adUnitId) async {
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  @override
  Future<void> showRewarded({
    required void Function(String type, int amount) onReward,
  }) async {
    await _rewardedAd?.show(
      onUserEarnedReward: (_, reward) => onReward(reward.type, reward.amount.toInt()),
    );
    _rewardedAd = null;
  }
}
''';
}
