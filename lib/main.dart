// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mypay/ThemeScreen/theme_changer.dart';
import 'package:mypay/screen/splash.dart';

final titleColor = Color(0xff444444);
final startColor = Color(0xFFaa7ce4);
final endColor = Color(0xFFe46792);
final colorOfApp = Color.fromARGB(255, 39, 188, 208);
// final colorOfApp = Color.fromARGB(255, 23, 117, 194);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'myDailyBook',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: myDealyBookSplash(),
    );
  }
}
