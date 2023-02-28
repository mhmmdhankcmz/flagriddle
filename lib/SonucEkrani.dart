import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'generated/locale_keys.g.dart';

class SonucEkrani extends StatefulWidget{
  late int dogruSayisi;
  late int soruSayisi;

  SonucEkrani({required this.soruSayisi, required this.dogruSayisi});

  @override
  State<SonucEkrani> createState() => _SonucEkraniState();
}

class _SonucEkraniState extends State<SonucEkrani> {
  ScreenshotController screenshotController = ScreenshotController();

  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    print(
        "${widget.soruSayisi}--------------------------------------------------*0-*0-0-0-*0-*0");
    return Screenshot(
      controller: screenshotController,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title:
                Text("${LocaleKeys.score.tr()}  ${LocaleKeys.flagriddle.tr()}"),
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/buton/background.jpg"),
                    fit: BoxFit.cover)),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(35, 0, 0, 60),
                            child: Text(
                              "${widget.dogruSayisi}  ${LocaleKeys.right.tr()} ",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 35, 60),
                            child: Text(
                              " ${widget.soruSayisi - widget.dogruSayisi}  ${LocaleKeys.wrong.tr()}",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
                      child: Text(
                        "% ${widget.dogruSayisi * 100 ~/ widget.soruSayisi} ${LocaleKeys.successRate.tr()}",
                        style: TextStyle(fontSize: 35, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0))),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(LocaleKeys.playAgain.tr()))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.share, size: 30),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.lightGreen),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0))),
                            ),
                            onPressed: () async {
                              final image = await screenshotController.capture();
                              if (image == null) return;
                              await saveImage(image);
                              saveAndShare(image);
                            },
                            label: Text(
                              "${LocaleKeys.share.tr()}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          )),
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

  Future saveAndShare(Uint8List bytes) async {
    final appUrl =
        'https://play.google.com/store/apps/details?id=com.mobdevs.flagriddle';
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flaggame.png');
    image.writeAsBytesSync(bytes);
    await Share.shareXFiles([XFile(image.path)],
        text: "Haydi Sende Dene Skorunu Paylaş :)\n\n $appUrl");
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
