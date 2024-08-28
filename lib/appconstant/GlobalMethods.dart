import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String currentLanguage = "en";
String fcmRegistrationToken = "";
bool isNetworkConnected = false;

setCurrentLanguage(String value) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.setString("currentLanguage", value);
}

Future<String> getCurrentLanguage() async {
  var prefs = await SharedPreferences.getInstance();
  currentLanguage = (prefs.getString("currentLanguage") ?? "en");
  return currentLanguage;
}

setStringValueForKey(String key, String value) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String> getStringValueForKey(String key) async {
  var prefs = await SharedPreferences.getInstance();
  return (prefs.getString(key) ?? "");
}

bool validatePasswordStructureContainAllType(String value) {
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}

bool isValidateEmail(String value) {
  print("Email : $value");
  if (value.isEmpty) {
    return false; //'Enter your Email Address';
  }
//r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);

  return regex.hasMatch(value); //'Enter Valid Email Address';
}

String? validateEmail(String value) {
  if (value.isEmpty) {
    return 'Enter your Email Address';
  }
  if (!isValidateEmail(value)) {
    return 'Enter Valid Email Address';
  } else {
    return null;
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

calculateAge(DateTime birthDate) {
  DateTime currentDate = DateTime.now();
  int age = currentDate.year - birthDate.year;
  int month1 = currentDate.month;
  int month2 = birthDate.month;
  if (month2 > month1) {
    age--;
  } else if (month1 == month2) {
    int day1 = currentDate.day;
    int day2 = birthDate.day;
    if (day2 > day1) {
      age--;
    }
  }
  return age;
}
