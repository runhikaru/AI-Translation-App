import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:transform_app/pages/settings_page.dart';
import 'package:transform_app/utils/fade_animation.dart';
import 'package:transform_app/utils/utils.dart';
import 'package:translator/translator.dart';

import '../utils/ad_helper.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final textController = TextEditingController();

  bool us = true,
      uk = true,
      ja = true,
      cn = true,
      ko = true,
      fr = true,
      es = true,
      de = true,
      it = true,
      ru = true,
      hi = true;

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
        size: AdSize.mediumRectangle,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
        }),
        request: AdRequest())
      ..load();

    _loadRewardedAd();
  }

  int counter = 0;

  bool _isRewardedAdReady = false;

  RewardedAd? _rewardedAd;

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
        this._rewardedAd = ad;
        ad.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
          setState(() {
            _isRewardedAdReady = false;
          });
          _loadRewardedAd();
        });
        setState(() {
          _isRewardedAdReady = true;
        });
      }, onAdFailedToLoad: (error) {
        setState(() {
          _isRewardedAdReady = false;
        });
      }),
    );
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    textController.dispose();
    super.dispose();
  }

  FlutterTts flutterTts = FlutterTts();
  GoogleTranslator translator = GoogleTranslator();
  String inputText = '';
  bool _loading = false;
  List<String> _translatedTexts = [];
  final List<String> _languagesCode = [
    'en',
    'ja',
    'zh-cn',
    'ko',
    'fr',
    'es',
    'de',
    'it',
    'ru',
    'hi',
  ];

  Future translate() async {
    List<String> translatedTexts = [];
    setState(() {
      _loading = true;
    });
    for (String code in _languagesCode) {
      Translation translation = await translator.translate(inputText, to: code);
      String translatedText = translation.text;
      translatedTexts.add(translatedText);
    }
    setState(() {
      _translatedTexts = translatedTexts;
      _loading = false;
    });
  }

  Future speak(String languageCode, String text) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Search TextField
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 12,
                        child: CupertinoTextField(
                          minLines: 5,
                          maxLines: 8,
                          controller: textController,
                          style: const TextStyle(color: Colors.black45),
                          placeholder: "テキストを入力またはペーストしてください。",
                          suffix: CupertinoButton(
                            child: const Icon(CupertinoIcons.clear),
                            onPressed: () {
                              textController.clear();
                            },
                          ),
                          onChanged: (input) {
                            setState(() {
                              inputText = input;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: SpinKitCubeGrid(
                                color: Colors.black54,
                                size: 25,
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                primary: Colors.white,
                              ),
                              onPressed: () {
                                if (inputText.isNotEmpty) {
                                  translate();

                                  counter++;
                                  if (counter >= 5) {
                                    counter = 0;
                                    _rewardedAd?.show(
                                        onUserEarnedReward: (_, reward) {});
                                  }
                                }
                              },
                              child: Icon(Icons.search,
                                  color: inputText.isNotEmpty
                                      ? Colors.black
                                      : Colors.black45),
                            ),
                    )
                  ],
                ),
              ),

              //
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Visibility(
                      visible: us,
                      child: FadeAnimation(
                        delay: 1.2,
                        child: Slidable(
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: ScrollMotion(), // (5)
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  setState(() {
                                    us ^= true;
                                  });
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Remove',
                              )
                            ],
                          ),
                          child: buildLangButton(
                              lang: "en-US",
                              tt: 0,
                              countryImage: "assets/country/united-states.png",
                              countryName: "United States American",
                              decoration: langDecoration1,
                              delay: 5),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: uk,
                      child: FadeAnimation(
                        delay: 1.0,
                        child: Slidable(
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: ScrollMotion(), // (5)
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  setState(() {
                                    uk ^= true;
                                  });
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Remove',
                              )
                            ],
                          ),
                          child: buildLangButton(
                              lang: "en-GB",
                              tt: 0,
                              countryImage: "assets/country/united-kingdom.png",
                              countryName: "United Kingdom",
                              decoration: langDecoration2,
                              delay: 4),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: ja,
                      child: FadeAnimation(
                        delay: 0.8,
                        child: Slidable(
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: ScrollMotion(), // (5)
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  setState(() {
                                    ja ^= true;
                                  });
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: '削除',
                              )
                            ],
                          ),
                          child: buildLangButton(
                              lang: "ja-JP",
                              tt: 1,
                              countryImage: "assets/country/japan.png",
                              countryName: "日本",
                              decoration: langDecoration1,
                              delay: 4.5),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: cn,
                      child: FadeAnimation(
                        delay: 0.6,
                        child: Slidable(
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: ScrollMotion(), // (5)
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  setState(() {
                                    cn ^= true;
                                  });
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: '消除',
                              )
                            ],
                          ),
                          child: buildLangButton(
                              lang: "zh-CN",
                              tt: 2,
                              countryImage: "assets/country/china.png",
                              countryName: "中国",
                              decoration: langDecoration2,
                              delay: 3),
                        ),
                      ),
                    ),

                    //Banner広告
                    if (_isBannerAdReady)
                      SizedBox(
                        height: _bannerAd.size.height.toDouble(),
                        width: _bannerAd.size.width.toDouble(),
                        child: AdWidget(ad: _bannerAd),
                      ),

                    Visibility(
                      visible: ko,
                      child: FadeAnimation(
                        delay: 0.4,
                        child: Slidable(
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: ScrollMotion(), // (5)
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  setState(() {
                                    ko ^= true;
                                  });
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: '제거하다',
                              )
                            ],
                          ),
                          child: buildLangButton(
                              lang: "ko-KR",
                              tt: 3,
                              countryImage: "assets/country/korea.png",
                              countryName: "한국",
                              decoration: langDecoration1,
                              delay: 3.5),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: fr,
                      child: Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: ScrollMotion(), // (5)
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                setState(() {
                                  fr ^= true;
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Supprimer',
                            )
                          ],
                        ),
                        child: buildLangButton(
                            lang: "fr-FR",
                            tt: 4,
                            countryImage: "assets/country/france.png",
                            countryName: "France",
                            decoration: langDecoration2,
                            delay: 3),
                      ),
                    ),
                    Visibility(
                      visible: es,
                      child: Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: ScrollMotion(), // (5)
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                setState(() {
                                  es ^= true;
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Borrar',
                            )
                          ],
                        ),
                        child: buildLangButton(
                            lang: "es-ES",
                            tt: 5,
                            countryImage: "assets/country/spain.png",
                            countryName: "España",
                            decoration: langDecoration1,
                            delay: 2.5),
                      ),
                    ),
                    Visibility(
                      visible: de,
                      child: Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: ScrollMotion(), // (5)
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                setState(() {
                                  de ^= true;
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Supprimer',
                            )
                          ],
                        ),
                        child: buildLangButton(
                            lang: "de-DE",
                            tt: 6,
                            countryImage: "assets/country/germany.png",
                            countryName: "Deutschland",
                            decoration: langDecoration2,
                            delay: 2),
                      ),
                    ),
                    Visibility(
                      visible: it,
                      child: Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: ScrollMotion(), // (5)
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                setState(() {
                                  it ^= true;
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'löschen',
                            )
                          ],
                        ),
                        child: buildLangButton(
                            lang: "it-IT",
                            tt: 7,
                            countryImage: "assets/country/italy.png",
                            countryName: "Italia",
                            decoration: langDecoration1,
                            delay: 1.5),
                      ),
                    ),
                    Visibility(
                      visible: ru,
                      child: Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: ScrollMotion(), // (5)
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                setState(() {
                                  ru ^= true;
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'löschen',
                            )
                          ],
                        ),
                        child: buildLangButton(
                            lang: "ru-RU",
                            tt: 8,
                            countryImage: "assets/country/russia.png",
                            countryName: "Россия",
                            decoration: langDecoration2,
                            delay: 1),
                      ),
                    ),
                    Visibility(
                      visible: hi,
                      child: Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: ScrollMotion(), // (5)
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                setState(() {
                                  hi ^= true;
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'eliminare',
                            )
                          ],
                        ),
                        child: buildLangButton(
                            lang: "hi-IN",
                            tt: 9,
                            countryImage: "assets/country/india.png",
                            countryName: "Hindu",
                            decoration: langDecoration1,
                            delay: 0),
                      ),
                    ),

                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: [
                          Visibility(
                            visible: !us,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    us ^= true;
                                  });
                                },
                                child: CountryChips("United States American")),
                          ),
                          Visibility(
                            visible: !uk,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    uk ^= true;
                                  });
                                },
                                child: CountryChips("United States Kingdom")),
                          ),
                          Visibility(
                            visible: !ja,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ja ^= true;
                                  });
                                },
                                child: CountryChips("日本")),
                          ),
                          Visibility(
                            visible: !cn,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    cn ^= true;
                                  });
                                },
                                child: CountryChips("中国")),
                          ),
                          Visibility(
                            visible: !ko,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ko ^= true;
                                  });
                                },
                                child: CountryChips("한국")),
                          ),
                          Visibility(
                            visible: !fr,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    fr ^= true;
                                  });
                                },
                                child: CountryChips("France")),
                          ),
                          Visibility(
                            visible: !es,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    es ^= true;
                                  });
                                },
                                child: CountryChips("España")),
                          ),
                          Visibility(
                            visible: !de,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    de ^= true;
                                  });
                                },
                                child: CountryChips("Deutschland")),
                          ),
                          Visibility(
                            visible: !it,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    it ^= true;
                                  });
                                },
                                child: CountryChips("Italia")),
                          ),
                          Visibility(
                            visible: !ru,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ru ^= true;
                                  });
                                },
                                child: CountryChips("Россия")),
                          ),
                          Visibility(
                            visible: !hi,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    hi ^= true;
                                  });
                                },
                                child: CountryChips("Hindu")),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool RemoveButton(bool country) {
    country = !country;
    return country;
  }

  Widget CountryChips(String countryName) {
    return Chip(
      elevation: 8.0,
      padding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
      label: Text(countryName),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          width: 1,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Future hideBar() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  Widget buildLangButton(
      {required String lang,
      required int tt,
      required String countryImage,
      required String countryName,
      required LinearGradient decoration,
      required double delay}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          if (_translatedTexts.isNotEmpty) speak(lang, _translatedTexts[tt]);
        },
        child: Card(
          elevation: 12,
          child: Container(
            // color: const Color(0xff263238),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Column(
                  children: [
                    Image.asset(
                      countryImage,
                      width: 50,
                    ),
                    _translatedTexts.isEmpty
                        ? Container()
                        : const Icon(
                            Icons.record_voice_over,
                            color: Colors.black,
                          )
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextSelectionTheme(
                    data: const TextSelectionThemeData(),
                    child: Text(
                      _translatedTexts.isEmpty
                          ? countryName
                          : _translatedTexts[tt],
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  child: _translatedTexts.isEmpty
                      ? null
                      : Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  final data =
                                      ClipboardData(text: _translatedTexts[tt]);
                                  Clipboard.setData(data);

                                  showSnackbar(lang, countryImage);
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.black,
                                )),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackbar(
    String lang,
    String countryImage,
  ) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      margin: const EdgeInsetsDirectional.all(16),
      content: Row(
        children: [
          Image.asset(
            countryImage,
            width: 50,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          Text(
            CheckCopyText(lang),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      showCloseIcon: true,
      elevation: 4.0,
      backgroundColor: Colors.black,
      closeIconColor: Colors.green,
      clipBehavior: Clip.hardEdge,
      dismissDirection: DismissDirection.up,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String CheckCopyText(String lang) {
    if (lang == "en-US" || lang == "en-GB") {
      return "Copy";
    } else if (lang == "ja-JP") {
      return "コピーしました";
    } else if (lang == "zh-CN") {
      return "复制";
    } else if (lang == "ko-KR") {
      return "복사";
    } else if (lang == "fr-FR" || lang == "it-IT") {
      return "Copie";
    } else if (lang == "es-ES") {
      return "Copiar";
    } else if (lang == "de-DE") {
      return "Kopieren";
    } else if (lang == "ru-RU") {
      return "Копия";
    } else if (lang == "hi-IN") {
      return "प्रतिलिपि";
    }
    return "XXX";
  }

  // void Review() {
  //   AppReview.requestReview.then((onValue) {
  //     print(onValue);
  //   });
  // }
}
