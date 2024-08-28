import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rcare_2/screen/ClientHome/ClientHomeScreen.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../appconstant/ApiUrls.dart';
import 'Login/Login.dart';
import 'home/HomeScreen.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );


  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    loadDeviceInfo();
    getData();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      print(_packageInfo.version);
      _packageInfo = info;
    });
  }

  loadDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceType = "android";
      appVersion = _packageInfo.version;
    } else if (Platform.isIOS) {
      deviceType = "ios";
      appVersion = _packageInfo.version;
    }
  }

  getData() async {
    if ((await Preferences().getPrefString(Preferences.prefAuthCode))
        .isNotEmpty) {
      bool is2FA = await Preferences().getPrefBool(Preferences.prefIs2FA);
      bool authenticated = await Preferences().getPrefBool(Preferences.prefAuthneticated);
      bool bioAuthenticated = await Preferences().getPrefBool(Preferences.prefBioAuthneticated);

      if(is2FA == true && (authenticated == false || bioAuthenticated == false)){
        sendToLogin();
      }
      else{
        _handleTransition();
      }

      /*
      if (accountType == 2) {
        sendToHome();
      } else {
        sendToClientHome();
      }*/
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
              builder: (context) => const HomeScreen(),
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
              builder: (context) => const ClientHomeScreen(),
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
            color: splashBlue,
            image: DecorationImage(
                image: AssetImage("assets/images/login_back.png"))),
        width: MediaQuery.of(context).size.width,
        child: Container(),
      ),
    );
  }

  Future<void> _handleTransition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? startTimeString = prefs.getString('sessionStartTime');
    DateTime? sessionStartTime;
    if (startTimeString != null) {
      sessionStartTime = DateTime.parse(startTimeString);
    }
    final now = DateTime.now();
    final difference = now.difference(sessionStartTime!);
    if (difference.inMinutes >= 1440){
      print("Time out");
      sendToLogin();
    }
    else{
      int accountType =
      await Preferences().getPrefInt(Preferences.prefAccountType);
      String comapanyCode =
      await Preferences().getPrefString(Preferences.prefCompanyCode);
      setUpAllUrls(comapanyCode == "nhc" ? "nhc-northside" : comapanyCode);

      bool is2FA = prefs.getBool(Preferences.prefIs2FA) ?? false;
      bool authenticated = prefs.getBool(Preferences.prefAuthneticated) ?? false;


      if (accountType == 2) {
        sendToHome();
      } else {
        sendToClientHome();
      }
    }
  }
}
