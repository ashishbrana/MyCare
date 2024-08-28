import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rcare_2/screen/ClientHome/ClientProfileScreen.dart';
import 'package:rcare_2/screen/ClientHome/ServiceForm.dart';
import 'package:rcare_2/screen/ClientHome/model/ClientFundingDetail.dart';
import 'package:rcare_2/screen/CustomView/VersionUpdateDialogWidget.dart';
import 'package:rcare_2/screen/Login/Login.dart';
import 'package:rcare_2/screen/home/notes/ProgressNotes.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../chart/PieChartContent.dart';
import '../../chart/chart_container.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Preferences.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';
import '../CustomView/CustomDateDialog.dart';
import '../home/models/ConfirmedResponseModel.dart';
import 'ClientFundingCodeList.dart';

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

  Future<bool> isDayPassed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastCalled = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('lastCalled') ?? 0);
    DateTime now = DateTime.now();
    // Check if a day has passed
    if (now.difference(lastCalled).inDays >= 1) {
      // Update the last called time to today
      await prefs.setInt('lastCalled', now.millisecondsSinceEpoch);
      return true;
    }
    return false;
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      print(_packageInfo.version);
      _packageInfo = info;
    });
  }

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
  List<ClientFundingDetail> fundingList = [];
  List<ClientFundingDetail> notesTempList = [];
  List<TimeShiteModel> mainList = [];
  List<TimeShiteModel> tempList = [];

  TimeShiteModel? selectedModel;

  final TextEditingController _controllerSearch = TextEditingController();
  FocusScopeNode focusNode = FocusScopeNode();
  FocusScopeNode focusNavigatorNode = FocusScopeNode();

  GlobalKey<ProgressNoteState> keyProgressNoteTab =
      GlobalKey<ProgressNoteState>();

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
    getFundingList();
    // Check if a day has passed
   checkLatestVersion();

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
    Map<String, dynamic> params = {
      'devicetype': deviceType
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(latestMobileAppVersion, params: params).toString(),
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
            var jres = json.decode(response);
            if (jres["status"] == 1) {
              var version =  jres["message"].toString();
              if (version != appVersion){
              /*  showVersionUpdateDialog(onYesTap: () {
                  Navigator.pop(context);
                });*/
                _showVersionUpdateDialog(context);
              }
            }
            setState(() {});
          } else {
            showSnackBarWithText(keyScaffold.currentState, stringSomeThingWentWrong);
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
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType':
          (await Preferences().getPrefInt(Preferences.prefAccountType))
              .toString(),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'fromdate': fromDate.shortDate(),
      'todate': toDate.shortDate(),
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
          print("endTimeSheets $response");
          if (response != null && response != "" && response.length > 100) {
            List jResponse = json.decode(response);
            print("jResponse $jResponse");
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
                    model.tSConfirm == true) {
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
                  // type = "unconfirmed";
                  unConfirmedDataList.add(model);
                } else if ((model.status1 == 4 || model.status1 == 0) &&
                    model.empID == 0) {}
              } else if (accType == 3) {
                if (model.confirmCW == true &&
                    model.empID != 0 &&
                    model.tSConfirm == false) {
                  // type = "confirmed";
                  confirmedDataList.add(model);
                } else if (model.empID != 0 && model.timesheetStatus == true) {
                  timeSheetDataList.add(model);
                } else if (model.status1 == 5 ||
                    model.status1 == 4 ||
                    model.status1 == 0) {
                  // type = "unconfirmed";
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
            removeOverlay();
            setState(() {});
            //}
          } else {
            tempList.clear();
            removeOverlay();
            setState(() {});
            removeOverlay();
            confirmedDataList.clear();
            unConfirmedDataList.clear();
            timeSheetDataList.clear();
            setState(() {});
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
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
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
    };
    print("getFundingList : $params");
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

            List jResponse = json.decode(response);
            print("getFundingList $jResponse");
            fundingList =
                jResponse.map((e) => ClientFundingDetail.fromJson(e)).toList();
            notesTempList.clear();
            notesTempList.addAll(fundingList);
            ClientFundingDetail fundingDetail = ClientFundingDetail();
            fundingDetail.balanceAmount = 0;
            fundingDetail.utilizeTotal = 0;
            fundingDetail.openBalance = 0;
            fundingDetail.budget = 0;
            fundingDetail.fundingServiceName = "Total Funding";
            fundingDetail.clientfundingid = -1;
            print("====================");
            notesTempList.forEach((detail) {
              print(detail.balanceAmount!);
              fundingDetail.balanceAmount = (fundingDetail.balanceAmount ?? 0) + (detail.balanceAmount ?? 0);
              fundingDetail.utilizeTotal = (fundingDetail.utilizeTotal ?? 0) + (detail.utilizeTotal ?? 0);
              fundingDetail.openBalance = (fundingDetail.openBalance ?? 0) + (detail.openBalance ?? 0);
              fundingDetail.budget = (fundingDetail.budget ?? 0) + (detail.budget ?? 0);
            });
            notesTempList.insert(0, fundingDetail);
            fundingList.insert(0, fundingDetail);
            print("NOTES : ${notesTempList.length}");

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
    var pref = Preferences();
    pref.reset();
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
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
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
                                builder: (context) =>
                                    const ClientProfileScreen(),
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
                Expanded(child:

                ThemedText(
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
    setState(() {});
    showDialog(
      context: context,
      builder: (context) {
        return CustomDateDialog(
          fromDate: fromDate,
          toDate: toDate,
          onApply: (DateTime newFromDate, DateTime newToDate) {
            print(newFromDate);
            print(newToDate);
            fromDate = newFromDate;
            toDate = newToDate;
            setState(() {});
            if (keyScaffold.currentState != null) {
              keyScaffold.currentState!.closeEndDrawer();
            }
            getData();
            getFundingList();
          },
        );
      },
    );
  }

  void performSearch(String searchString) {
    final trimmedString = searchString.trim();

    if (bottomCurrentIndex == 4) {
      notesTempList = trimmedString.isNotEmpty
          ? fundingList
              .where((model) =>
                  (model.fundingServiceName
                          ?.toLowerCase()
                          .contains(trimmedString.toLowerCase()) ??
                      false) ||
                  (model.sourceType
                          ?.toLowerCase()
                          .contains(trimmedString.toLowerCase()) ??
                      false))
              .toList()
          : List.from(fundingList);
    } else {
      tempList = trimmedString.isNotEmpty && trimmedString.length > 1
          ? mainList
              .where((model) =>
                  (model.serviceName
                          ?.toLowerCase()
                          .contains(trimmedString.toLowerCase()) ??
                      false) ||
                  (model.resName
                          ?.toLowerCase()
                          .contains(trimmedString.toLowerCase()) ??
                      false) ||
                      (model.emplName.toString()
                        .toLowerCase()
                        .contains(trimmedString.toLowerCase()) ??
                        false)
      )
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
              child: SizedBox(
                height: 50,
                width: 40,
                child: CachedNetworkImage(
                  imageUrl: logoUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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

  String getStatusText() {
    String title = "";
    switch (bottomCurrentIndex) {
      case 0:
        title = "Confirmed";
      case 1:
        title = "UnConfirmed";
      case 2:
        title = "Completed";
      case 4:
        title = "Funding";
      default:
        title = "Confirmed";
    }
    if (bottomCurrentIndex != 4) {
      return "$title : ${DateFormat("dd-MM-yyyy").format(fromDate)} - ${DateFormat("dd-MM-yyyy").format(toDate)}";
    } else {
      return title;
    }
  }

  _buildList({required List<TimeShiteModel> list}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: bottomCurrentIndex != 4
              ? () {
                  _buildDateDialog();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: spaceHorizontal, vertical: spaceVertical),
            child: ThemedText(
              text: getStatusText(),
              fontSize: 16,
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
        if ((bottomCurrentIndex < 3 &&  mainList.isEmpty))
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
                        : ListView.builder(
                            itemCount: list.length,
                            primary: true,
                            itemBuilder: (context, index) {
                              TimeShiteModel model = list[index];
                              DateTime? serviceDate =
                                  getDateTimeFromEpochTime(model.serviceDate!);
                              return Container(
                                // Set your desired background color
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
                                                            text:
                                                                model.isGroupService ? "${model.groupName} - ${model.serviceName}" : "${model.serviceName}",
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
                                                          TextSpan(
                                                            text:
                                                                " - ${model.fundingsourcename}",
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
                                                  )
                                                ],
                                              ),
                                              if (bottomCurrentIndex != 1)
                                                const SizedBox(height: 8),
                                              if (bottomCurrentIndex != 1)
                                                buildCareWorkerRow(
                                                    model.emplName ?? ""),
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
                                                          buildIconAndTitleRow(
                                                              formatServiceDate(
                                                                  model
                                                                      .serviceDate),
                                                              Icons
                                                                  .calendar_month_outlined,
                                                              true),
                                                          buildIconAndTitleRow(
                                                              "${model.totalHours}hrs",
                                                              Icons
                                                                  .access_time_outlined,
                                                              true),
                                                          buildIconAndTitleRow(
                                                              model.shift ?? "",
                                                              Icons
                                                                  .timer_outlined,
                                                              false),
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
                                            setState(() {
                                              lastSelectedRow = index;
                                            });
                                            selectedModel = model;
                                            Navigator.push(
                                              keyScaffold.currentContext!,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ServiceForm(
                                                        model: model,
                                                        indexSelectedFrom:
                                                            bottomCurrentIndex),
                                              ),
                                            ).then((value) {
                                              print("check1267");
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 7),
                                          buildTextRowWithAlphaIcon("S", model.shiftComments !=
                                              null &&
                                              model.shiftComments!
                                                  .isNotEmpty
                                              ? model.shiftComments!
                                              : "No shift comments provided."),
                                          const SizedBox(height: 7),
                                          buildTextRowWithAlphaIcon("C",  model.comments !=
                                              null &&
                                              model.comments!
                                                  .isNotEmpty
                                              ? model.comments!
                                              : "No client comments provided."),
                                          const SizedBox(height: 7),
                                        ],
                                      ),
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

  Widget buildCareWorkerRow(String employeeName) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Care Worker:",
                  style: TextStyle(
                    color: colorGreyLiteText,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: " $employeeName",
                  style: const TextStyle(
                    color: colorGreyText,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  WidgetSpan buildIconAndTitleRow(
      String title, IconData iconData, bool showDivider) {
    return WidgetSpan(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 5),
          Icon(
            iconData,
            color: colorGreen,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              color: colorGreyText,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 5),
          if (showDivider)
            Container(
              width: 1,
              height: 25,
              color: colorGreyBorderD3,
            ),
        ],
      ),
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
                                      Row(children: [
                                        ThemedText(
                                          text: "${model.fundingServiceName}",
                                          fontSize: 16,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ThemedText(
                                          text: " ${model.sourceType ?? ""}",
                                          fontSize: 16,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ]),
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
                                            child: const SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Icon(
                                                Icons.arrow_downward_rounded,
                                                color: colorGreen,
                                              ),
                                            ),
                                          ),
                                          if (model.clientfundingid! > 0)
                                          Expanded(
                                            child: ThemedRichText(
                                              spanList: [
                                                WidgetSpan(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color: colorGreen,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        formatServiceDate(
                                                            model.startDate),
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color: colorGreen,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        formatServiceDate(
                                                            model.endDate),
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
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
                                if (model.clientfundingid! > 0)
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      lastSelectedRow = index;
                                    });
                                    final authCode = await Preferences()
                                        .getPrefString(
                                            Preferences.prefAuthCode);
                                    final userId = (await Preferences()
                                            .getPrefInt(Preferences.prefUserID))
                                        .toString();

                                    Navigator.of(keyScaffold.currentContext!)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          ClientFundingCodeList(
                                        authCode: authCode,
                                        userid: userId,
                                        fundingID: model.clientfundingid ?? 0,
                                        fromDate: fromDate,
                                        toDate: toDate,
                                      ),
                                    ));
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
                                  createBalanceRow(
                                      title: "Budget",
                                      openBalance:
                                          "\$${model.budget?.toDouble().toStringAsFixed(2) ?? "0.00"}",
                                      boxColor: Colors.white),
                                  const SizedBox(height: 7),
                                  createBalanceRow(
                                      title: "Open Balance",
                                      openBalance:
                                          "\$${model.openBalance?.toDouble().toStringAsFixed(2) ?? "0.00"}",
                                      boxColor: Colors.white),
                                  const SizedBox(height: 7),
                                  createBalanceRow(
                                      title: "Utilised",
                                      openBalance:
                                          "\$${model.utilizeTotal?.toDouble().toStringAsFixed(2) ?? "0.00"}",
                                      boxColor: Colors.red),
                                  const SizedBox(height: 7),
                                  createBalanceRow(
                                      title: "Balance",
                                      openBalance:
                                          "\$${model.balanceAmount?.toDouble().toStringAsFixed(2) ?? "0.00"}",
                                      boxColor: Colors.green),
                                  const SizedBox(height: 7),
                                  ChartContainer(
                                      title: '',
                                      color: Colors.white,
                                      chart: PieChartContent(
                                          pieChartSectionData:
                                              model.getSectionData(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width))),
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

  Widget createBalanceRow(
      {required String title,
      required String openBalance,
      required Color boxColor}) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Container(
          width: 10.0,
          height: 10.0,
          color: boxColor,
        ),
        const SizedBox(width: 30),
        Expanded(
          child: ThemedText(
            text: "$title:",
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: ThemedText(
            text: openBalance,
            fontSize: 14,
            fontWeight: FontWeight.bold,
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

  void showAddNew() {
    Navigator.push(
      keyScaffold.currentContext!,
      MaterialPageRoute(
        builder: (context) =>
            ServiceForm(model: TimeShiteModel(), indexSelectedFrom: -1),
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
          lastSelectedRow = -1;
          selectedExpandedIndex = -1;
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
