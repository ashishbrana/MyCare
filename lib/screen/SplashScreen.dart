import 'package:flutter/material.dart';
import 'package:rcare_2/screen/ClinetHome/ClientHomeScreen.dart';
import 'package:rcare_2/utils/Preferences.dart';


import '../appconstant/ApiUrls.dart';
import 'Login/Login.dart';
import 'home/HomeScreen.dart';


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
    if ((await Preferences().getPrefString(Preferences.prefAuthCode))
        .isNotEmpty) {
      int accountType =
          await Preferences().getPrefInt(Preferences.prefAccountType);
      String comapanyCode =
          await Preferences().getPrefString(Preferences.prefComepanyCode);
      if(comapanyCode == "nhc"){
        String cName = "nhc-northside";
        baseUrlWithHttp ="https://$cName-web.mycaresoftware.com/";
        baseUrl = '$cName-web.mycaresoftware.com';
        nestedUrl = 'MobileAPI/v1.asmx/';
        masterURL = "https://$cName-web.mycaresoftware.com/MobileAPI/v1.asmx/";
      }
      else{
        baseUrlWithHttp ="https://$comapanyCode-web.mycaresoftware.com/";
        baseUrl = '$comapanyCode-web.mycaresoftware.com';
        nestedUrl = 'MobileAPI/v1.asmx/';
        masterURL = "https://$comapanyCode-web.mycaresoftware.com/MobileAPI/v1.asmx/";
      }

      print(baseUrlWithHttp);
      print(baseUrl);
      print(masterURL);
      print(accountType);
      if (accountType == 2) {
        sendToHome();
      } else {
        sendToClientHome();
      }
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

  sendToClientHome() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClientHomeScreen(),
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
