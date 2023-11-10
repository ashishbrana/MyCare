import 'package:flutter/material.dart';
import 'package:rcare_2/screen/SplashScreen.dart';
import 'package:rcare_2/utils/ColorConstants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorLiteGreen),
        datePickerTheme: const DatePickerThemeData(
          headerBackgroundColor: colorLiteGreen,
        ),
        useMaterial3: true,
        fontFamily: "Roboto",
      ),
      home: const SplashScreen(),
    );
  }
}
