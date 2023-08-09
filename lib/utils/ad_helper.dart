import 'dart:io';

class AdHelper {
  //本番
  static String bannerId = "ca-app-pub-9774750874955739/9147064686";
  static String interstitialId = "ca-app-pub-9774750874955739/6937448715";
  static String rewordId = "ca-app-pub-9774750874955739/9230825167";
  
  //テスト
  // static String bannerId = "ca-app-pub-3940256099942544/6300978111";
  // static String interstitialId = "ca-app-pub-3940256099942544/1033173712";
  // static String rewordId = "ca-app-pub-3940256099942544/6300978111";

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return bannerId;
    } else if (Platform.isIOS) {
      return bannerId;
    } else {
      throw UnsupportedError("このプラットフォームでは対応していません");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return interstitialId;
    } else if (Platform.isIOS) {
      return interstitialId;
    } else {
      throw UnsupportedError("このプラットフォームでは対応していません");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return rewordId;
    } else if (Platform.isIOS) {
      return rewordId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
