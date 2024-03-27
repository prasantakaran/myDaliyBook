import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mypay/ThemeScreen/Theme_controller.dart';
import 'package:mypay/screen/Login.dart';
import 'package:mypay/screen/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class myDealyBookSplash extends StatefulWidget {
  const myDealyBookSplash({super.key});

  @override
  State<myDealyBookSplash> createState() => myDealyBookSplashState();
}

class myDealyBookSplashState extends State<myDealyBookSplash> {
  ThemeController themeController = Get.put(ThemeController());
  @override
  void initState() {
    setState(() {
      isanimated = true;
    });
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      wherToGo();

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top]);
    });
    getThemeValue();
  }

  static const String keySP = 'LOGIN';

  late SharedPreferences sp;
  Future<void> wherToGo() async {
    sp = await SharedPreferences.getInstance();
    var isLoggedIn = sp.getBool(keySP);
    if (isLoggedIn != null) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginUser(),
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginUser(),
        ),
      );
    }
  }

  Future<void> getThemeValue() async {
    var sp = await SharedPreferences.getInstance();
    bool themeVal = sp.getBool('theme') ?? false;

    themeController.changeTheme(themeVal);
  }

  bool isanimated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            Column(children: [
              Image.asset(
                "assets/images/mybook.png",
                scale: 1,
              ),
            ]),
            AnimatedPositioned(
              duration: Duration(seconds: 5),
              height: 50,
              width: MediaQuery.of(context).size.width * .8,
              left: isanimated
                  ? MediaQuery.of(context).size.height * .05
                  : -MediaQuery.of(context).size.height * 1,
              bottom: MediaQuery.of(context).size.height * .40,
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'my \n ',
                      style: TextStyle(
                          fontFamily: 'KaushanScript',
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 5),
              height: 50,
              width: MediaQuery.of(context).size.width * .5,
              right: isanimated
                  ? MediaQuery.of(context).size.height * .09
                  : -MediaQuery.of(context).size.height * .1,
              bottom: MediaQuery.of(context).size.height * .36,
              child: const Text(
                ' DailyBook',
                style: TextStyle(
                  fontFamily: 'KaushanScript',
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: const Text(
                'Develop By Prasanta',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showBottomDailog() {
    return showBottomDailog();
  }
}
