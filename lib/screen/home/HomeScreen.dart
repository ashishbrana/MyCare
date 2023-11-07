import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/Login/Login.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';

import '../../utils/ConstantStrings.dart';
import '../../utils/Preferences.dart';
import 'Tabs/ConfirmedTabScreen.dart';

DateTime fromDate = DateTime.now();
DateTime toDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day + 15);
DateTime tempFromDate = DateTime.now();
DateTime tempToDate = DateTime.now();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bottomCurrentIndex = 0;
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  final TextEditingController _controllerFromDate = TextEditingController();
  final TextEditingController _controllerToDate = TextEditingController();

  List<Widget> body = [
    ConfirmedTabScreen(),
    ConfirmedTabScreen(),
    ConfirmedTabScreen(),
    ConfirmedTabScreen(),
    ConfirmedTabScreen(),
  ];

  Logout() {
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
      key: _keyScaffold,
      appBar: AppBar(
        title: ThemedTextField(
          borderColor: colorPrimary,
          preFix: const FaIcon(
            FontAwesomeIcons.search,
            color: Color(0XFFBBBECB),
          ),
          hintText: "Search...",
        ),
        actions: [
          SizedBox(
            height: 50,
            child: MaterialButton(
              color: colorGreen,
              child: ThemedText(
                text: "Note",
                fontSize: 16,
                color: colorWhite,
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 50,
            child: MaterialButton(
              color: colorGreen,
              child: ThemedText(
                text: "Search",
                fontSize: 16,
                color: colorWhite,
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              // if (_keyScaffold.currentState != null) {
              //
              // }
              _keyScaffold.currentState!.openEndDrawer();
            },

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 60,
                width: 30,
                decoration: const BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(30),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: FaIcon(
                    FontAwesomeIcons.list,
                    color: colorWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      onEndDrawerChanged: (isOpened) {
        tempFromDate = fromDate;
        tempToDate = toDate;
        _controllerFromDate.text = DateFormat("dd-MM-yyyy").format(fromDate);
        _controllerToDate.text = DateFormat("dd-MM-yyyy").format(toDate);
        setState(() {});
      },
      endDrawer: SizedBox(
        width: double.infinity,
        child: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: boxBorderRadius,
                  ),
                  padding: const EdgeInsets.all(spaceHorizontal),
                  margin: const EdgeInsets.all(spaceHorizontal),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      ThemedText(text:'Kate Clark',color: colorBlack,fontSize: 20,fontWeight: FontWeight.bold,),
                      const SizedBox(height: 30),

                      ThemedTextField(
                        controller: _controllerFromDate,
                        borderColor: colorGreyBorderD3,
                        preFix: const FaIcon(
                          FontAwesomeIcons.calendar,
                          color: colorGreen,
                          size: 26,
                        ),
                        sufFix: InkWell(
                          onTap: () {
                            tempFromDate = DateTime(tempFromDate.year,
                                tempFromDate.month, tempFromDate.day + 15);
                            tempToDate = DateTime(tempFromDate.year,
                                tempFromDate.month, tempFromDate.day + 15);
                            _controllerFromDate.text =
                                DateFormat("dd-MM-yyyy").format(tempFromDate);
                            _controllerToDate.text =
                                DateFormat("dd-MM-yyyy").format(tempToDate);
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorLiteGreen,
                              borderRadius: boxBorderRadius,
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.plus,
                              color: colorGreyText,
                              size: 20,
                            ),
                          ),
                        ),
                        isReadOnly: true,
                        labelText: "From Date",
                        hintFontWeight: FontWeight.bold,
                        fontWeight: FontWeight.bold,
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: tempFromDate,
                            firstDate: DateTime(tempFromDate.year - 1),
                            lastDate: DateTime(tempFromDate.year + 1),
                          ).then((value) {
                            if (value != null) {
                              tempFromDate = value;
                              _controllerFromDate.text =
                                  DateFormat("dd-MM-yyyy").format(tempFromDate);
                              setState(() {});
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ThemedTextField(
                        controller: _controllerToDate,
                        borderColor: colorGreyBorderD3,
                        preFix: const FaIcon(
                          FontAwesomeIcons.calendar,
                          color: colorGreen,
                          size: 24,
                        ),
                        sufFix: InkWell(
                          onTap: () {
                            tempFromDate = DateTime(tempFromDate.year,
                                tempFromDate.month, tempFromDate.day - 15);
                            tempToDate = DateTime(tempFromDate.year,
                                tempFromDate.month, tempFromDate.day + 15);
                            _controllerFromDate.text =
                                DateFormat("dd-MM-yyyy").format(tempFromDate);
                            _controllerToDate.text =
                                DateFormat("dd-MM-yyyy").format(tempToDate);
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorLiteGreen,
                              borderRadius: boxBorderRadius,
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.minus,
                              color: colorGreyText,
                              size: 20,
                            ),
                          ),
                        ),
                        isReadOnly: true,
                        labelText: "To Date",
                        hintFontWeight: FontWeight.bold,
                        fontWeight: FontWeight.bold,
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: tempToDate,
                            firstDate: DateTime(tempToDate.year + 1),
                            lastDate: DateTime(tempToDate.year - 1),
                          ).then((value) {
                            if (value != null) {
                              tempToDate = value;
                              _controllerToDate.text =
                                  DateFormat("dd-MM-yyyy").format(tempToDate);
                              setState(() {});
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: ThemedButton(
                              title: "Apply",
                              onTap: () {
                                fromDate = tempFromDate;
                                toDate = tempToDate;
                                setState(() {});
                                if (_keyScaffold.currentState != null) {
                                  _keyScaffold.currentState!.closeEndDrawer();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ThemedButton(
                              title: "Cancel",
                              onTap: () {
                                tempFromDate = fromDate;
                                tempToDate = toDate;
                                setState(() {});
                                if (_keyScaffold.currentState != null) {
                                  _keyScaffold.currentState!.closeEndDrawer();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Material(
                        borderRadius: boxBorderRadius,
                        color: colorGreen,
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            Logout();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: boxBorderRadius,
                              border: Border.all(color: colorGreen, width: 2),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.arrowLeft,
                                  color: colorWhite,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Sign Out",
                                  style: TextStyle(
                                      color: colorWhite,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22,
                                      fontFamily: stringFontFamilyGibson),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      body: Column(
        children: [
          Expanded(child: body[bottomCurrentIndex]),
        ],
      ),
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
