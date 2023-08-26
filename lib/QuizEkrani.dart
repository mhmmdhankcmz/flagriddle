import 'dart:collection';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' ;
import 'package:lite_rolling_switch/lite_rolling_switch.dart';


import 'Bayraklar.dart';
import 'Bayraklardao.dart';
import 'SonucEkrani.dart';


// ignore: must_be_immutable
class QuizEkrani extends StatefulWidget {

 late int gelenSoru ;
 late bool volume;

   QuizEkrani({required this.gelenSoru,required this.volume});

  @override
  State<QuizEkrani> createState() => _QuizEkraniState();
}

class _QuizEkraniState extends State<QuizEkrani> {
  var sorular = <Bayraklar>[];
  var yanlisSecenekler = <Bayraklar>[];
  late Bayraklar dogruSoru;
  var tumSecenekler = HashSet<Bayraklar>();
  bool dogrumu = false;
  bool tiklandimiSik = false;


  Color dogru = Colors.green;
  Color yanlis = Colors.red;
  Color renk = Colors.blue;


  int soruSayac = 0;
  int dogruSayac = 0;
  int yanlisSayac = 0;

  String bayrakResimAdi= "placeholder.png";
  String butonAyazi= "";
  String butonByazi= "";
  String butonCyazi= "";
  String butonDyazi= "";


  @override
  void initState() {
    super.initState();
    sorulariAl();
  }

  Future<void>sorulariAl() async{
    sorular = (await Bayraklardao().rasgele5Getir())!;
    soruYukle();
  }

  Future<void>soruYukle() async{
    dogruSoru = sorular[soruSayac];
    bayrakResimAdi = dogruSoru.bayrak_resim;

    yanlisSecenekler = (await Bayraklardao().rasgele3YanlisGetir(dogruSoru.bayrak_id))!;
    tumSecenekler.clear();
    tumSecenekler.add(dogruSoru);
    tumSecenekler.add(yanlisSecenekler[0]);
    tumSecenekler.add(yanlisSecenekler[1]);
    tumSecenekler.add(yanlisSecenekler[2]);

    butonAyazi = tumSecenekler.elementAt(0).bayrak_ad;
    butonByazi = tumSecenekler.elementAt(1).bayrak_ad;
    butonCyazi = tumSecenekler.elementAt(2).bayrak_ad;
    butonDyazi = tumSecenekler.elementAt(3).bayrak_ad;

    setState(() {

    });

  }



