import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/network/ApiUrls.dart';
import 'package:rcare_2/screen/Login/Login.dart';
import 'package:rcare_2/screen/home/CareWorkerList.dart';
import 'package:rcare_2/screen/home/ClientDocument.dart';
import 'package:rcare_2/screen/home/ClientInfo.dart';
import 'package:rcare_2/screen/home/DNSList.dart';
import 'package:rcare_2/screen/home/ProgressNoteListByNoteId.dart';
import 'package:rcare_2/screen/home/notes/NotesDetails.dart';
import 'package:rcare_2/screen/home/notes/ProgressNotes.dart';
import 'package:rcare_2/screen/home/tabs/ProfileTabScreen.dart';
import 'package:rcare_2/screen/home/tabs/UnConfirmedTabScreen.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Network/API.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/GlobalMethods.dart';
import '../../utils/Preferences.dart';
import '../../utils/methods.dart';
import 'Tabs/ConfirmedTabScreen.dart';
import 'TimeSheetDetail.dart';
import 'models/ConfirmedResponseModel.dart';

DateTime fromDate = DateTime.now();
DateTime toDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day + 15);
DateTime tempFromDate = DateTime.now();
DateTime tempToDate = DateTime.now();
final GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bottomCurrentIndex = 0;
  int selectedExpandedIndex = -1;

  final GlobalKey<NavigatorState> _keyNavigator = GlobalKey<NavigatorState>();
  String userName = "";
  List<TimeShiteResponseModel> dataList = [];
  List<TimeShiteResponseModel> confirmedDataList = [];
  List<TimeShiteResponseModel> unConfirmedDataList = [];
  List<TimeShiteResponseModel> timeSheetDataList = [];
  List<TimeShiteResponseModel> avaliableDataList = [];

  final TextEditingController _controllerFromDate = TextEditingController();
  final TextEditingController _controllerToDate = TextEditingController();

  @override
  void initState() {
    super.initState();

    getData();
    getAvailableShiftsData();
  }

  getData() async {
    userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType':
          (await Preferences().getPrefInt(Preferences.prefAccountType))
              .toString(),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'fromdate': DateFormat("yyyy/MM/dd").format(fromDate),
      'todate': DateFormat("yyyy/MM/dd").format(toDate),
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endTimeSheets, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponse $jResponse");
            dataList = jResponse
                .map((e) => TimeShiteResponseModel.fromJson(e))
                .toList();
            print("models.length : ${dataList.length}");
            confirmedDataList.clear();
            unConfirmedDataList.clear();
            timeSheetDataList.clear();
            // avaliableDataList.clear();
            int accType =
                await Preferences().getPrefInt(Preferences.prefAccountType);
            for (TimeShiteResponseModel model in dataList) {
              if (accType == 2 ||
                  accType == 4 ||
                  accType == 5 ||
                  accType == 6) {
                if (model.confirmCW == true &&
                    model.empID != 0 &&
                    model.tSConfirm == false) {
                  // type = "confirmed";
                  confirmedDataList.add(model);
                  timeSheetDataList.add(model);
                } else if (model.empID != 0 && model.timesheetStatus == true) {
                  // type = "timesheets";
                  timeSheetDataList.add(model);
                }
                // else if (model.status1 == 5 && model.EmpID != 0) {
                else if ((model.status1 == 5 || model.confirmCW == false) &&
                    model.empID != 0) {
                  // type = "unconfirmed";
                  unConfirmedDataList.add(model);
                } else if ((model.status1 == 4 || model.status1 == 0) &&
                    model.empID == 0) {
                  // type = "available";
                  // avaliableDataList.add(model);
                }
              } else if (accType == 3) {
                if (model.confirmCW == true &&
                    model.empID != 0 &&
                    model.tSConfirm == false) {
                  // type = "confirmed";
                  confirmedDataList.add(model);
                } else if (model.empID != 0 && model.timesheetStatus == true) {
                  // type = "timesheets";
                  timeSheetDataList.add(model);
                } else if (model.status1 == 5 ||
                    model.status1 == 4 ||
                    model.status1 == 0) {
                  // type = "unconfirmed";
                  unConfirmedDataList.add(model);
                } else if (model.status1 == 4 && model.empID == 0) {
                  // type = "available";
                  // avaliableDataList.add(model);
                }
              }
            }
            // confirmedDataList = dataList.where((element) => element.confirmCW == true).toList();
            // unConfirmedDataList = dataList
            //     .where((element) => element.confirmCW == false)
            //     .toList();

            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  getAvailableShiftsData() async {
    userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      /*   'accountType':
          (await Preferences().getPrefInt(Preferences.prefAccountType))
              .toString(),*/
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'fromdate': DateFormat("yyyy/MM/dd").format(fromDate),
      'todate': DateFormat("yyyy/MM/dd").format(toDate),
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endAvailableShifts, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponse $endAvailableShifts $jResponse");
            avaliableDataList.clear();
            avaliableDataList = jResponse
                .map((e) => TimeShiteResponseModel.fromJson(e))
                .toList();
            print("models.length : ${avaliableDataList.length}");
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  logout() async {
    await Preferences().setPrefString(Preferences.prefAuthCode, "");
    await Preferences().setPrefInt(Preferences.prefAccountType, 0);
    await Preferences().setPrefInt(Preferences.prefUserID, 0);
    await Preferences().setPrefString(Preferences.prefUserFullName, "");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_keyNavigator.currentState != null &&
            _keyNavigator.currentState!.canPop()) {
          _keyNavigator.currentState!.pop();
          return Future(() => false);
        }
        return Future(() => true);
      },
      child: Scaffold(
        key: keyScaffold,
        appBar: AppBar(
          title: SizedBox(
            height: 40,
            child: ThemedTextField(
              borderColor: colorPrimary,
              preFix: const FaIcon(
                FontAwesomeIcons.search,
                color: Color(0XFFBBBECB),
                size: 20,
              ),
              hintText: "Search...",
            ),
          ),
          titleSpacing: spaceHorizontal / 2,
          actions: [
            SizedBox(
              height: 40,
              child: MaterialButton(
                color: colorGreen,
                child: ThemedText(
                  text: "Note",
                  fontSize: 16,
                  color: colorWhite,
                ),
                onPressed: () {
                  setState(() {
                    bottomCurrentIndex = 5;
                  });

                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ProgressNote(),
                  //     ));
                },
              ),
            ),
            const SizedBox(width: spaceHorizontal / 2),
            SizedBox(
              height: 40,
              child: MaterialButton(
                color: colorGreen,
                child: ThemedText(
                  text: "Refresh",
                  fontSize: 16,
                  color: colorWhite,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: spaceHorizontal / 2),
            InkWell(
              onTap: () async {
                userName = await Preferences()
                    .getPrefString(Preferences.prefUserFullName);
                if (keyScaffold.currentState != null) {
                  keyScaffold.currentState!.openEndDrawer();
                }
              },
              child: Container(
                height: 50,
                width: 30,
                decoration: const BoxDecoration(
                  color: colorGreen,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(25),
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
                        ThemedText(
                          text: 'Kate Clark',
                          color: colorBlack,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                                    DateFormat("dd-MM-yyyy")
                                        .format(tempFromDate);
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
                              firstDate: DateTime(tempToDate.year - 1),
                              lastDate: DateTime(tempToDate.year + 1),
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
                        SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              Expanded(
                                child: ThemedButton(
                                  title: "Apply",
                                  fontSize: 20,
                                  padding: EdgeInsets.zero,
                                  onTap: () {
                                    fromDate = tempFromDate;
                                    toDate = tempToDate;
                                    setState(() {});
                                    if (keyScaffold.currentState != null) {
                                      keyScaffold.currentState!
                                          .closeEndDrawer();
                                    }
                                    getData();
                                    getAvailableShiftsData();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ThemedButton(
                                  title: "Cancel",
                                  fontSize: 20,
                                  padding: EdgeInsets.zero,
                                  onTap: () {
                                    tempFromDate = fromDate;
                                    tempToDate = toDate;
                                    setState(() {});
                                    if (keyScaffold.currentState != null) {
                                      keyScaffold.currentState!
                                          .closeEndDrawer();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Material(
                          borderRadius: boxBorderRadius,
                          color: colorGreen,
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              logout();
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              padding: EdgeInsets.zero,
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
                                        fontSize: 20,
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
                      size: 30,
                    ),
                    label: "CONFIRMED"),
              ),
              Expanded(
                child: _buildBottomNavBarItem(
                    index: 1,
                    icons: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorWhite,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: colorWhite,
                        size: 20,
                      ),
                    ),
                    label: "unCONFIRMED"),
              ),
              Expanded(
                child: _buildBottomNavBarItem(
                  index: 2,
                  icons: const Icon(
                    Icons.access_time_rounded,
                    color: colorWhite,
                    size: 30,
                  ),
                  label: "timesheet",
                ),
              ),
              Expanded(
                child: _buildBottomNavBarItem(
                    index: 3,
                    icons: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: colorWhite,
                      size: 30,
                    ),
                    label: "available"),
              ),
              Expanded(
                child: _buildBottomNavBarItem(
                    index: 4,
                    icons: const Icon(
                      CupertinoIcons.person_alt_circle,
                      color: colorWhite,
                      size: 30,
                    ),
                    label: "profile"),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: colorLiteBlueBackGround,
                child: getViewAsPerIndex(bottomCurrentIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildList({required List<TimeShiteResponseModel> list}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: spaceHorizontal, vertical: spaceVertical),
          child: ThemedText(
            text:
                "${bottomCurrentIndex == 1 ? "UnConfirmed" : bottomCurrentIndex == 2 ? "TimeSheet" : bottomCurrentIndex == 3 ? "Available" : "Confirmed"} : ${DateFormat("dd-MM-yyyy").format(fromDate)} - ${DateFormat("dd-MM-yyyy").format(toDate)}",
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: colorGreyText,
          ),
        ),
        const Divider(
          thickness: 1,
          height: 1,
          color: colorGreyBorderD3,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Navigator(
            key: _keyNavigator,
            pages: [
              MaterialPage(
                child: ListView.builder(
                  itemCount: list.length,
                  primary: true,
                  itemBuilder: (context, index) {
                    TimeShiteResponseModel model = list[index];
                    DateTime? serviceDate =
                        getDateTimeFromEpochTime(model.serviceDate!);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      margin:
                          const EdgeInsets.only(top: 8, right: 15, left: 15),
                      color: colorWhite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 8,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${model.resName} ",
                                                  style: const TextStyle(
                                                    color: colorGreyText,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: model.serviceName,
                                                  style: const TextStyle(
                                                    color: colorGreyLiteText,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (model.noteID != 0)
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProgressNoteListByNoteId(
                                                    userId: model.empID ?? 0,
                                                    noteID: model.noteID ?? 0,
                                                    rosterID:
                                                        model.rosterID ?? 0,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const FaIcon(
                                              FontAwesomeIcons.calendarDays,
                                              size: 22,
                                            ),
                                          ),
                                        const SizedBox(
                                            width: spaceHorizontal / 2),
                                        if (bottomCurrentIndex != 3)
                                          InkWell(
                                            onTap: () {
                                              print(
                                                  "CareWorkerList ${model.empID} ${model.rosterID}");
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CareWorkerList(
                                                          userId:
                                                              model.empID ?? 0,
                                                          rosterID:
                                                              model.rosterID ??
                                                                  0),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: const Icon(
                                                  CupertinoIcons
                                                      .person_crop_circle,
                                                  color: Colors.white,
                                                  size: 22),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 1,
                                      color: colorGreyBorderD3,
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (selectedExpandedIndex !=
                                                  index) {
                                                selectedExpandedIndex = index;
                                              } else {
                                                selectedExpandedIndex = -1;
                                              }
                                            });
                                          },
                                          child: const SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Icon(
                                              Icons.arrow_downward_rounded,
                                              color: colorGreen,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(width: 5),
                                                      const FaIcon(
                                                        FontAwesomeIcons
                                                            .calendarDays,
                                                        color: colorGreen,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      if (getDateTimeFromEpochTime(
                                                              model
                                                                  .serviceDate!) !=
                                                          null)
                                                        Text(
                                                          // model.serviceDate!,
                                                          model.serviceDate !=
                                                                  null
                                                              ? DateFormat(
                                                                      "EEE,dd-MM-yyyy")
                                                                  .format(getDateTimeFromEpochTime(
                                                                      model
                                                                          .serviceDate!)!)
                                                              : "",
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                colorGreyText,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      const SizedBox(width: 5),
                                                      Container(
                                                        width: 1,
                                                        height: 25,
                                                        color:
                                                            colorGreyBorderD3,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      /* const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                  ),*/
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                        CupertinoIcons.time,
                                                        color: colorGreen,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "${model.totalHours}hrs",
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Container(
                                                        width: 1,
                                                        height: 25,
                                                        color:
                                                            colorGreyBorderD3,
                                                      ),
                                                      const SizedBox(width: 5),
                                                    ],
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  child: Row(
                                                    children: [
                                                      /*   SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                ),*/
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                        Icons.timer,
                                                        color: colorGreen,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        model.shift ?? "",
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        if ((bottomCurrentIndex == 0 ||
                                                bottomCurrentIndex == 2) &&
                                            serviceDate != null &&
                                            serviceDate.day ==
                                                DateTime.now().day &&
                                            serviceDate.month ==
                                                DateTime.now().month &&
                                            serviceDate.year ==
                                                DateTime.now().year)
                                          InkWell(
                                            onTap:
                                                model.locationName != null &&
                                                        model.locationName!
                                                            .isNotEmpty
                                                    ? null
                                                    : () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              Dialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    boxBorderRadius),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      spaceHorizontal,
                                                                  vertical:
                                                                      spaceVertical),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  ThemedText(
                                                                      text:
                                                                          "Are You Sure You Want To Logon The Shift ?"),
                                                                  const SizedBox(
                                                                      height:
                                                                          spaceVertical),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            ThemedButton(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          title:
                                                                              "Cancel",
                                                                          fontSize:
                                                                              18,
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            spaceHorizontal /
                                                                                2,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            ThemedButton(
                                                                          onTap:
                                                                              () async {
                                                                            Navigator.pop(context);
                                                                            String?
                                                                                address =
                                                                                await getAddress();
                                                                            if (address !=
                                                                                null) {
                                                                              print("ADDRESS : $address");
                                                                              saveLocationTime(address, (model.servicescheduleemployeeID ?? 0).toString());
                                                                            }
                                                                          },
                                                                          title:
                                                                              "Ok",
                                                                          fontSize:
                                                                              18,
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                            child: FaIcon(
                                              Icons.history,
                                              color:
                                                  model.locationName != null &&
                                                          model.locationName!
                                                              .isNotEmpty
                                                      ? colorGreen
                                                      : colorRed,
                                              size: 22,
                                            ),
                                          ),
                                        if ((bottomCurrentIndex == 0 ||
                                                bottomCurrentIndex == 2) &&
                                            serviceDate != null &&
                                            serviceDate.day ==
                                                DateTime.now().day &&
                                            serviceDate.month ==
                                                DateTime.now().month &&
                                            serviceDate.year ==
                                                DateTime.now().year)
                                          const SizedBox(
                                              width: spaceHorizontal / 2),
                                        if (model.noteID != 0)
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                keyScaffold.currentContext!,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProgressNoteDetails(
                                                    userId: model.empID ?? 0,
                                                    noteId: model.noteID ?? 0,
                                                    clientId: model.clientID ?? 0,
                                                    serviceName:
                                                        model.serviceName ?? "",
                                                    clientName:
                                                        "${model.resName} - ${model.rESID.toString().padLeft(5, "0")}",
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const FaIcon(
                                              FontAwesomeIcons.notesMedical,
                                              size: 22,
                                            ),
                                          ),
                                        if (model.noteID != 0)
                                          const SizedBox(
                                              width: spaceHorizontal / 2),
                                        if (model.dsnId != 0)
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DNSList(
                                                      userId: model.empID ?? 0,
                                                      rosterID:
                                                          model.serviceShceduleClientID ?? 0),
                                                ),
                                              );
                                            },
                                            child: const FaIcon(
                                              FontAwesomeIcons.volcano,
                                              size: 22,
                                            ),
                                          ),
                                        if (model.dsnId != 0)
                                          const SizedBox(
                                              width: spaceHorizontal / 2),
                                        if (bottomCurrentIndex == 2)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: model.locationName == "" ||
                                                    model.logOffLocationName ==
                                                        ""
                                                ? colorRed
                                                : colorGreen,
                                            size: 22,
                                          ),
                                        if (bottomCurrentIndex == 2)
                                          const SizedBox(
                                              width: spaceHorizontal / 2),
                                        /*const Expanded(
                                        child: Icon(
                                      Icons.timelapse_rounded,
                                      color: colorGreen,
                                      size: 26,
                                    )),*/
                                        // const SizedBox(width: 5),
                                        Container(
                                          width: 1,
                                          height: 30,
                                          color: colorGreyBorderD3,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    keyScaffold.currentContext!,
                                    MaterialPageRoute(
                                      builder: (context) => TimeSheetDetail(
                                        model: model,
                                        indexSelectedFrom: bottomCurrentIndex,
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value != null && value) {
                                      getData();
                                      getAvailableShiftsData();
                                    }
                                  });
                                },
                                child: const Align(
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: colorGreen,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ExpandableContainer(
                            expanded: selectedExpandedIndex == index,
                            expandedHeight: 225,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ThemedText(
                                      text: model.shiftComments != null &&
                                              model.shiftComments!.isNotEmpty
                                          ? model.shiftComments!
                                          : "No shift comments provided."),
                                  ThemedText(
                                      text: model.comments != null &&
                                              model.comments!.isNotEmpty
                                          ? model.comments!
                                          : "No shift comments provided."),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      launchUrlMethod(
                                          "http://maps.google.com/?q=${model.resAddress}");
                                    },
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.locationDot,
                                              color: colorGreen,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: spaceHorizontal),
                                        Expanded(
                                          child: ThemedText(
                                              text: model.resAddress ?? ""),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      launchUrlMethod(
                                          "tel:${model.resHomePhone}");
                                    },
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.phoneVolume,
                                              color: colorGreen,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: spaceHorizontal),
                                        Expanded(
                                          child: ThemedText(
                                              text: model.resHomePhone ?? ""),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      launchUrlMethod(
                                          "tel:${model.resMobilePhone}");
                                    },
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.mobileAlt,
                                              color: colorGreen,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: spaceHorizontal),
                                        Expanded(
                                          child: ThemedText(
                                              text: model.resMobilePhone ?? ""),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ClientDocument(
                                            id: (model.clientID ?? 0)
                                                .toString(),
                                            resId:
                                                (model.rESID ?? 0).toString(),
                                          ),
                                        ),
                                      );
                                      // _launchUrl(
                                      //     "https://mycare.mycaresoftware.com/Uploads/client/5/MyDocs/Cappadocia1.jpg");
                                    },
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.fileLines,
                                              color: colorGreen,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: spaceHorizontal),
                                        Expanded(
                                          child: ThemedText(
                                              text: "View Client Documents"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      print("model.clientID : ${model.rESID}");
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ClientInfo(
                                              clientId:
                                                  (model.rESID ?? 0).toString(),
                                            ),
                                          ));
                                    },
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.circleInfo,
                                              color: colorGreen,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: spaceHorizontal),
                                        Expanded(
                                          child: ThemedText(
                                              text: "View Client Info"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> getAddress() async {
    try {
      getOverlay(context);
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnackBarWithText(
            keyScaffold.currentState, "Please Enable the Location!");
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnackBarWithText(
              keyScaffold.currentState, "We need Location Permission!");
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnackBarWithText(
            keyScaffold.currentState, "We need Location Permission!");
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> addressList =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      return addressList[0].toString().replaceAll("\n", "");
    } catch (e) {
      showSnackBarWithText(keyScaffold.currentState, stringSomeThingWentWrong);
      print(e);
    } finally {
      removeOverlay();
      // setState(() {});
    }
    // return null;
  }

  saveLocationTime(String address, String sSEID) async {
    userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'servicescheduleemployeeID': sSEID,
      'Location': address,
      'SaveTimesheet': "false",
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endSaveLocationTime, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            // print('res ${response}');

            if (json.decode(response)["status"] == 1) {
              showSnackBarWithText(keyScaffold.currentState, "Success",
                  color: colorGreen);
              getData();
              getAvailableShiftsData();
              // Navigator.pop(context);
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  Widget getViewAsPerIndex(int index) {
    switch (index) {
      // case 0:
      //   return _buildList(list: confirmedDataList);
      case 1:
        return _buildList(list: unConfirmedDataList);
      case 2:
        return _buildList(list: timeSheetDataList);
      case 3:
        return _buildList(list: avaliableDataList);
      case 5:
        return const ProgressNote();
      default:
        return _buildList(list: confirmedDataList);
    }
  }

  _buildBottomNavBarItem(
      {required int index, required String label, required Widget icons}) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_keyNavigator.currentState != null) {
            while (_keyNavigator.currentState!.canPop()) {
              _keyNavigator.currentState!.pop();
            }
          }
          if (index < 4) {
            bottomCurrentIndex = index;
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileTabScreen(),
                ));
          }
        });
      },
      child: Container(
        color: bottomCurrentIndex == index ? colorPrimary : colorLiteBlue,
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                icons,
                if (index < 4)
                  Positioned(
                    top: -3,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        index == 1
                            ? unConfirmedDataList.length.toString()
                            : index == 2
                                ? timeSheetDataList.length.toString()
                                : index == 3
                                    ? avaliableDataList.length.toString()
                                    : confirmedDataList.length.toString(),
                        style: const TextStyle(
                          color: colorPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: spaceVertical / 2),
            ThemedText(
              text: label.toUpperCase(),
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w500,
              maxLine: 1,
            )
          ],
        ),
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget child;

  ExpandableContainer({
    super.key,
    required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: new Container(
        child: child,
        // decoration: new BoxDecoration(
        //   border: new Border.all(width: 1.0, color: Colors.blue),
        // ),
      ),
    );
  }
}
