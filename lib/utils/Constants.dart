import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ColorConstants.dart';
import 'app_colors.dart';

bool trustSelfSigned = true;

HttpClient getHttpClient() {
  HttpClient httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);

  return httpClient;
}

List<BoxShadow> boxShadow = [
  BoxShadow(
    color: Colors.grey.shade400,
    blurRadius: 3,
    spreadRadius: 0,
    offset: const Offset(0, 1),
  ),
];

const double spaceVertical = 15;
const double spaceHorizontal = 10;
const double radius = 3;

const double textFiledHeight = 40;
const double spaceBetween = spaceVertical * .4;
const double space = spaceVertical * .6;

BorderRadius boxBorderRadius = BorderRadius.circular(radius);
double elevation = 2;

const double dividerWidth = 2;

class Constants {
  static final String imagePath = 'assets/images/';
}

class AppConstants {
  AppConstants._();

  static OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(7),
    borderSide: BorderSide(
      width: 2,
      color: AppColors.lightNavyBlue,
    ),
  );

  static InputDecoration get inputDecoration => InputDecoration(
    border: inputBorder,
    disabledBorder: inputBorder,
    errorBorder: inputBorder.copyWith(
      borderSide: BorderSide(
        width: 2,
        color: AppColors.red,
      ),
    ),
    enabledBorder: inputBorder,
    focusedBorder: inputBorder,
    focusedErrorBorder: inputBorder,
    hintText: "Event Title",
    hintStyle: TextStyle(
      color: AppColors.black,
      fontSize: 17,
    ),
    labelStyle: TextStyle(
      color: AppColors.black,
      fontSize: 17,
    ),
    helperStyle: TextStyle(
      color: AppColors.black,
      fontSize: 17,
    ),
    errorStyle: TextStyle(
      color: AppColors.red,
      fontSize: 12,
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 20,
    ),
  );
}

class BreakPoints {
  static const double web = 800;
}
