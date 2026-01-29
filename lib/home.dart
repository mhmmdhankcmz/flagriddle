import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'QuizEkrani.dart';
import 'controllers/theme_controller.dart';
import 'services/score_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool _volume = true;
  int _selectedItem = 10;
  int _highScore = 0;
  final player = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  Future<void> _loadHighScore() async {
    final score = await ScoreService.getHighScore();
    setState(() {
      _highScore = score;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    player.dispose();
    super.dispose();
  }

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
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            buildLiteRollingSwitch(),
            buildThemeToggle(),
            buildPopupMenuButton(),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await showMyDialog();
            if (shouldPop == true) {
              shotDownApp();
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/buton/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSizedBox(),
                      buildHighScoreCard(),
                      buildPadding(),
                      buildQuestionSelector(),
                      const SizedBox(height: 20),
                      buildStartButton(),
                      const SizedBox(height: 20),
                      buildLanguageButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHighScoreCard() {
    if (_highScore == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 8,
        color: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
              const SizedBox(width: 10),
              Text(
                '${'highScore'.tr}: %$_highScore',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuestionSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.white,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          color: Colors.black.withValues(alpha: 0.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: DropdownButton<int>(
            dropdownColor: Colors.lightBlueAccent.shade100,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            elevation: 20,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            isDense: false,
            isExpanded: false,
            icon: const Icon(
              Icons.arrow_drop_down_circle,
              size: 30,
              color: Colors.white,
            ),
            hint: RichText(
              text: TextSpan(
                text: "hmqwyl".tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: " $_selectedItem",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            focusColor: Colors.blue,
            items: <int>[10, 15, 20, 25, 30, 35, 40, 45, 50].map((int value) {
              return DropdownMenuItem<int>(
                alignment: Alignment.center,
                value: value,
                child: Text(
                  "${value.toString()} ${'askQuestion'.tr}",
                  style: const TextStyle(fontSize: 20, color: Colors.blue),
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
    );
  }

  Widget buildStartButton() {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
          backgroundColor: WidgetStateProperty.all(Colors.blue.shade600),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          ),
          elevation: WidgetStateProperty.all(8),
        ),
        onPressed: () async {
          await player.play(AssetSource("audio/beep.mp3"));
          Get.offAll(
            () => QuizEkrani(gelenSoru: _selectedItem, volume: _volume),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: Text(
          'start'.tr,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildLanguageButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () {
            Get.updateLocale(const Locale('en', 'US'));
          },
          icon: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
          label: const Text(
            "ENGLISH",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(width: 20),
        TextButton.icon(
          onPressed: () {
            Get.updateLocale(const Locale('tr', 'TR'));
          },
          icon: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
          label: const Text(
            "TÜRKÇE",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Padding buildPadding() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Hero(
        tag: 'logo',
        child: Image.asset(
          "assets/buton/logo.png",
          height: 200.0,
          width: 200.0,
        ),
      ),
    );
  }

  SizedBox buildSizedBox() {
    return SizedBox(
      width: 300,
      child: Text(
        "flaggame".tr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black26,
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildThemeToggle() {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return IconButton(
          icon: Icon(
            controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () {
            controller.toggleTheme();
          },
          tooltip: controller.isDarkMode ? 'lightMode'.tr : 'darkMode'.tr,
        );
      },
    );
  }

  PopupMenuButton<dynamic> buildPopupMenuButton() {
    return PopupMenuButton(
      icon: const Icon(Icons.language_rounded),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Text("English"),
          onTap: () {
            Get.updateLocale(const Locale('en', 'US'));
          },
        ),
        PopupMenuItem(
          child: const Text("Türkçe"),
          onTap: () {
            Get.updateLocale(const Locale('tr', 'TR'));
          },
        ),
      ],
    );
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
      animationDuration: const Duration(milliseconds: 700),
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
    exit(0);
  }

  Future<bool?> showMyDialog() => showDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("exit".tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("no".tr),
            ),
            TextButton(
              onPressed: () => shotDownApp(),
              child: Text("yes".tr),
            ),
          ],
        ),
      );
}
