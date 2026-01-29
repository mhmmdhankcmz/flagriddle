import 'dart:collection';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import 'Bayraklar.dart';
import 'Bayraklardao.dart';
import 'SonucEkrani.dart';

class QuizEkrani extends StatefulWidget {
  final int gelenSoru;
  final bool volume;

  const QuizEkrani({
    Key? key,
    required this.gelenSoru,
    required this.volume,
  }) : super(key: key);

  @override
  State<QuizEkrani> createState() => _QuizEkraniState();
}

class _QuizEkraniState extends State<QuizEkrani>
    with SingleTickerProviderStateMixin {
  var sorular = <Bayraklar>[];
  var yanlisSecenekler = <Bayraklar>[];
  late Bayraklar dogruSoru;
  var tumSecenekler = HashSet<Bayraklar>();
  bool dogrumu = false;
  bool tiklandimiSik = false;
  bool _isLoading = true;
  bool _volume = true;

  final Color dogru = Colors.green;
  final Color yanlis = Colors.red;
  Color renk = Colors.blue;

  int soruSayac = 0;
  int dogruSayac = 0;
  int yanlisSayac = 0;

  String bayrakResimAdi = "placeholder.png";
  List<String> butonYazilari = ["", "", "", ""];

  final player = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _volume = widget.volume;
    _setupAnimations();
    sorulariAl();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    player.dispose();
    super.dispose();
  }

  Future<void> sorulariAl() async {
    sorular = await Bayraklardao().rasgele5Getir();
    await soruYukle();
    setState(() {
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> soruYukle() async {
    dogruSoru = sorular[soruSayac];
    bayrakResimAdi = dogruSoru.bayrakResim;

    yanlisSecenekler = await Bayraklardao().rasgele3YanlisGetir(dogruSoru.bayrakId);
    tumSecenekler.clear();
    tumSecenekler.add(dogruSoru);
    tumSecenekler.add(yanlisSecenekler[0]);
    tumSecenekler.add(yanlisSecenekler[1]);
    tumSecenekler.add(yanlisSecenekler[2]);

    butonYazilari = [
      tumSecenekler.elementAt(0).bayrakAd,
      tumSecenekler.elementAt(1).bayrakAd,
      tumSecenekler.elementAt(2).bayrakAd,
      tumSecenekler.elementAt(3).bayrakAd,
    ];

    setState(() {});
  }

  Future<void> soruSayacKontrol() async {
    soruSayac = soruSayac + 1;
    if (soruSayac != widget.gelenSoru) {
      _animationController.reset();
      await soruYukle();
      _animationController.forward();
    } else {
      Get.offAll(
        () => SonucEkrani(
          soruSayisi: widget.gelenSoru,
          dogruSayisi: dogruSayac,
        ),
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  Future<void> dogruKontrol(String buttonYazi) async {
    if (dogruSoru.bayrakAd == buttonYazi) {
      dogruSayac = dogruSayac + 1;
      await player.play(AssetSource("audio/success.mp3"));
      setState(() {
        renk = dogru;
        dogrumu = true;
      });
    } else {
      player.play(AssetSource("audio/dit.mp3"));
      yanlisSayac = yanlisSayac + 1;
      setState(() {
        renk = yanlis;
        dogrumu = false;
      });
    }
  }

  Future<void> _onAnswerSelected(String answer) async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      tiklandimiSik = true;
    });
    await dogruKontrol(answer);
    await soruSayacKontrol();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (_volume == false) {
      player.setVolume(0.0);
    } else {
      player.setVolume(1.0);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarTheme.of(context).backgroundColor,
          title: Text("flagriddle".tr),
          actions: [
            buildLiteRollingSwitch(),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                height: screenHeight - 10,
                width: screenWidth,
                decoration: buildBoxDecoration(),
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildScoreRow(),
                            _buildQuestionCounter(),
                            _buildProgressInfo(screenWidth),
                            _buildFlagCard(),
                            const SizedBox(height: 20),
                            ...List.generate(4, (index) {
                              return _buildAnswerButton(butonYazilari[index]);
                            }),
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

  Widget _buildQuestionCounter() {
    if (soruSayac == widget.gelenSoru) {
      return const Text("  ", style: TextStyle(fontSize: 30));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "${soruSayac + 1}. ${'question'.tr}",
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressInfo(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: RichText(
              text: TextSpan(
                text: "${widget.gelenSoru} ",
                style: TextStyle(
                  fontSize: screenWidth / 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade300,
                ),
                children: [
                  TextSpan(text: "questionbeasked".tr),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: dogrumu
                ? Visibility(
                    visible: tiklandimiSik,
                    child: Icon(
                      Icons.check_rounded,
                      color: dogru,
                      size: screenWidth / 5.toDouble(),
                      key: const ValueKey('check'),
                    ),
                  )
                : Visibility(
                    visible: tiklandimiSik,
                    child: Icon(
                      Icons.cancel_outlined,
                      color: yanlis,
                      size: screenWidth / 5.toDouble(),
                      key: const ValueKey('cancel'),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 30, 0),
            child: RichText(
              text: TextSpan(
                text: "remaining".tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth / 30,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: " ${widget.gelenSoru - soruSayac}",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: screenWidth / 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagCard() {
    return Card(
      elevation: 25,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          "resimler/$bayrakResimAdi",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String answer) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: 50,
        width: 250,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 5,
          ),
          onPressed: () => _onAnswerSelected(answer),
          child: Text(
            answer.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget buildScoreRow() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreChip('right'.tr, dogruSayac, Colors.green),
          _buildScoreChip('wrong'.tr, yanlisSayac, Colors.red.shade600),
        ],
      ),
    );
  }

  Widget _buildScoreChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        filterQuality: FilterQuality.high,
        image: AssetImage("assets/buton/background.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }

  LiteRollingSwitch buildLiteRollingSwitch() {
    return LiteRollingSwitch(
      width: 105.0,
      value: _volume,
      textOn: 'on'.tr,
      textOnColor: Colors.white,
      textOff: 'off'.tr,
      textOffColor: Colors.black54,
      colorOn: Colors.blue,
      colorOff: Colors.blue,
      iconOn: Icons.volume_up,
      iconOff: Icons.volume_off,
      animationDuration: const Duration(milliseconds: 800),
      textSize: 15,
      onChanged: (value) {
        setState(() {
          _volume = value;
          if (_volume == false) {
            player.setVolume(0.0);
          } else {
            player.setVolume(1.0);
          }
        });
      },
      onTap: () {},
      onDoubleTap: () {},
      onSwipe: () {},
    );
  }
}
