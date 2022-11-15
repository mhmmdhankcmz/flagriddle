import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdMainId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2723435209726138/3883813884';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2723435209726138~4059427954';
    }
    return null;
  }

  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2723435209726138/4618078576';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2723435209726138~4059427954';
    }
    return null;
  }

  // static String? get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     return 'ca-app-pub-2723435209726138~4059427954';
  //   } else if (Platform.isIOS) {
  //     return 'ca-app-pub-2723435209726138~4059427954';
  //   }
  //   return null;
  // }

  // static String? get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return 'ca-app-pub-2723435209726138~4059427954';
  //   } else if (Platform.isIOS) {
  //     return 'ca-app-pub-2723435209726138~4059427954';
  //   }
  //   return null;
  // }
  static final BannerAdListener bannerListener = BannerAdListener(
      onAdLoaded: (ad) => debugPrint('Ad loaded'),
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        debugPrint('Ad failed to load: $error');
      });
}
