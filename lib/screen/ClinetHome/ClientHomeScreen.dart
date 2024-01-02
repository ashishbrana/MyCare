import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/ClinetHome/ServiceForm.dart';
import 'package:rcare_2/screen/ClinetHome/model/ClientFundingDetail.dart';
import 'package:rcare_2/screen/Login/Login.dart';
import 'package:rcare_2/screen/home/CareWorkerList.dart';
import 'package:rcare_2/screen/home/ClientDocument.dart';
import 'package:rcare_2/screen/home/ClientInfo.dart';
import 'package:rcare_2/screen/home/DNSList.dart';
import 'package:rcare_2/screen/home/ProgressNoteListByNoteId.dart';
import 'package:rcare_2/screen/home/notes/NotesDetails.dart';
import 'package:rcare_2/screen/home/notes/ProgressNotes.dart';
import 'package:rcare_2/screen/home/tabs/ProfileTabScreen.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';


import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/GlobalMethods.dart';
import '../../utils/Preferences.dart';
import '../../utils/methods.dart';
import '../home/TimeSheetDetail.dart';
import '../home/TimeSheetForm.dart';
import '../home/models/ConfirmedResponseModel.dart';
import '../home/models/GroupServiceResponseModel.dart';
import '../home/models/ProgressNoteModel.dart';


