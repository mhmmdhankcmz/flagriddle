import 'dart:io';
import 'dart:typed_data';
import 'package:FlagRiddle/home.dart';
import 'package:FlagRiddle/services/score_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class SonucEkrani extends StatefulWidget {
  final int dogruSayisi;
  final int soruSayisi;

  const SonucEkrani({
    Key? key,
    required this.soruSayisi,
    required this.dogruSayisi,
  }) : super(key: key);

  @override
  State<SonucEkrani> createState() => _SonucEkraniState();
}

class _SonucEkraniState extends State<SonucEkrani>
    with SingleTickerProviderStateMixin {
  ScreenshotController screenshotController = ScreenshotController();
  bool _isNewHighScore = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _saveAndCheckScore();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  Future<void> _saveAndCheckScore() async {
    final isNewHighScore = await ScoreService.saveScore(
      widget.dogruSayisi,
      widget.soruSayisi,
    );
    setState(() {
      _isNewHighScore = isNewHighScore;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int get _percentage => (widget.dogruSayisi * 100) ~/ widget.soruSayisi;

  Color get _resultColor {
    if (_percentage >= 80) return Colors.green;
    if (_percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String get _resultEmoji {
    if (_percentage >= 80) return '🎉';
    if (_percentage >= 50) return '👍';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Screenshot(
      controller: screenshotController,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppBarTheme.of(context).backgroundColor,
            title: Text("riddleScore".tr),
          ),
          body: Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/buton/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isNewHighScore) _buildNewHighScoreBadge(),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildScoreCard(size),
                    ),
                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildActionButtons(),
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

  Widget _buildNewHighScoreBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  'newHighScore'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.white, size: 28),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(Size size) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              _resultEmoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 20),
            _buildScoreRow(
              'right'.tr,
              widget.dogruSayisi.toString(),
              Colors.green,
              Icons.check_circle,
            ),
            const SizedBox(height: 15),
            _buildScoreRow(
              'wrong'.tr,
              (widget.soruSayisi - widget.dogruSayisi).toString(),
              Colors.red,
              Icons.cancel,
            ),
            const Divider(height: 40, thickness: 2),
            _buildPercentageDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 10),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageDisplay() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: _percentage),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Column(
          children: [
            Text(
              'successRate'.tr,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: value / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(_resultColor),
                  ),
                ),
                Text(
                  '%$value',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _resultColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: 250,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.replay, size: 24),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 5,
            ),
            onPressed: () {
              Get.offAll(
                () => const Home(),
                transition: Transition.leftToRight,
                duration: const Duration(milliseconds: 300),
              );
            },
            label: Text(
              "playAgain".tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share, size: 24),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 5,
            ),
            onPressed: () async {
              final image = await screenshotController.capture();
              if (image == null) return;
              await saveImage(image);
              saveAndShare(image);
            },
            label: Text(
              "share".tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future saveAndShare(Uint8List bytes) async {
    final appUrl =
        'https://play.google.com/store/apps/details?id=com.mobdevs.flagriddle';
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flaggame.png');
    image.writeAsBytesSync(bytes);
    await Share.shareXFiles(
      [XFile(image.path)],
      text: "Haydi Sende Dene Skorunu Paylaş :)\n\n$appUrl",
    );
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '_')
        .replaceAll(':', '_');
    final name = "screenshot_$time";
    final result = await ImageGallerySaver.saveImage(bytes, name: name);

    return result['filePath'];
  }
}
