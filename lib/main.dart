import 'package:flutter/material.dart';
import 'package:rcare_2/screen/SplashScreen.dart';
import 'package:rcare_2/screen/home/TimeSheetDetail.dart';
import 'package:rcare_2/utils/ColorConstants.dart';

import 'calendar/calendar_controller_provider.dart';
import 'calendar/calendar_event_data.dart';
import 'calendar/event_controller.dart';
DateTime get _now => DateTime.now();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build1(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
        controller: EventController(),
    child: MaterialApp(
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
    ),
    );
  }
}

List<CalendarEventData> _events = [
  CalendarEventData(
    date: _now,
    title: "Project meeting",
    description: "Today is project meeting.",
    startTime: DateTime(_now.year, _now.month, _now.day, 18, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 22),
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 1)),
    startTime: DateTime(_now.year, _now.month, _now.day, 18),
    endTime: DateTime(_now.year, _now.month, _now.day, 19),
    title: "Wedding anniversary",
    description: "Attend uncle's wedding anniversary.",
  ),
  CalendarEventData(
    date: _now,
    startTime: DateTime(_now.year, _now.month, _now.day, 14),
    endTime: DateTime(_now.year, _now.month, _now.day, 17),
    title: "Football Tournament",
    description: "Go to football tournament.",
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 3)),
    startTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 10),
    endTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 14),
    title: "Sprint Meeting.",
    description: "Last day of project submission for last year.",
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        14),
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        16),
    title: "Team Meeting",
    description: "Team Meeting",
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        10),
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        12),
    title: "Chemistry Viva",
    description: "Today is Joe's birthday.",
  ),
];

