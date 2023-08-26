import 'dart:io';
import 'dart:typed_data';
import 'package:FlagRiddle/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class SonucEkrani extends StatefulWidget{
  late int dogruSayisi;
  late int soruSayisi;


  SonucEkrani({required this.soruSayisi, required this.dogruSayisi});

  @override
  State<SonucEkrani> createState() => _SonucEkraniState();
}

class _SonucEkraniState extends State<SonucEkrani> {
  ScreenshotController screenshotController = ScreenshotController();





  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print(
        "${widget.soruSayisi}--------------------------------------------------*0-*0-0-0-*0-*0");
    return Screenshot(
      controller: screenshotController,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppBarTheme.of(context).backgroundColor,
            title:
                Text("riddleScore".tr),
          ),
          body: Container(width: size.width,height: size.height,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Padding(
                            padding: const EdgeInsets.fromLTRB(35, 0, 0, 60),
                            child:  RichText(text: TextSpan(text: "${widget.dogruSayisi} ",style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.green),children: [TextSpan(text: "right".tr)])),
                            // child: Text(
                            //   "${widget.dogruSayisi} right".tr,
                            //   style: TextStyle(
                            //       color: Colors.green,
                            //       fontSize: 25,
                            //       fontWeight: FontWeight.bold),
                            //   textAlign: TextAlign.left,
                            // ),
                          ),
                         // Padding(
                         //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                         //   child: Align(alignment: AlignmentDirectional.bottomEnd,child: Container(width: 50,height:50,child: Icon(Icons.compare_arrows_sharp))),
                         // ),/* burda kaldım*/
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 35, 60),
                            child:  RichText(text: TextSpan(text: "${widget.soruSayisi-widget.dogruSayisi} ",style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.red),children: [TextSpan(text: "wrong".tr)])),
                            // child: Text(
                            //   " ${widget.soruSayisi-widget.dogruSayisi} wrong".tr,
                            //
                            //   style: TextStyle(
                            //       color: Colors.red,
                            //       fontSize: 25,
                            //       fontWeight: FontWeight.bold),
                            // ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.fromLTRB(30, 0, 30, 60),
                      child: RichText(text: TextSpan(text: "% ${widget.dogruSayisi * 100 ~/ widget.soruSayisi} ",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color: Colors.blueGrey.shade800),children:[TextSpan(text: "successRate".tr,)])),

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
                                Get.offAll(Home());
                                // Navigator.pop(context);
                              },
                              child: Text("playAgain".tr)
                          )),
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
                              "share".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
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
