import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../calendar/calendar_controller_provider.dart';
import '../../calendar/calendar_event_data.dart';
import '../../calendar/event_controller.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/GlobalMethods.dart';
import '../../utils/Preferences.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';
import '../../widget/day_view_widget.dart';
import '../../widget/week_view_widget.dart';
import '../CustomView/VersionUpdateDialogWidget.dart';
import 'GroupNoteList.dart';
import 'TimeSheetDetail.dart';
import 'TimeSheetForm.dart';
import 'models/ConfirmedResponseModel.dart';
import 'models/GroupServiceResponseModel.dart';
import 'models/ProgressNoteModel.dart';

DateTime fromDate = DateTime.now();
DateTime toDate = fromDate.addDays(14);
GlobalKey<ScaffoldState> keyScaffold = GlobalKey<ScaffoldState>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final AppLifecycleListener _listener;
  late AppLifecycleState? _state;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );
  bool _isCalendarView = false;

  int bottomCurrentIndex = 0;
  int selectedExpandedIndex = -1;
  int lastSelectedRow = -1;

  final GlobalKey<NavigatorState> _keyNavigator = GlobalKey<NavigatorState>();
  String userName = "";
  List<TimeShiteModel> dataList = [];
  List<TimeShiteModel> confirmedDataList = [];
  List<TimeShiteModel> unConfirmedDataList = [];
  List<TimeShiteModel> timeSheetDataList = [];
  List<TimeShiteModel> availableDataList = [];
  List<ProgressNoteModel> notesDataList = [];
  List<ProgressNoteModel> notesTempList = [];
  List<TimeShiteModel> mainList = [];
  List<TimeShiteModel> tempList = [];
  List<GroupServiceModel> mainListGroupService = [];
  List<GroupServiceModel> tempListGroupService = [];
  List<CalendarEventData> _events = [];

  TimeShiteModel? selectedModel;

  final TextEditingController _controllerSearch = TextEditingController();
  FocusScopeNode focusNode = FocusScopeNode();
  FocusScopeNode focusNavigatorNode = FocusScopeNode();

  GlobalKey<ProgressNoteState> keyProgressNoteTab =
      GlobalKey<ProgressNoteState>();

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      print(_packageInfo.version);
      _packageInfo = info;
    });
  }

  Future<bool> isDayPassed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastCalled =
        DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastCalled') ?? 0);
    DateTime now = DateTime.now();
    // Check if a day has passed
    if (now.difference(lastCalled).inDays >= 1) {
      // Update the last called time to today
      await prefs.setInt('lastCalled', now.millisecondsSinceEpoch);
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
      onResume: () => _handleTransition('resume'),
    );
    if (_state != null) {
      print(_state!.name);
      if(_state == AppLifecycleState.resumed){
        print("Check time now");
      }
    }

    _initPackageInfo();
    getData();
    getAvailableShiftsData();
    getDataProgressNotes();
  }

  Future<void> _handleTransition(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? startTimeString = prefs.getString('sessionStartTime');
    DateTime? sessionStartTime;
    if (startTimeString != null) {
      sessionStartTime = DateTime.parse(startTimeString);
    }
      final now = DateTime.now();
      final difference = now.difference(sessionStartTime!);
      if (difference.inMinutes >= 1440){
        logout();
      }
  }

  // Function to show the version update dialog
  void _showVersionUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VersionUpdateDialogWidget(
        onYesTap: () {
          // Handle Ok button tap here
          Navigator.of(context).pop(); // Close the dialog
        },
      ),
    );
  }

  checkLatestVersion() async {
    bool dayPassed = await isDayPassed();
    // If a day has passed, call your target function
    if (dayPassed) {
      return;
    }
    Map<String, dynamic> params = {'devicetype': deviceType};
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(latestMobileAppVersion, params: params).toString(),
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            var jres = json.decode(response);
            if (jres["status"] == 1) {
              var version = jres["message"].toString();
              if (version != appVersion) {
                /*  showVersionUpdateDialog(onYesTap: () {
                  Navigator.pop(context);
                });*/
                _showVersionUpdateDialog(context);
              }
            }
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

  getData() async {
    userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code': (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType': (await Preferences().getPrefInt(Preferences.prefAccountType)).toString(),
      'userid': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'fromdate': fromDate.shortDate(),
      'todate': toDate.shortDate(),
    };
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endTimeSheets, params: params).toString(),
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);

          if (response.isNotEmpty && !response.contains("\"status\":0")) {
            List jResponse = json.decode(response);
            dataList =
                jResponse.map((e) => TimeShiteModel.fromJson(e)).toList();
            print("models.length : ${dataList.length}");
            confirmedDataList.clear();
            unConfirmedDataList.clear();
            timeSheetDataList.clear();
            int accType =
                await Preferences().getPrefInt(Preferences.prefAccountType);
            for (TimeShiteModel model in dataList) {
              if (accType == 2 ||
                  accType == 4 ||
                  accType == 5 ||
                  accType == 6) {
                if (model.confirmCW == true &&
                    model.empID != 0 &&
                    model.tSConfirm == false) {
                  // type = "confirmed";
                  confirmedDataList.add(model);
                  DateTime? serviceDate =
                      getDateTimeFromEpochTime(model.serviceDate!);
                  if (serviceDate!.isToday) {
                    timeSheetDataList.add(model);
                  }
                } else if (model.empID != 0 && model.timesheetStatus == true) {
                  timeSheetDataList.add(model);
                }
                // else if (model.status1 == 5 && model.EmpID != 0) {
                else if ((model.status1 == 5 || model.confirmCW == false) &&
                    model.empID != 0) {
                  unConfirmedDataList.add(model);
                } else if ((model.status1 == 4 || model.status1 == 0) &&
                    model.empID == 0) {

                }
              } else if (accType == 3) {
                if (model.confirmCW == true &&
                    model.empID != 0 &&
                    model.tSConfirm == false) {
                  confirmedDataList.add(model);
                } else if (model.empID != 0 && model.timesheetStatus == true) {
                  timeSheetDataList.add(model);
                } else if (model.status1 == 5 ||
                    model.status1 == 4 ||
                    model.status1 == 0) {
                  unConfirmedDataList.add(model);
                } else if (model.status1 == 4 && model.empID == 0) {}
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

            if(_events.isNotEmpty) {
              CalendarControllerProvider
                  .of(context)
                  .controller
                  .removeAll(_events);
            }
            for (int k = 0; k < tempList.length; k++) {
              var model = tempList[k];
              var arr = model.shift?.split("-") ?? [];
              var sT = arr[0].split(":") ?? [];
              var eT = arr[1].split(":") ?? [];
              var startHour = sT[0];
              var startMin = sT[1];
              var endHour = eT[0];
              var endMin = eT[1];
              var dt = getDateTimeFromEpochTime(model.serviceDate ?? "") ??
                  DateTime.now();

              var event = CalendarEventData(
                  date: dt,
                  title: model.isGroupService
                      ? "${model.groupName}"
                      : "${model.resName}",
                  description: model.serviceName,
                  startTime: DateTime(dt.year, dt.month, dt.day,
                      int.parse(startHour), int.parse(startMin)),
                  endTime: DateTime(dt.year, dt.month, dt.day, int.parse(endHour),
                      int.parse(endMin)),
                  event: model);
              _events.add(event);
              //EventController()..addAll(_events);
              CalendarControllerProvider.of(context).controller.add(event);
            }


            removeOverlay();
            setState(() {});
          } else {
            tempList.clear();
            confirmedDataList.clear();
            unConfirmedDataList.clear();
            timeSheetDataList.clear();
            print("getData ERROR : $response");
            // showSnackBarWithText(keyScaffold.currentState, noRecordFound);
            //setState(() {});
          }
          removeOverlay();
        } catch (e) {
          print("getData ERROR : $e");
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
    print("availableDataList getAvailableShiftsData");
    userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code': (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'fromdate': fromDate.shortDate(),
      'todate': toDate.shortDate(),
    };
    print("getAvailableShiftsData : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endAvailableShifts, params: params).toString(),
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          print("availableDataList $endAvailableShifts $response");
          removeOverlay();
          if (response != null && response != "") {
            List jResponse = json.decode(response);
            availableDataList.clear();
            availableDataList =
                jResponse.map((e) => TimeShiteModel.fromJson(e)).toList();

            if (bottomCurrentIndex == 3) {
              mainList.addAll(availableDataList);
              tempList.clear();
              tempList.addAll(mainList);
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("getAvailableShiftsData ERROR : $e");
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

  getDataProgressNotes() async {
    int userid =  await Preferences().getPrefInt(Preferences.prefUserID);
    Map<String, dynamic> params = {
      'auth_code': (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType': (await Preferences().getPrefInt(Preferences.prefAccountType)).toString(),
      'userid': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'fromdate': fromDate.shortDate(),
      'todate': toDate.shortDate(),
      'isCareworkerSpecific': "1",
      'rosterid': "0",
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(progressNotesList, params: params).toString(),
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          log("$progressNotesList : $response");
          removeOverlay();
          if (response.isNotEmpty && !response.contains("\"status\":0")) {
            List jResponse = json.decode(response);
            var tempnotesDataList = jResponse.map((e) => ProgressNoteModel.fromJson(e)).toList();
            notesTempList.clear();
            notesDataList.clear();
            for(ProgressNoteModel model in tempnotesDataList){
              if(model.isConfidential == true && model.createdBy != userid){

              }
              else{
                notesDataList.add(model);
                notesTempList.add(model);
              }
            }

            setState(() {});
          } else {
            notesTempList.clear();
            setState(() {});
            if (bottomCurrentIndex == 4) {
              showSnackBarWithText(keyScaffold.currentState, noRecordFound);
            }
          }
          removeOverlay();
        } catch (e) {
          print("getDataProgressNotes ERROR : $e");
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
    CalendarControllerProvider
        .of(context)
        .controller
        .removeAll(_events);
    var pref = Preferences();
    pref.reset();
    keyScaffold = GlobalKey<ScaffoldState>();
   // Navigator.pop(context);
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
                //  child: DayViewWidget()
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
                  Icons.note_alt_outlined,
                  color: colorWhite,
                  size: 30,
                ),
                label: "NOTE"),
          ),
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
                    Container(
                      height: 150,
                      width: 150,
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
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
                            Navigator.pop(context);
                            logout();
                          }, onNoTap: () {
                            Navigator.pop(context);
                            if (keyScaffold.currentState != null) {
                              keyScaffold.currentState!.closeEndDrawer();
                            }
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
                    const SizedBox(height: 30),
                    ThemedText(
                      text: "App Version: ${_packageInfo.version}",
                      color: colorGrey88,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 20),
                ThemedText(
                  text: "Sign Out",
                  color: colorBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: ThemedText(
                    text: "Are you sure you want to sign out?",
                    color: colorBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildDateDialog() {
    final TextEditingController controllerFromDate = TextEditingController();
    final TextEditingController controllerToDate = TextEditingController();
    DateTime tempFromDate = fromDate;
    DateTime tempToDate = toDate;

    updateDates() {
      controllerFromDate.text = DateFormat("dd-MM-yyyy").format(tempFromDate);
      controllerToDate.text = DateFormat("dd-MM-yyyy").format(tempToDate);
    }

    Widget buildIconContainer(IconData icon) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorLiteGreen,
          borderRadius: BorderRadius.circular(
              8.0), // You can adjust the border radius as needed
        ),
        child: FaIcon(
          icon,
          color: colorGreyText,
          size: 20,
        ),
      );
    }

    updateDates();

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
                  controller: controllerFromDate,
                  borderColor: colorGreyBorderD3,
                  preFix: const FaIcon(
                    FontAwesomeIcons.calendar,
                    color: colorGreen,
                    size: 26,
                  ),
                  sufFix: InkWell(
                    onTap: () {
                      tempFromDate = tempFromDate.addDays(15);
                      tempToDate = tempFromDate.addDays(14);
                      updateDates();
                      setState(() {});
                    },
                    child: buildIconContainer(FontAwesomeIcons.plus),
                  ),
                  isReadOnly: true,
                  labelText: "From Date",
                  hintFontWeight: FontWeight.bold,
                  fontWeight: FontWeight.bold,
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: tempFromDate,
                      firstDate: DateTime(tempFromDate.year - 3),
                      lastDate: DateTime(tempFromDate.year + 3),
                    ).then((value) {
                      if (value != null) {
                        tempFromDate = value;
                        updateDates();
                        setState(() {});
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                ThemedTextField(
                  controller: controllerToDate,
                  borderColor: colorGreyBorderD3,
                  preFix: const FaIcon(
                    FontAwesomeIcons.calendar,
                    color: colorGreen,
                    size: 24,
                  ),
                  sufFix: InkWell(
                    onTap: () {
                      tempFromDate = tempFromDate.subtractDays(15);
                      tempToDate = tempFromDate.addDays(14);
                      updateDates();
                      setState(() {});
                    },
                    child: buildIconContainer(FontAwesomeIcons.minus),
                  ),
                  isReadOnly: true,
                  labelText: "To Date",
                  hintFontWeight: FontWeight.bold,
                  fontWeight: FontWeight.bold,
                  onTap: () {
                    print(DateTime(tempToDate.year + 1));
                    showDatePicker(
                      context: context,
                      initialDate: tempToDate,
                      firstDate: tempFromDate,
                      lastDate: DateTime(tempToDate.year + 3),
                    ).then((value) {
                      if (value != null) {
                        tempToDate = value;
                        updateDates();
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
                            updateDates();
                            fromDate = tempFromDate;
                            toDate = tempToDate;
                            setState(() {});

                            if (keyScaffold.currentState != null) {
                              keyScaffold.currentState!.closeEndDrawer();
                            }
                            getData();
                            getAvailableShiftsData();
                            getDataProgressNotes();
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

  void performSearch(String searchString) {
    if (bottomCurrentIndex == 4) {
      notesTempList = searchString.isNotEmpty && searchString.length > 1
          ? notesDataList
              .where((model) =>
                  model.serviceName
                          ?.toLowerCase()
                          .contains(searchString.toLowerCase()) ==
                      true ||
                  model.serviceName
                          ?.toLowerCase()
                          .contains(searchString.toLowerCase()) ==
                      true)
              .toList()
          : List.from(notesDataList);

      setState(() {});
    } else {
      tempList = searchString.isNotEmpty && searchString.length > 1
          ? mainList
              .where((model) =>
                  model.serviceName
                          ?.toLowerCase()
                          .contains(searchString.toLowerCase()) ==
                      true ||
                  model.resName
                          ?.toLowerCase()
                          .contains(searchString.toLowerCase()) ==
                      true)
              .toList()
          : List.from(mainList);
    }

    setState(() {});
  }

  _buildAppBar() {
    return AppBar(
      title: SizedBox(
          height: 40,
          child: Row(children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 50,
                width: 40,
                child: CachedNetworkImage(
                  imageUrl: logoUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: FocusScope(
              node: focusNode,
              child: ThemedTextField(
                borderColor: colorPrimary,
                controller: _controllerSearch,
                // currentFocusNode: focusNode,
                preFix: const Icon(
                  Icons.search,
                  size: 28, // Adjust the size as needed
                  color: Color(0XFFBBBECB), // Adjust the color as needed
                ),
                sufFix: SizedBox(
                  height: 40,
                  width: 40,
                  child: InkWell(
                    onTap: () {
                      _controllerSearch.text = "";
                      performSearch(_controllerSearch.text);
                    },
                    child: Icon(
                      _controllerSearch.text.isNotEmpty ? Icons.cancel : null,
                      size: 20, // Adjust the size as needed
                      color: Color(0XFFBBBECB), // Adjust the color as needed
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
                hintText: "Search...",
                onTap: () {
                  setState(() {
                    lastSelectedRow = -1;
                  });
                  focusNavigatorNode.unfocus();
                  focusNode.requestFocus();
                },
                onChanged: (string) {
                  performSearch(string);
                },
              ),
            )),
          ])),
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
                  getAvailableShiftsData();
                  getDataProgressNotes();
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

  bool showEmptyPage() {
    return (bottomCurrentIndex < 4 && mainList.isEmpty) ||
        (notesTempList.isEmpty && bottomCurrentIndex == 4);
  }

  _buildList({required List<TimeShiteModel> list}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  lastSelectedRow = -1;
                });
                _buildDateDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: spaceHorizontal, vertical: 4),
                child: ThemedText(
                  text:
                      "${bottomCurrentIndex == 1 ? "UnConfirmed\n" : bottomCurrentIndex == 2 ? "TimeSheet\n" : bottomCurrentIndex == 3 ? "Available\n" : bottomCurrentIndex == 4 ? "ProgressNotes\n" : "Confirmed\n"} ${DateFormat("dd-MM-yyyy").format(fromDate)} - ${DateFormat("dd-MM-yyyy").format(toDate)}",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorGreyText,
                ),
              ),
            ),
            Spacer(),
            ToggleButtons(
              isSelected: [_isCalendarView, !_isCalendarView],
              onPressed: (index) {
                setState(() {
                  _isCalendarView = index == 0;
                });
              },
              children: const [
                Icon(Icons.calendar_month),
                Icon(Icons.list),
              ],
            ),
           ]
    ),
           /* InkWell(
              onTap: () {
                setState(() {
                  lastSelectedRow = -1;
                });
                _buildDateDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: spaceHorizontal, vertical: spaceVertical),
                child: const FaIcon(
                  FontAwesomeIcons.calendarDays,
                  size: 22,
                ),
              ),
            ),
          ],
        ),*/
        const Divider(
          thickness: 1,
          height: 1,
          color: colorGreyBorderD3,
        ),
        if (showEmptyPage())
          Expanded(
            child: Container(
              child: Center(
                child: ThemedText(
                  text: "No record found",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: colorGreyText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        if (!showEmptyPage())
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
                        : _isCalendarView  ? WeekViewWidget(maxDay: toDate, minDay: fromDate, bottomCurrentIndex:bottomCurrentIndex,onPressed: (selectedModel){
                      Navigator.of(context).pop();
                      updateSignOff(selectedModel);
                    }, onConfirmOrPickup: (){
                      getData();
                      getAvailableShiftsData();
                      getDataProgressNotes();
                    }) : ListView.builder(
                            itemCount: list.length,
                            primary: true,
                            itemBuilder: (context, index) {
                              TimeShiteModel model = list[index];
                              DateTime? serviceDate =
                                  getDateTimeFromEpochTime(model.serviceDate!);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                margin: const EdgeInsets.only(
                                    top: 8, right: 15, left: 15),
                                color: lastSelectedRow == index
                                    ? Colors.grey.withOpacity(0.2)
                                    : colorWhite,
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
                                                            text: model
                                                                    .isGroupService
                                                                ? "${model.groupName} - "
                                                                : "${model.resName} - ",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .blueAccent,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: model
                                                                .serviceName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .blueAccent,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (bottomCurrentIndex != 3 &&
                                                      model.noteID != 0)
                                                    InkWell(
                                                      onTap: () {
                                                        lastSelectedRow = index;
                                                        setState(() {});
                                                        showProgressNotes(
                                                            model);
                                                      },
                                                      child: const FaIcon(
                                                        FontAwesomeIcons
                                                            .calendarDays,
                                                        size: 22,
                                                      ),
                                                    ),
                                                  const SizedBox(
                                                      width:
                                                          spaceHorizontal / 2),
                                                  if (bottomCurrentIndex != 3)
                                                    InkWell(
                                                      onTap: () {
                                                        lastSelectedRow = index;
                                                        setState(() {});
                                                        showCareWrokerList(
                                                            model);
                                                      },
                                                      child: Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.black,
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            child: const Icon(
                                                              CupertinoIcons.person_crop_circle,
                                                              color: Colors.white,
                                                              size: 28,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Container(
                                                              padding: const EdgeInsets.all(1),
                                                              decoration: BoxDecoration(
                                                                color: colorGreen,
                                                                borderRadius: BorderRadius.circular(6),
                                                              ),
                                                              constraints: BoxConstraints(
                                                                minWidth: 10,
                                                                minHeight: 10,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  model.CWNumber.toString(),
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 16,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
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
                                                        updateSelection(index);
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
                                                                    width: 5),
                                                                const FaIcon(
                                                                  FontAwesomeIcons
                                                                      .calendarDays,
                                                                  color:
                                                                      colorGreen,
                                                                  size: 18,
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
                                                                if (getDateTimeFromEpochTime(
                                                                        model
                                                                            .serviceDate!) !=
                                                                    null)
                                                                  Text(
                                                                    formatServiceDate(
                                                                        model
                                                                            .serviceDate),
                                                                    style:
                                                                        const TextStyle(
                                                                      color:
                                                                          colorGreyText,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                const SizedBox(
                                                                    width: 5),
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
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const SizedBox(
                                                                    width: 5),
                                                                const Icon(
                                                                  Icons
                                                                      .timelapse,
                                                                  color:
                                                                      colorGreen,
                                                                  size: 18,
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
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
                                                                    width: 5),
                                                                Container(
                                                                  width: 1,
                                                                  height: 25,
                                                                  color:
                                                                      colorGreyBorderD3,
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
                                                              ],
                                                            ),
                                                          ),
                                                          WidgetSpan(
                                                            child: Row(
                                                              children: [
                                                                const SizedBox(
                                                                    width: 5),
                                                                const Icon(
                                                                  Icons
                                                                      .access_time_outlined,
                                                                  color:
                                                                      colorGreen,
                                                                  size: 18,
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
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
                                                                    width: 5),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  if ((bottomCurrentIndex == 0 ||
                                                          bottomCurrentIndex ==
                                                              2) &&
                                                      model.tSConfirm ==
                                                          false &&
                                                      serviceDate != null &&
                                                      serviceDate.isToday)
                                                    InkWell(
                                                      onTap: model.locationName !=
                                                                  null &&
                                                              model
                                                                  .locationName!
                                                                  .isNotEmpty
                                                          ? null
                                                          : () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          boxBorderRadius),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            spaceHorizontal,
                                                                        vertical:
                                                                            spaceVertical),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            ThemedText(
                                                                              text: "Shift Logon",
                                                                              color: colorBlack,
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                spaceVertical),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: ThemedText(
                                                                                text: "Logon to shift?",
                                                                                color: colorBlack,
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 20),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                spaceVertical),
                                                                        const SizedBox(
                                                                            height:
                                                                                spaceVertical),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: ThemedButton(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                title: "Cancel",
                                                                                fontSize: 18,
                                                                                padding: EdgeInsets.zero,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: spaceHorizontal / 2,
                                                                            ),
                                                                            Expanded(
                                                                              child: ThemedButton(
                                                                                onTap: () async {
                                                                                  Navigator.pop(context);
                                                                                  String? address = await getAddress();
                                                                                  if (address != null) {
                                                                                    print("ADDRESS : $address");
                                                                                    saveLocationTime(address, (model.servicescheduleemployeeID ?? 0).toString());
                                                                                  }
                                                                                },
                                                                                title: "Ok",
                                                                                fontSize: 18,
                                                                                padding: EdgeInsets.zero,
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
                                                        color: model.locationName !=
                                                                    null &&
                                                                model
                                                                    .locationName!
                                                                    .isNotEmpty
                                                            ? colorGreen
                                                            : colorRed,
                                                        size: 22,
                                                      ),
                                                    ),
                                                  if ((bottomCurrentIndex ==
                                                              0 ||
                                                          bottomCurrentIndex ==
                                                              2) &&
                                                      serviceDate != null &&
                                                      serviceDate.isToday)
                                                    const SizedBox(
                                                        width: spaceHorizontal /
                                                            2),
                                                  if ((bottomCurrentIndex ==
                                                              0 ||
                                                          bottomCurrentIndex ==
                                                              2) &&
                                                      (model.isGroupService ||
                                                          model.noteID != 0))
                                                    model.isGroupService
                                                        ? InkWell(
                                                            onTap: () {
                                                              lastSelectedRow =
                                                                  index;
                                                              setState(() {});
                                                              selectedModel =
                                                                  model;
                                                              //  getGroupServices();
                                                              showGroupList(
                                                                  model);

                                                              /*  setState(() {
                                                                    bottomCurrentIndex =
                                                                        5;
                                                                  });*/
                                                            },
                                                            child: model.noteID ==
                                                                    0
                                                                ? const FaIcon(
                                                                    FontAwesomeIcons
                                                                        .userGroup,
                                                                    size: 18,
                                                                  )
                                                                : const FaIcon(
                                                                    // FontAwesomeIcons.notesMedical,
                                                                    Icons
                                                                        .note_alt_outlined,
                                                                    color: Colors
                                                                        .green,
                                                                    size: 22,
                                                                  ),
                                                          )
                                                        : InkWell(
                                                            onTap: () {
                                                              print(
                                                                  "progressnote 1");
                                                              lastSelectedRow =
                                                                  index;
                                                              setState(() {});
                                                              if (!model
                                                                  .isGroupService) {
                                                                Navigator.push(
                                                                  keyScaffold
                                                                      .currentContext!,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ProgressNoteDetails(
                                                                      userId:
                                                                          model.empID ??
                                                                              0,
                                                                      noteId:
                                                                          model.noteID ??
                                                                              0,
                                                                      clientId:
                                                                          model.rESID ??
                                                                              0,
                                                                      servicescheduleemployeeID:
                                                                          model.servicescheduleemployeeID ??
                                                                              0,
                                                                      serviceShceduleClientID:
                                                                          model.serviceShceduleClientID ??
                                                                              0,
                                                                      serviceName:
                                                                          model.serviceName ??
                                                                              "",
                                                                      clientName:
                                                                          "${model.resName} - ${model.rESID.toString().padLeft(5, "0")}",
                                                                      noteWriter:
                                                                          "",
                                                                      serviceDate: getDateTimeFromEpochTime(model.serviceDate ??
                                                                              "") ??
                                                                          DateTime
                                                                              .now(),
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                selectedModel =
                                                                    model;
                                                                //getGroupServices();
                                                                /* setState(
                                                                        () {
                                                                      bottomCurrentIndex = 5;
                                                                    });*/
                                                                showGroupList(
                                                                    model);
                                                              }
                                                            },
                                                            child: const FaIcon(
                                                              // FontAwesomeIcons.notesMedical,
                                                              Icons
                                                                  .note_alt_outlined,
                                                              color:
                                                                  Colors.green,
                                                              size: 22,
                                                            ),
                                                          ),
                                                  const SizedBox(
                                                      width:
                                                          spaceHorizontal / 2),
                                                  if (model.dsnId != 0 &&
                                                      bottomCurrentIndex != 3)
                                                    InkWell(
                                                      onTap: () {
                                                        lastSelectedRow = index;
                                                        setState(() {});
                                                        showDNSList(model);
                                                      },
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .lifeRing,
                                                        size: 22,
                                                        color: (model.isDNSComplete == true ) ? Colors.green : Colors.red,
                                                      ),
                                                    ),
                                                  if (model.dsnId != 0)
                                                    const SizedBox(
                                                        width: spaceHorizontal /
                                                            2),
                                                  if (bottomCurrentIndex == 2 &&
                                                      model.tSConfirm == true)
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: model.locationName ==
                                                                  "" ||
                                                              model.logOffLocationName ==
                                                                  ""
                                                          ? colorRed
                                                          : colorGreen,
                                                      size: 22,
                                                    ),
                                                  if (bottomCurrentIndex == 2)
                                                    const SizedBox(
                                                        width: spaceHorizontal /
                                                            2),
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
                                            setState(() {
                                              lastSelectedRow = index;
                                            });
                                            selectedModel = model;
                                            Navigator.push(
                                              keyScaffold.currentContext!,
                                              MaterialPageRoute(
                                                builder: (context) => model
                                                            .tSConfirm ==
                                                        false
                                                    ? TimeSheetDetail(
                                                        model: model,
                                                        indexSelectedFrom:
                                                            bottomCurrentIndex,
                                                      )
                                                    : TimeSheetForm(
                                                        model: model,
                                                        indexSelectedFrom:
                                                            bottomCurrentIndex),
                                              ),
                                            ).then((value) {
                                              if (value != null) {
                                                if (value == 0) {
                                                  getData();
                                                  getAvailableShiftsData();
                                                  getDataProgressNotes();
                                                } else if (value == 1) {
                                                  showGroupList(model);
                                                }
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
                                    if (selectedExpandedIndex == index)
                                      Row(
                                        children: [
                                          const SizedBox(width: 7),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 7),
                                                buildTextRowWithAlphaIcon(
                                                    "S",
                                                    model.shiftComments !=
                                                                null &&
                                                            model.shiftComments!
                                                                .isNotEmpty
                                                        ? model.shiftComments!
                                                        : "No shift comments provided."),
                                                const SizedBox(height: 7),
                                                buildTextRowWithAlphaIcon(
                                                    "C",
                                                    model.comments != null &&
                                                            model.comments!
                                                                .isNotEmpty
                                                        ? model.comments!
                                                        : "No client comments provided."),
                                                const SizedBox(height: 7),
                                                InkWell(
                                                    onTap: () {
                                                      launchUrlMethod(
                                                          "http://maps.google.com/?q=${model.resAddress}");
                                                    },
                                                    child: buildRowIconAndText(
                                                        FontAwesomeIcons
                                                            .locationDot,
                                                        model.resAddress ??
                                                            "")),
                                                const SizedBox(height: 7),
                                                InkWell(
                                                    onTap: () {
                                                      launchUrlMethod(
                                                          "tel:${model.resHomePhone}");
                                                    },
                                                    child: buildRowIconAndText(
                                                        FontAwesomeIcons
                                                            .phoneVolume,
                                                        model.resHomePhone ??
                                                            "")),
                                                const SizedBox(height: 7),
                                                InkWell(
                                                    onTap: () {
                                                      launchUrlMethod(
                                                          "tel:${model.resMobilePhone}");
                                                    },
                                                    child: buildRowIconAndText(
                                                        FontAwesomeIcons
                                                            .mobileAlt,
                                                        model.resMobilePhone ??
                                                            "")),
                                                const SizedBox(height: 7),
                                                InkWell(
                                                    onTap: () {
                                                      showClientDocument(model);
                                                    },
                                                    child: buildRowIconAndText(
                                                        FontAwesomeIcons
                                                            .fileLines,
                                                        "View Client Documents")),
                                                const SizedBox(height: 7),
                                                InkWell(
                                                    onTap: () {
                                                      print(
                                                          "model.clientID : ${model.rESID}");
                                                      Navigator.of(keyScaffold
                                                              .currentContext!)
                                                          .push(
                                                              MaterialPageRoute(
                                                        builder: (context) =>
                                                            ClientInfo(
                                                          clientId:
                                                              (model.rESID ?? 0)
                                                                  .toString(),
                                                        ),
                                                      ));
                                                    },
                                                    child: buildRowIconAndText(
                                                        FontAwesomeIcons
                                                            .circleInfo,
                                                        "View Client Info")),
                                                const SizedBox(height: 7),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
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

  Widget buildRowIconAndText(IconData icon, String text) {
    return Row(
      children: [
        SizedBox(
          width: 25,
          height: 25,
          child: Center(
            child: FaIcon(
              icon,
              color: colorGreen,
            ),
          ),
        ),
        const SizedBox(
          width: spaceHorizontal,
        ),
        Expanded(
          child: ThemedText(
            text: text,
          ),
        ),
      ],
    );
  }

  Future<void> updateSignOff(TimeShiteModel model) async {
    String? address = await getAddress();
    if (address != null) {
      print("ADDRESS : $address");
      saveLocationTime(address, (model.servicescheduleemployeeID ?? 0).toString());
    }
  }

  showGroupList(TimeShiteModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GroupNoteList(selectedModel: model)),
    );
  }

  showDNSList(TimeShiteModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DNSList(
            userId: model.empID ?? 0,
            rosterID: model.serviceShceduleClientID ?? 0),
      ),
    );
  }

  showProgressNotes(TimeShiteModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressNoteListByNoteId(
          userId: model.empID ?? 0,
          noteID: model.noteID ?? 0,
          rosterID: model.rosterID ?? 0,
        ),
      ),
    );
  }

  showClientDocument(TimeShiteModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDocument(
          id: (model.clientID ?? 0).toString(),
          resId: (model.rESID ?? 0).toString(),
           clientName: model.resName ?? "",
        ),
      ),
    );
  }

  showCareWrokerList(TimeShiteModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CareWorkerList(
          userId: model.empID ?? 0,
          rosterID: model.rosterID ?? 0,
          model: model,
        ),
      ),
    );
  }

  _buildProgressNoteList() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: notesTempList.length,
                    primary: true,
                    itemBuilder: (context, index) {
                      ProgressNoteModel model = notesTempList[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        margin:
                            const EdgeInsets.only(top: 8, right: 15, left: 15),
                        color: lastSelectedRow == index
                            ? Colors.grey.withOpacity(0.2)
                            : colorWhite,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        // Aligns children to the top
                                        children: [
                                          if (model.tSid != 0)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: colorGreen,
                                              size: 22,
                                            ),
                                          if (model.tSid != 0)
                                            const SizedBox(
                                              width: 10,
                                              height: 10,
                                            ),
                                          Expanded(
                                            child: ThemedText(
                                              text: "${model.serviceName}",
                                              fontSize: 15,
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ThemedText(
                                                text:
                                                    "Note Writer: ${model.createdByName}",
                                                color: colorGreyLiteText,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          ),
                                        ],
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
                                              updateSelection(index);
                                              setState(() {});
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
                                                      Text(
                                                        // model.serviceDate!,
                                                        formatServiceDate(
                                                            model.noteDate),
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Container(
                                                        width: 1,
                                                        height: 20,
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
                                                      const SizedBox(width: 5),
                                                      ThemedText(
                                                          text: model.subject!,
                                                          color: colorGreyText,
                                                          fontSize: 14),
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
                                    print("Tap on progress");
                                    lastSelectedRow = index;
                                    setState(() {});
                                    showNoteDetail(model);
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
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 7,
                                    height: 30,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    WidgetSpan(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .access_time_outlined,
                                                            color: colorGreen,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            "${model.timeFrom ?? ""} - ${model.timeTo ?? ""}",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  colorGreyText,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Container(
                                                            width: 1,
                                                            height: 20,
                                                            color:
                                                                colorGreyBorderD3,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                        ],
                                                      ),
                                                    ),
                                                    WidgetSpan(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                              width: 5),
                                                          const Icon(
                                                            Icons.timelapse,
                                                            color: colorGreen,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            "${model.totalHours ?? ""}hrs",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  colorGreyText,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Container(
                                                            width: 1,
                                                            height: 20,
                                                            color:
                                                                colorGreyBorderD3,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildTextRowWithAlphaIcon(
                                                  "D",
                                                  model.description?.trim() ??
                                                      "No description"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildTextRowWithAlphaIcon(
                                                  "A",
                                                  model.assessmentComment
                                                          ?.trim() ??
                                                      "No assessment comment"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
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

  Widget buildIconTextRow(IconData iconData, String text) {
    return Row(
      children: [
        Icon(
          iconData,
          color: colorGreen,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ThemedText(
            text: text,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  updateSelection(int index) {
    if (selectedExpandedIndex == index) {
      selectedExpandedIndex = -1;
    } else {
      selectedExpandedIndex = index;
    }
  }

  showNoteDetail(ProgressNoteModel model) {
    if (keyScaffold.currentContext != null) {
      Navigator.of(keyScaffold.currentContext!)
          .push(MaterialPageRoute(
        builder: (context) => ProgressNoteDetails(
          userId: model.serviceScheduleEmpID ?? 0,
          clientId: model.clientID ?? 0,
          noteId: model.noteID ?? 0,
          serviceShceduleClientID: model.servicescheduleCLientID ?? 0,
          servicescheduleemployeeID: model.serviceScheduleEmpID ?? 0,
          serviceName: model.serviceName ?? "",
          clientName: model.clientName,
          noteWriter: model.createdByName ?? "",
          serviceDate: getDateTimeFromEpochTime(model.serviceDate ?? "") ??
              DateTime.now(),
        ),
      ))
          .then((value) {
        if (value != null && value) {
          print("Check all value");
          getDataProgressNotes();
        }
      });
    }
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

      Placemark placeMark = addressList[0];
      String address = "";
      void appendIfNotEmpty(String value) {
        if (value.trim().isNotEmpty) {
          address += "$value, ";
        }
      }

      appendIfNotEmpty(placeMark.name ?? "");
      appendIfNotEmpty(placeMark.subLocality ?? "");
      appendIfNotEmpty(placeMark.locality ?? "");
      appendIfNotEmpty(placeMark.administrativeArea ?? "");
      appendIfNotEmpty(placeMark.postalCode ?? "");
      appendIfNotEmpty(placeMark.country ?? "");

      address = address.trim();
      if (address.isNotEmpty) {
        address = address.substring(0, address.length - 1);
      }
      return address;
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
      'auth_code': (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'servicescheduleemployeeID': sSEID,
      'Location': address,
      'SaveTimesheet': "false",
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endSaveLocationTime, params: params).toString(),
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            if (json.decode(response)["status"] == 1) {
              showSnackBarWithText(keyScaffold.currentState, "Success",
                  color: colorGreen);
              getData();
              getAvailableShiftsData();
              getDataProgressNotes();
              // Navigator.pop(context);
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("saveLocationTime ERROR : $e");
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
    if (index < 4) {
      return _buildList(list: tempList);
    } else {
      return _buildProgressNoteList(); /*ProgressNote(
        key: keyProgressNoteTab,
      );*/
    }
  }

  _buildBottomNavBarItem(
      {required int index, required String label, required Widget icons}) {
    return InkWell(
      onTap: () {
        setState(() {
          lastSelectedRow = -1;
          if (_keyNavigator.currentState != null) {
            while (_keyNavigator.currentState!.canPop()) {
              _keyNavigator.currentState!.pop();
            }
          }
          switch (index) {
            case 1:
              mainList = unConfirmedDataList;
              bottomCurrentIndex = index;
              break;
            case 2:
              mainList = timeSheetDataList;
              bottomCurrentIndex = index;
              break;
            case 3:
              print(availableDataList.length);
              mainList = availableDataList;
              bottomCurrentIndex = index;
              break;
            case 4:
              print(notesDataList.length);
              bottomCurrentIndex = index;
              break;
            default:
              mainList = confirmedDataList;
              bottomCurrentIndex = index;
              break;
          }
          _controllerSearch.text = "";
          performSearch("");
          tempList.clear();
          tempList.addAll(mainList);
          if(_events.isNotEmpty) {
            CalendarControllerProvider
                .of(context)
                .controller
                .removeAll(_events);
          }
          for (int k = 0; k < tempList.length; k++) {
            var model = tempList[k];
            var arr = model.shift?.split("-") ?? [];
            var sT = arr[0].split(":") ?? [];
            var eT = arr[1].split(":") ?? [];
            var startHour = sT[0];
            var startMin = sT[1];
            var endHour = eT[0];
            var endMin = eT[1];
            var dt = getDateTimeFromEpochTime(model.serviceDate ?? "") ??
                DateTime.now();

            var event = CalendarEventData(
                date: dt,
                title: model.isGroupService
                    ? "${model.groupName}"
                    : "${model.resName}",
                description: model.serviceName,
                startTime: DateTime(dt.year, dt.month, dt.day,
                    int.parse(startHour), int.parse(startMin)),
                endTime: DateTime(dt.year, dt.month, dt.day, int.parse(endHour),
                    int.parse(endMin)),
                event: model,
            color: (model.confirmCW == true && model.empID != 0 && model.tSConfirm == false)  ? colorGreen : colorBlue );
            _events.add(event);
            //EventController()..addAll(_events);
            CalendarControllerProvider.of(context).controller.add(event);
          }
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
        return notesDataList.length;
      default:
        return confirmedDataList.length;
    }
  }
}