  Future<void> soruSayacKontrol() async{
    soruSayac = soruSayac +1;
    if(soruSayac != widget.gelenSoru){
      soruYukle();
    }else{
      print("Sonuç ekranına geçiş yapıldı ---------------*-*-*-*--*");
      Get.offAll(SonucEkrani(soruSayisi:widget.gelenSoru , dogruSayisi: dogruSayac),transition: Transition.cupertino);
       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SonucEkrani(dogruSayisi: dogruSayac,soruSayisi: widget.gelenSoru)));
    }
  }

  final player = AudioPlayer();

  dogruKontrol(String buttonYazi) async{
    if(dogruSoru.bayrak_ad == buttonYazi) {
    dogruSayac = dogruSayac + 1;
   await player.play(AssetSource("audio/success.mp3"));
   setState(() {
       renk = dogru;
       dogrumu = true;
    });
    }else{
      player.play(AssetSource("audio/dit.mp3"));
      yanlisSayac = yanlisSayac +1;
      setState(() {
      renk = yanlis;
      dogrumu = false;

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height ;
    if(widget.volume == false){
      player.setVolume(0.0);
      print("ses kapalı");
    }else{
      player.setVolume(1.0);
      print("ses açık");
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
        body: Container(height: screenHeight-10,width: screenWidth,
          decoration: buildBoxDecoration(),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildPadding(),
                    soruSayac != widget.gelenSoru ? RichText(text: TextSpan(text: "${soruSayac+1}. ",style: TextStyle(fontSize: 30,color: Colors.black),children: [TextSpan(text: "question".tr)]),):
                    // soruSayac != widget.gelenSoru ? Text("${soruSayac+1}. question".tr,style: TextStyle(fontSize: 30),):
                    Text("  ",style: TextStyle(fontSize: 30),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30,0,0,0),
                            child: RichText(text: TextSpan(text: "${widget.gelenSoru} ",style: TextStyle(fontSize: screenWidth/30,fontWeight: FontWeight.bold,color: Colors.green.shade300),children: [TextSpan(text: "questionbeasked".tr,)])),

                          ),
                          dogrumu ? Visibility(visible : tiklandimiSik,child: Icon(Icons.check_rounded,color: dogru,size: screenWidth/5.toDouble(),)) : Visibility(visible : tiklandimiSik,child:Icon(Icons.cancel_outlined,color: yanlis,size:screenWidth/5.toDouble() ) ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5,0,30,0),
                            child: RichText(text: TextSpan(text: "remaining".tr,style: TextStyle(fontWeight: FontWeight.bold,fontSize: screenWidth/30,color: Colors.black),children: [TextSpan(text: " ${widget.gelenSoru - soruSayac}",style: TextStyle(color: Colors.red,fontSize: screenWidth/30))])),
                          ),
                        ],
                      ),
                    ),

                    Card(elevation:25,child: Image.asset("resimler/$bayrakResimAdi")),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(height: 50,width:250, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor:Colors.lightBlue,),
                          onPressed: () async{
                           await Future.delayed(Duration(milliseconds: 200));
                            setState(() {
                              tiklandimiSik= true;
                              print("A şıkkı $tiklandimiSik");
                            });
                            dogruKontrol(butonAyazi);
                            soruSayacKontrol();
                      }, child: Text(butonAyazi.tr)
                      )
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(height: 50,width:250, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue,
                      ),
                          onPressed: () async{
                            await Future.delayed(Duration(milliseconds: 200));
                            setState(() {
                              tiklandimiSik= true;
                              print("B şıkkı $tiklandimiSik");
                            });
                             dogruKontrol(butonByazi);
                             soruSayacKontrol();

                      }, child: Text(butonByazi.tr))),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(height: 50,width:250, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue,),
                          onPressed: ()async{
                            await Future.delayed(Duration(milliseconds: 200));
                            setState(() {
                              tiklandimiSik= true;
                              print("C şıkkı $tiklandimiSik");
                            });
                            dogruKontrol(butonCyazi);
                            soruSayacKontrol();
                      }, child: Text(butonCyazi.tr))),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(height: 50,width:250, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue,),
                          onPressed: ()async{
                            await Future.delayed(Duration(milliseconds: 200));
                            setState(() {
                              tiklandimiSik= true;
                              print("D şıkkı $tiklandimiSik");
                            });
                        dogruKontrol(butonDyazi);
                        soruSayacKontrol();
                      }, child: Text(butonDyazi.tr))),
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
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:  [
                    RichText(text: TextSpan(text: "right".tr,style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.green),children: [TextSpan(text: " $dogruSayac")])),
                    RichText(text: TextSpan(text: "wrong".tr,style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.red.shade600),children: [TextSpan(text: " $yanlisSayac")])),
                  ],
                ),
              );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
          image: DecorationImage(
            filterQuality: FilterQuality.high,
              image: AssetImage("assets/buton/background.jpg"),
              fit: BoxFit.cover));
  }

  LiteRollingSwitch buildLiteRollingSwitch() {
    return LiteRollingSwitch(
          width: 105.0,
          value: widget.volume,
          textOn: 'on'.tr,textOnColor: Colors.white,
          textOff: 'off'.tr,textOffColor: Colors.black54,
          colorOn: Colors.blue,
          colorOff: Colors.blue,
          iconOn: Icons.volume_up,
          iconOff: Icons.volume_off,
          animationDuration: Duration(milliseconds: 800),
          textSize: 15,
          onChanged: (value) {
            setState(() {
              widget.volume = value;
              if(widget.volume == false){
                player.setVolume(0.0);
                print("ses kapalı");
              }else{
                player.setVolume(1.0);
                print("ses açık");
              }

              print("**-*-*-*-*-*-*-*- ${widget.volume}");
            });
          }, onTap: (){}, onDoubleTap: (){}, onSwipe:(){},
        );
  }
}
