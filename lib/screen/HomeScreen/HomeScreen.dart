import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import 'Tabs/ConfirmedTabScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bottomCurrentIndex = 0;

  List<Widget> body = [
    ConfirmedTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context,
          isComeWithBackButton: false, isBackButtonEnable: false),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Row(
          children: [
            Expanded(
              child: _buildBottomNavBarItem(
                  index: 0,
                  icons: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  label: "CONFIRMED"),
            ),
            Expanded(
              child: _buildBottomNavBarItem(
                  index: 1,
                  icons: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  label: "unCONFIRMED"),
            ),
            Expanded(
              child: _buildBottomNavBarItem(
                index: 2,
                icons: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                ),
                label: "timesheet",
              ),
            ),
            Expanded(
              child: _buildBottomNavBarItem(
                  index: 3,
                  icons: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  label: "available"),
            ),
            Expanded(
              child: _buildBottomNavBarItem(
                  index: 4,
                  icons: const Icon(
                    CupertinoIcons.person_alt_circle,
                    color: Colors.white,
                  ),
                  label: "profile"),
            ),
          ],
        ),
      ),
      body: body[bottomCurrentIndex],
    );
  }

  _buildBottomNavBarItem(
      {required int index, required String label, required Widget icons}) {
    return InkWell(
      onTap: () {
        setState(() {
          bottomCurrentIndex = index;
        });
      },
      child: Container(
        color: bottomCurrentIndex == index ? Colors.blue.shade600 : Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                icons,
                Positioned(
                  top: -3,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      "10",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                )
              ],
            ),
            ThemedText(
              text: label.toUpperCase(),
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w300,
              maxLine: 1,
            )
          ],
        ),
      ),
    );
  }
}