DateTime fromDate = DateTime.now();
DateTime toDate = fromDate.addDays(14);
DateTime tempFromDate = DateTime.now();
DateTime tempToDate = DateTime.now();
GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int bottomCurrentIndex = 0;
  int selectedExpandedIndex = -1;

  final GlobalKey<NavigatorState> _keyNavigator = GlobalKey<NavigatorState>();
  String userName = "";
  List<TimeShiteModel> dataList = [];
  List<TimeShiteModel> confirmedDataList = [];
  List<TimeShiteModel> unConfirmedDataList = [];
  List<TimeShiteModel> timeSheetDataList = [];
  List<TimeShiteModel> availableDataList = [];
  List<ClientFundingDetail> fundingList = [];
  List<ClientFundingDetail> notesTempList = [];
  List<TimeShiteModel> mainList = [];
  List<TimeShiteModel> tempList = [];


  TimeShiteModel? selectedModel;

  final TextEditingController _controllerFromDate = TextEditingController();
  final TextEditingController _controllerToDate = TextEditingController();
  final TextEditingController _controllerSearch = TextEditingController();
  FocusScopeNode focusNode = FocusScopeNode();
  FocusScopeNode focusNavigatorNode = FocusScopeNode();

  GlobalKey<ProgressNoteState> keyProgressNoteTab =
  GlobalKey<ProgressNoteState>();

  @override
  void initState() {
    super.initState();

    getData();
    loadFundingServiceType();
    loadclientServiceType();
    getFundingList();
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
    print("params : $params");
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

          if (response != null && response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            // print("jResponse $jResponse");
            dataList =
                jResponse.map((e) => TimeShiteModel.fromJson(e)).toList();
            print("models.length : ${dataList.length}");
            confirmedDataList.clear();
            unConfirmedDataList.clear();
            timeSheetDataList.clear();
            // avaliableDataList.clear();
            int accType =
            await Preferences().getPrefInt(Preferences.prefAccountType);
            for (TimeShiteModel model in dataList) {
              if (accType == 2 ||
                  accType == 4 ||
                  accType == 5 ||
                  accType == 6) {
                if (model.confirmCW == true &&
                    model.empID != 0 &&
                    model.tSConfirm == true) {
                  // type = "confirmed";
                  confirmedDataList.add(model);
                  DateTime? serviceDate =
                  getDateTimeFromEpochTime(model.serviceDate!);
                  if (serviceDate!.isToday){
                    timeSheetDataList.add(model);
                  }
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
            switch (bottomCurrentIndex) {
              case 1:
                mainList = unConfirmedDataList;

                break;
              case 2:
                mainList = timeSheetDataList;

                break;
              case 3:
                mainList = availableDataList;

                break;
              default:
                mainList = confirmedDataList;
                break;
            }
            tempList.clear();
            tempList.addAll(mainList);
            removeOverlay();
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

  loadFundingServiceType() async {
    print("availableDataList getAvailableShiftsData");
    userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
      (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
      (await Preferences().getPrefInt(Preferences.prefUserID)).toString()
    };
    print("getAvailableShiftsData : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(getFundingServiceType, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          print("availableDataList $endAvailableShifts $response");
          removeOverlay();
          if (response != null && response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            // print("jResponse $endAvailableShifts $jResponse");
            availableDataList.clear();
            availableDataList =
                jResponse.map((e) => TimeShiteModel.fromJson(e)).toList();
            print("availableDataList : ${availableDataList.length}");

            if (bottomCurrentIndex == 3) {
              mainList.addAll(availableDataList);
              tempList.clear();
              tempList.addAll(mainList);
              print("availableDataList ${availableDataList.length}");
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          availableDataList.clear();
          mainList.addAll(availableDataList);
          tempList.clear();
          tempList.addAll(mainList);
          setState(() {});
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

  loadclientServiceType() async {
    print("availableDataList getAvailableShiftsData");
    userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
      (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
      (await Preferences().getPrefInt(Preferences.prefUserID)).toString()
    };
    print("getAvailableShiftsData : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(clientservicetype, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          print("availableDataList $endAvailableShifts $response");
          removeOverlay();
          if (response != null && response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            // print("jResponse $endAvailableShifts $jResponse");
            availableDataList.clear();
            availableDataList =
                jResponse.map((e) => TimeShiteModel.fromJson(e)).toList();
            print("availableDataList : ${availableDataList.length}");

            if (bottomCurrentIndex == 3) {
              mainList.addAll(availableDataList);
              tempList.clear();
              tempList.addAll(mainList);
              print("availableDataList ${availableDataList.length}");
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          availableDataList.clear();
          mainList.addAll(availableDataList);
          tempList.clear();
          tempList.addAll(mainList);
          setState(() {});
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

  getFundingList() async {
    // userName = await Preferences().getPrefString(Preferences.prefUserFullName);
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
      'isCareworkerSpecific': "1",
      'rosterid': "0",
    };
    print("getFundingList : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endClientFundingDetails, params: params).toString(),
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
            print("getFundingList $jResponse");
            fundingList =
                jResponse.map((e) => ClientFundingDetail.fromJson(e)).toList();
            notesTempList.clear();
            notesTempList.addAll(fundingList);
            print("NOTES : ${fundingList.length}");
            int accType =
            await Preferences().getPrefInt(Preferences.prefAccountType);

            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERRORparsing : $e");
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
    keyScaffold = GlobalKey<ScaffoldState>();
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
        if (bottomCurrentIndex != 0) {
          setState(() {
            bottomCurrentIndex = 0;
          });
          return Future(() => false);
        }
        return Future(() => true);
      },
      child: Scaffold(
        key: keyScaffold,
        appBar: _buildAppBar(),
        endDrawer: _buildEndDrawer(),
        onEndDrawerChanged: (opened) async {
          userName =
          await Preferences().getPrefString(Preferences.prefUserFullName);
          setState(() {});
        },
        bottomNavigationBar: _buildBottomNavigation(),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: colorLiteBlueBackGround,
                child: _buildList(list: tempList),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBottomNavigation() {
    return SizedBox(
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
                label: "UNCONFIRMED"),
          ),
          Expanded(
            child: _buildBottomNavBarItem(
              index: 2,
              icons: const Icon(
                Icons.access_time_rounded,
                color: colorWhite,
                size: 30,
              ),
              label: "COMPLETED",
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
                label: "ADD NEW"),
          ),
          Expanded(
            child: _buildBottomNavBarItem(
                index: 4,
                icons: const Icon(
                  Icons.note_alt_outlined,
                  color: colorWhite,
                  size: 30,
                ),
                label: "FUNDING"),
          ),
          /*  Expanded(
                child: _buildBottomNavBarItem(
                    index: 4,
                    icons: const Icon(
                      CupertinoIcons.person_alt_circle,
                      color: colorWhite,
                      size: 30,
                    ),
                    label: "profile"),
              ),*/
        ],
      ),
    );
  }

  _buildEndDrawer() {
    return SizedBox(
      width: double.infinity,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    if (keyScaffold.currentState != null) {
                      keyScaffold.currentState!.closeEndDrawer();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
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
                      text: userName,
                      color: colorBlack,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: spaceVertical),
                    Material(
                      borderRadius: boxBorderRadius,
                      color: colorGreen,
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                          // logout();
                          if (keyScaffold.currentState != null) {
                            keyScaffold.currentState!.closeEndDrawer();
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileTabScreen(),
                              ));
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
                                FontAwesomeIcons.user,
                                color: colorWhite,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Profile",
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
                    const SizedBox(height: spaceVertical),
                    Material(
                      borderRadius: boxBorderRadius,
                      color: colorGreen,
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                          showConfirmationDialog(onYesTap: () {
                            if (keyScaffold.currentState != null) {
                              keyScaffold.currentState!.closeEndDrawer();
                            }
                            logout();
                          }, onNoTap: () {
                            Navigator.pop(context);
                          });
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
    );
  }

  showConfirmationDialog(
      {required void Function() onYesTap,
        required void Function() onNoTap,
        String? extendedText}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: boxBorderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: spaceVertical),
            ThemedText(text: "Are you sure ${extendedText ?? ""}? "),
            const SizedBox(height: spaceVertical),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  const SizedBox(width: spaceHorizontal * 2),
                  Expanded(
                    child: ThemedButton(
                      title: "Yes",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      padding: EdgeInsets.zero,
                      onTap: onYesTap,
                    ),
                  ),
                  const SizedBox(width: spaceHorizontal),
                  Expanded(
                    child: ThemedButton(
                      title: "No",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      padding: EdgeInsets.zero,
                      onTap: onNoTap,
                    ),
                  ),
                  const SizedBox(width: spaceHorizontal * 2),
                ],
              ),
            ),
            const SizedBox(height: spaceVertical),
          ],
        ),
      ),
    );
  }

  _buildDateDialog() {
    tempFromDate = fromDate;
    tempToDate = toDate;
    _controllerFromDate.text = DateFormat("dd-MM-yyyy").format(fromDate);
    _controllerToDate.text = DateFormat("dd-MM-yyyy").format(toDate);

    setState(() {});
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius * 2)),
          insetPadding: const EdgeInsets.symmetric(
              horizontal: spaceHorizontal, vertical: spaceVertical * 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: spaceHorizontal, vertical: spaceVertical * 1.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                              keyScaffold.currentState!.closeEndDrawer();
                            }
                            getData();
                            loadFundingServiceType();
                            getFundingList();
                            Navigator.pop(context);
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
                              keyScaffold.currentState!.closeEndDrawer();
                            }
                            Navigator.pop(context);
                            /*if (keyScaffold.currentState != null) {
                              keyScaffold.currentState!.closeEndDrawer();
                            }*/
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildAppBar() {
    return AppBar(
      title: SizedBox(
        height: 40,
        child: FocusScope(
          node: focusNode,
          child: ThemedTextField(
            borderColor: colorPrimary,
            controller: _controllerSearch,
            // currentFocusNode: focusNode,
            preFix: const FaIcon(
              FontAwesomeIcons.search,
              color: Color(0XFFBBBECB),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            hintText: "Search...",
            onTap: () {
              focusNavigatorNode.unfocus();
              focusNode.requestFocus();
            },
            onChanged: (string) {
              if (bottomCurrentIndex == 4) {
                if (string.isNotEmpty && string.length > 1) {
                  notesTempList = [];
                  for (ClientFundingDetail model in fundingList) {
                    if ((model.fundingServiceName != null &&
                        model.fundingServiceName!
                            .toLowerCase()
                            .contains(string.toLowerCase())) ||
                        (model.sourceType != null &&
                            model.sourceType!
                                .toLowerCase()
                                .contains(string.toLowerCase()))) {
                      notesTempList.add(model);
                    }
                  }
                } else {
                  notesTempList = [];
                  notesTempList.addAll(fundingList);
                }
                setState(() {});
              } else {
                if (string.isNotEmpty && string.length > 1) {
                  tempList = [];
                  for (TimeShiteModel model in mainList) {
                    if ((model.serviceName != null &&
                        model.serviceName!
                            .toLowerCase()
                            .contains(string.toLowerCase())) ||
                        (model.serviceName != null &&
                            model.resName!
                                .toLowerCase()
                                .contains(string.toLowerCase()))) {
                      tempList.add(model);
                    }
                  }
                } else {
                  tempList = [];
                  tempList.addAll(mainList);
                }
              }
              setState(() {});
            },
          ),
        ),
      ),
      titleSpacing: spaceHorizontal / 2,
      actions: [
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              color: colorGreen,
              child: InkWell(
                onTap: () {
                  getData();
                  loadFundingServiceType();
                  getFundingList();
                },
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.refresh,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: spaceHorizontal / 2),
        InkWell(
          onTap: () async {
            userName =
            await Preferences().getPrefString(Preferences.prefUserFullName);
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
    );
  }

  _buildList({required List<TimeShiteModel> list}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            _buildDateDialog();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: spaceHorizontal, vertical: spaceVertical),
            child: ThemedText(
              text:
              "${bottomCurrentIndex == 1 ? "UnConfirmed" : bottomCurrentIndex == 2 ? "Completed" : bottomCurrentIndex == 3 ? "u" : bottomCurrentIndex == 4 ? "Funding" : "Confirmed"} : ${DateFormat("dd-MM-yyyy").format(fromDate)} - ${DateFormat("dd-MM-yyyy").format(toDate)}",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorGreyText,
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 1,
          color: colorGreyBorderD3,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: FocusScope(
            node: focusNavigatorNode,
            child: Navigator(
              key: _keyNavigator,
              onPopPage: (route, result) {
                if (_keyNavigator.currentState != null) {
                  return _keyNavigator.currentState!.canPop();
                } else {
                  return false;
                }
              },
              pages: [
                MaterialPage(
                  child: Scaffold(
                    body: bottomCurrentIndex == 4
                        ? _buildProgressNoteList()
                        :  ListView.builder(
                      itemCount: list.length,
                      primary: true,
                      itemBuilder: (context, index) {
                        TimeShiteModel model = list[index];
                        DateTime? serviceDate =
                        getDateTimeFromEpochTime(
                            model.serviceDate!);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          margin: const EdgeInsets.only(
                              top: 8, right: 15, left: 15),
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
                                                      text:
                                                      "${model.resName}",
                                                      style:
                                                      const TextStyle(
                                                        color:
                                                        colorGreyText,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:  " ${model.serviceName}",
                                                      style:
                                                      const TextStyle(
                                                        color:
                                                        colorGreyLiteText,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: " ${model.emplName}",
                                                      style:
                                                      const TextStyle(
                                                        color:
                                                        colorGreyText,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width:
                                          MediaQuery.of(context)
                                              .size
                                              .width,
                                          height: 1,
                                          color: colorGreyBorderD3,
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (selectedExpandedIndex !=
                                                      index) {
                                                    selectedExpandedIndex =
                                                        index;
                                                  } else {
                                                    selectedExpandedIndex =
                                                    -1;
                                                  }
                                                });
                                              },
                                              child: const SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: Icon(
                                                  Icons
                                                      .arrow_downward_rounded,
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
                                                        MainAxisSize
                                                            .min,
                                                        children: [
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                          const FaIcon(
                                                            FontAwesomeIcons
                                                                .calendarDays,
                                                            color:
                                                            colorGreen,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                            Text(
                                                              formatServiceDate(model.serviceDate),
                                                              style:
                                                              const TextStyle(
                                                                color:
                                                                colorGreyText,
                                                                fontSize:
                                                                14,
                                                              ),
                                                            ),
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                          Container(
                                                            width: 1,
                                                            height:
                                                            25,
                                                            color:
                                                            colorGreyBorderD3,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    WidgetSpan(
                                                      child: Row(
                                                        mainAxisSize:
                                                        MainAxisSize
                                                            .min,
                                                        children: [
                                                          /* const SizedBox(
                                                        width: 30,
                                                        height: 30,
                                                      ),*/
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                          const Icon(
                                                            CupertinoIcons
                                                                .time,
                                                            color:
                                                            colorGreen,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                          Text(
                                                            "${model.totalHours}hrs",
                                                            style:
                                                            const TextStyle(
                                                              color:
                                                              colorGreyText,
                                                              fontSize:
                                                              14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                          Container(
                                                            width: 1,
                                                            height:
                                                            25,
                                                            color:
                                                            colorGreyBorderD3,
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                              5),
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
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                          const Icon(
                                                            Icons
                                                                .timer,
                                                            color:
                                                            colorGreen,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                          Text(
                                                            model.shift ??
                                                                "",
                                                            style:
                                                            const TextStyle(
                                                              color:
                                                              colorGreyText,
                                                              fontSize:
                                                              14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                              5),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      selectedModel = model;
                                      Navigator.push(
                                        keyScaffold.currentContext!,
                                        MaterialPageRoute(
                                          builder: (context) =>  ServiceForm(
                                              model: model,
                                              indexSelectedFrom:
                                              bottomCurrentIndex),
                                        ),
                                      ).then((value) {
                                        if (value != null) {
                                          if (value == 0) {
                                            getData();
                                            loadFundingServiceType();
                                            getFundingList();
                                          } else if (value == 1) {
                                            bottomCurrentIndex = 5;
                                            setState(() {});
                                          }
                                        }
                                      });
                                    },
                                    child: const Align(
                                      child: Icon(
                                        Icons
                                            .arrow_forward_ios_rounded,
                                        color: colorGreen,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedExpandedIndex == index)
                              Row( // this row has full width
                              children: [
                                const SizedBox(width: 40),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    ThemedText(
                                        textAlign: TextAlign.start,
                                        color: Colors.black,
                                        text: (model.shiftComments !=
                                            null &&
                                            model.shiftComments!.trim()
                                                .isNotEmpty
                                            ? model.shiftComments!
                                            : "No shift comments provided.")),
                                    ThemedText(
                                        textAlign: TextAlign.start,
                                        color: Colors.black,
                                        text: model.comments !=
                                            null &&
                                            model.comments!
                                                .isNotEmpty
                                            ? model.comments!
                                            : "No client comments provided."),
                                    const SizedBox(height: 7),
                                  ],
                                ),
                        ])
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildProgressNoteList() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: colorLiteBlueBackGround,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: notesTempList.length,
                    primary: true,
                    itemBuilder: (context, index) {
                      ClientFundingDetail model = notesTempList[index];
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                  Row(
                                  children: [

                                      ThemedText(
                                          text: "${model.fundingServiceName}",
                                          color: colorBlack,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                      ThemedText(
                                          text:
                                          " ${model.sourceType}",
                                          color: colorGreyLiteText,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                      ]
                                  ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width,
                                        height: 1,
                                        color: colorGreyBorderD3,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (selectedExpandedIndex != -1) {
                                                selectedExpandedIndex = -1;
                                              } else {
                                                selectedExpandedIndex = index;
                                              }
                                              setState(() {});
                                            },
                                            child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Icon(
                                                Icons.arrow_downward_rounded,
                                                color: colorGreen,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ThemedRichText(
                                              spanList: [
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
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 5),
                                                  Text( formatServiceDate(model.startDate),
                                                        style: TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      const FaIcon(
                                                        FontAwesomeIcons
                                                            .calendarDays,
                                                        color: colorGreen,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text( formatServiceDate(model.endDate),
                                                        style: TextStyle(
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
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                   /* print("progressnote 2");
                                    if (keyScaffold.currentContext != null) {
                                      Navigator.of(keyScaffold.currentContext!)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProgressNoteDetails(
                                                userId:
                                                model.serviceScheduleEmpID ?? 0,
                                                clientId: model.clientID ?? 0,
                                                noteId: model.noteID ?? 0,
                                                serviceShceduleClientID:
                                                model.servicescheduleCLientID ??
                                                    0,
                                                servicescheduleemployeeID:
                                                model.serviceScheduleEmpID ?? 0,
                                                serviceName:
                                                model.serviceName ?? "",
                                                clientName: model.clientName,
                                                noteWriter:
                                                model.createdByName ?? "",
                                                serviceDate:
                                                getDateTimeFromEpochTime(
                                                    model.serviceDate ??
                                                        "") ??
                                                    DateTime.now(),
                                              ),
                                        ),
                                      );
                                    }*/
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
                            if (selectedExpandedIndex == index)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                           const SizedBox(
                                                width: 30),
                                            Expanded(
                                              child: ThemedText(
                                                text:
                                                "Budget: \$${model.budget?.toDouble().toInt() ?? "0"}",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                                width: spaceHorizontal),
                                            Expanded(
                                              child: ThemedText(
                                                text:
                                                "Utilised \$${model.utilizeTotal ?? ""}",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      const SizedBox(width: 30),
                                      Expanded(
                                        child: ThemedText(
                                          text:
                                          "Balance: \$${model.balanceAmount ?? ""}",
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
        ),
      ],
    );
  }

  Widget getViewAsPerIndex(int index) {
    if (index < 4) {
      return _buildList(list: tempList);
    } else {
      return _buildProgressNoteList(); /*ProgressNote(
        key: keyProgressNoteTab,
      );*/
    }
  }


  void showAddNew(){
    Navigator.push(
      keyScaffold.currentContext!,
      MaterialPageRoute(
        builder: (context) =>  ServiceForm(
            model: TimeShiteModel(),
            indexSelectedFrom:
            -1),
      ),
    ).then((value) {
      if (value != null) {
        if (value == 0) {
          getData();
          getFundingList();
        } else if (value == 1) {
          bottomCurrentIndex = 5;
          setState(() {});
        }
      }
    });
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
          switch (index) {
            case 3:
              showAddNew();
              break;
            case 1:
              mainList = unConfirmedDataList;
              bottomCurrentIndex = index;
              break;
            case 2:
              mainList = timeSheetDataList;
              bottomCurrentIndex = index;
              break;
            case 4:
            /*  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileTabScreen(),
                  ));*/
              print(fundingList.length);
              // mainList = availableDataList;
              bottomCurrentIndex = index;
              break;
            default:
              mainList = confirmedDataList;
              bottomCurrentIndex = index;
              break;
          }
          _controllerSearch.text = "";
          tempList.clear();
          tempList.addAll(mainList);
          setState(() {});
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
                // if (index < 4)
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
                      getRecordsCount(index).toString(),
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

  int getRecordsCount(int index) {
    switch (index) {
      case 1:
        return unConfirmedDataList.length;
      case 2:
        return timeSheetDataList.length;
      case 3:
        return availableDataList.length;
      case 4:
        return fundingList.length;
      default:
        return confirmedDataList.length;
    }
  }
}
