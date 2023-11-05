import 'package:flutter/material.dart';
import 'package:rcare_2/utils/Preferences.dart';

import 'HomeScreen/HomeScreen.dart';
import 'Login/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // sendToHome();

    getData();
  }

  getData() async {
    if ((await Preferences().getPrefString(Preferences.prefAuthCode)).isNotEmpty) {
      sendToHome();
    } else {
      sendToLogin();
    }
  }

  sendToHome() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      },
    );
  }

  sendToLogin() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/login_back.png"))),
        width: MediaQuery.of(context).size.width,
        child: Container(),
      ),
    );
  }
}
