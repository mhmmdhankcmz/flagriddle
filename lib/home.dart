import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'QuizEkrani.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppBarTheme.of(context).backgroundColor,
          title: Text(
            'welcomeflaggame'.tr,
            style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            buildLiteRollingSwitch(),
            buildPopupMenuButton()
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
                    buildSizedBox(),
                    buildPadding(),
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
                            dropdownColor: Colors.lightBlueAccent.shade100,
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
                            hint: RichText(text: TextSpan(text: "hmqwyl".tr,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold) ,children: [TextSpan(text:" ${_selectedItem}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))])),
                            // hint: Text(
                            //   "hmqwyl  ${_selectedItem}".tr ,
                            //   style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: Colors.black),
                            // ),
                            focusColor: Colors.blue,
                            items: <int>[10, 15, 20, 25, 30, 35, 40, 45, 50]
                                .map((int value) {
                              return DropdownMenuItem<int>(
                                alignment: Alignment.center,
                                value: value,

                                child: Text("${value.toString()} Soru Sor",
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
                          foregroundColor: MaterialStateProperty.all(Colors.blue.shade400),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0))),
                        ),
                        onPressed: () async {
                          await player.play(AssetSource("audio/beep.mp3"));
                          Get.offAll(QuizEkrani(gelenSoru: _selectedItem, volume: _volume));

                          print(
                              "*ses durumu $_volume**************");
                        },
                        child: Text(
                          'start'.tr,
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // setState(() {
                        //   EasyLocalization.of(context)!
                        //       .setLocale(const Locale("en"));
                        // });
                          Get.updateLocale(const Locale('en','US'));
                      },
                      child: const Text("ENGLISH", style: TextStyle(color: Colors.white, fontSize: 16),),
                    ),
                    TextButton(
                      onPressed: () {
                          Get.updateLocale(const Locale('tr','TR'));
                          // EasyLocalization.of(context)!.setLocale(const Locale("tr"));
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
      ),
    );
  }

  Padding buildPadding() {
    return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Image.asset(
                      "assets/buton/logo.png",
                      height: 250.0,
                      width: 250.0,
                    ),
                  );
  }

  SizedBox buildSizedBox() {
    return SizedBox(
                      width: 300,
                      child: Text(
                        "flaggame".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: (Colors.blue)),
                      ));
  }

  PopupMenuButton<dynamic> buildPopupMenuButton() {
    return PopupMenuButton(
              icon: const Icon(Icons.language_rounded),
              itemBuilder: (context) => [
                    PopupMenuItem(
                        child: Text("English"),
                        onTap: () {
                         Get.updateLocale(const Locale('en','US'));
                        }),
                    PopupMenuItem(
                        child: Text("Türkçe"),
                        onTap: () {
                          Get.updateLocale(const Locale('tr','TR'));
                        })
                  ]);
  }

  LiteRollingSwitch buildLiteRollingSwitch() {
    return LiteRollingSwitch(
            width: 100.0,
            value: true,
            textOn: 'on'.tr,
            textOnColor: Colors.white,
            textOff: 'off'.tr,
            textOffColor: Colors.black45,
            colorOn: Colors.blue,
            colorOff: Colors.blue,
            iconOn: Icons.volume_up,
            iconOff: Icons.volume_off,
            animationDuration: Duration(milliseconds: 700),
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
          );
  }

  Future<bool> shotDownApp() async {
    await exit(0);
  }

  Future<bool?> showMyDialog() => showDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
            title: Text("exit".tr),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("no".tr)),
              TextButton(onPressed: () =>shotDownApp(), child: Text("yes".tr)),
            ],
          ));
}
