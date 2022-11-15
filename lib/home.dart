import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flagquiz/QuizEkrani.dart';
import 'package:flagquiz/ad_mob_service.dart';
import 'package:flagquiz/translations/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BannerAd? _banner;
  bool _volume = true;
  int _selectedItem = 10;
  final player = AudioPlayer();

  void soundOff() {
    if (_volume == true) {
      player.setVolume(1.0);
    } else {
      player.setVolume(0.0);
    }
  }

  @override
  void initState() {
    super.initState();

    _createBannerAd();
  }

  void _createBannerAd() {
    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdMobService.bannerAdMainId!,
      listener: AdMobService.bannerListener,
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${LocaleKeys.welcomeflaggame.tr()}',
          style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          LiteRollingSwitch(
            width: 105.0,
            value: true,
            textOn: '${LocaleKeys.on.tr()}',
            textOnColor: Colors.white,
            textOff: '${LocaleKeys.off.tr()}',
            textOffColor: Colors.black45,
            colorOn: Colors.blue,
            colorOff: Colors.blue,
            iconOn: Icons.volume_up,
            iconOff: Icons.volume_off,
            animationDuration: Duration(milliseconds: 800),
            textSize: 14,
            onChanged: (value) {
              setState(() {
                _volume = value;
                soundOff();
              });
            },
            onTap: () {},
            onDoubleTap: () {},
            onSwipe: () {},
          ),
          PopupMenuButton(
              icon: const Icon(Icons.language_rounded),
              itemBuilder: (context) => [
                    PopupMenuItem(
                        child: Text("English"),
                        onTap: () {
                          setState(() {
                            EasyLocalization.of(context)!
                                .setLocale(Locale("en"));
                          });
                        }),
                    PopupMenuItem(
                        child: Text("Türkçe"),
                        onTap: () {
                          setState(() {
                            EasyLocalization.of(context)!
                                .setLocale(Locale("tr"));
                          });
                        })
                  ])
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          final shouldPop = await showMyDialog();
          return shouldPop ?? false;
        },
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/buton/background.jpg"),
                  fit: BoxFit.cover)),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 300,
                      child: Text(
                        "${LocaleKeys.flaggame.tr()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: (Colors.blue)),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: SvgPicture.asset(
                      "assets/buton/world.svg",
                      placeholderBuilder: (context) =>
                          CircularProgressIndicator(),
                      height: 250.0,
                      width: 250.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                              color: Colors.white,
                              style: BorderStyle.solid,
                              width: 1.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: DropdownButton<int>(
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          alignment: Alignment.center,
                          elevation: 20,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          isDense: false,
                          isExpanded: false,
                          icon: Icon(
                            Icons.arrow_drop_down_circle,
                            size: 30,
                            color: Colors.white,
                          ),
                          hint: Text(
                            "${LocaleKeys.hmqwyl.tr()}  ${_selectedItem} ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          focusColor: Colors.blue,
                          items: <int>[10, 15, 20, 25, 30, 35, 40, 45, 50]
                              .map((int value) {
                            return DropdownMenuItem<int>(
                              alignment: Alignment.center,
                              value: value,
                              child: Text(
                                value.toString(),
                                style:
                                    TextStyle(fontSize: 20, color: Colors.blue),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? sayi) {
                            setState(() {
                              _selectedItem = sayi!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    // --------------------Start Butonu---------------
                    width: 300, height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0))),
                      ),
                      onPressed: () async {
                        await player.play(AssetSource("audio/beep.mp3"));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizEkrani(
                                      gelenSoru: _selectedItem,
                                      volume: _volume,
                                    )));
                        print(
                            "******************ses durumu $_volume**************");
                      },
                      child: Text(
                        "${LocaleKeys.start.tr()}",
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      EasyLocalization.of(context)!
                          .setLocale(const Locale("en"));
                    },
                    child: const Text(
                      "ENGLISH",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      EasyLocalization.of(context)!
                          .setLocale(const Locale("tr"));
                    },
                    child: const Text(
                      "TÜRKÇE",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _banner == null
          ? Container()
          : Container(
              decoration: BoxDecoration(
                color: Color(0xa9d7ef),
              ),
              margin: const EdgeInsets.all(0),
              height: 55,
              child: AdWidget(
                ad: _banner!,
              ),
            ),
    );
  }

  Future<bool> shotDownApp() async {
    await exit(0);
  }

  Future<bool?> showMyDialog() => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Do you want to exit the FlagRiddle?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('CANCEL')),
              TextButton(onPressed: () => shotDownApp(), child: Text('YES')),
            ],
          ));
}
