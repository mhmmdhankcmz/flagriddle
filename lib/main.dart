import 'package:FlagRiddle/translate/languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'home.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp( MyApp());
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      translations: Languages(),
      title: 'Flag Game',
      debugShowCheckedModeBanner: false,
      locale: Get.deviceLocale,
      fallbackLocale: Locale('tr','TR'),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(

            color: Colors.lightBlue.shade300)
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    Future.delayed(Duration(seconds: 2), () {
     Get.to(()=>Home());
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
           Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/buton/background.jpg"),
                    fit: BoxFit.cover),
              )),
        Center(
          child: Container(width: width/2,height: width,
              foregroundDecoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/buton/logo.png"))),

        ),),
      ],

      ),
    );
  }
}
