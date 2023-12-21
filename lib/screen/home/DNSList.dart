import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/HomeScreen.dart';
import 'package:rcare_2/screen/home/models/DSNListModel.dart';
import 'package:rcare_2/screen/home/notes/DNSNotesDetails.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../Network/API.dart';
import '../../network/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import 'TimeSheetDetail.dart';
import 'models/CareWorkerModel.dart';

class DNSList extends StatefulWidget {
  final int userId;
  final int rosterID;

  const DNSList({super.key, required this.userId, required this.rosterID});

  @override
  State<DNSList> createState() => _DNSListState();
}

class _DNSListState extends State<DNSList> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  List<DSNListModel> dataList = [];

  int selectedExpandedIndex = -1;
  var userid = Preferences().getPrefInt(Preferences.prefUserID);
  @override
  void initState() {
    super.initState();
    print("INITSTATE");
    getData();
  }

  getData() async {
    // userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType':
          (await Preferences().getPrefInt(Preferences.prefAccountType))
              .toString(),
      'rosterid': /*"27339",*/ widget.rosterID.toString(),
      'fromdate': DateFormat("yyyy/MM/dd").format(fromDate),
      'todate': DateFormat("yyyy/MM/dd").format(toDate),
      'userid': widget.userId.toString(),
      'isCareworkerSpecific': "1",
    };
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endDNSList, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponse $jResponse");
            dataList = jResponse.map((e) => DSNListModel.fromJson(e)).toList();
            print("models.length : ${dataList.length}");

            setState(() {});
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          showSnackBarWithText(
              _keyScaffold.currentState, stringDataNotAvailable);
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: colorLiteBlueBackGround,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
            decoration: BoxDecoration(
              color: colorGreen,
              borderRadius: boxBorderRadius,
            ),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(3),
            child: ThemedText(
              text: "Daily Support Needs",
              color: colorWhite,
              fontSize: 12,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              primary: true,
              itemBuilder: (context, index) {
                DSNListModel model = dataList[index];

                return Container(
                  margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: boxBorderRadius,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
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
                                                              "${model.sscname} ",
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                colorGreyText,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              "\nNote Writer: ${model.notewriter}",
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                colorGreyLiteText,
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      /* const SizedBox(width: 5),
                                                      const FaIcon(
                                                        FontAwesomeIcons
                                                            .calendarDays,
                                                        color: colorGreen,
                                                        size: 14,
                                                      ),*/
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          "${model.taskname}",
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                colorGreyText,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        "${model.taskcompleted == false ? "Not Completed" : "Completed"}",
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF337ab7),
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
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
                                    ],
                                  ),
                                ),
                                if ( (getDateTimeFromEpochTime(model.ssdate!) !=
                                        null &&
                                    getDateTimeFromEpochTime(model.ssdate!)!
                                        .isBefore(DateTime.now())) && (widget.userId == model.notewriterid || model.notewriterid == 0))
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        keyScaffold.currentContext!,
                                        MaterialPageRoute(
                                          builder: (context) => DNSNotesDetails(
                                            dsnListModel: model,
                                            userId: widget.userId,
                                            serviceShceduleClientID:
                                                widget.rosterID,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value != null && value) {
                                          getData();
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
                              expandedHeight: 110,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    ThemedRichText(
                                      spanList: [
                                        WidgetSpan(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(
                                                  width: spaceHorizontal / 2),
                                              const SizedBox(
                                                width: 25,
                                                height: 25,
                                                child: Center(
                                                  child: FaIcon(
                                                    FontAwesomeIcons.clock,
                                                    color: colorGreen,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal / 2),
                                              ThemedText(
                                                text: "Time: ",
                                                color: colorBlack,
                                                fontSize: 12,
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal),
                                              ThemedText(
                                                text:
                                                    "${model.timefrom ?? ""} - ${model.timeto ?? ""}",
                                                color: colorBlack,
                                                fontSize: 12,
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal),
                                              Container(
                                                  height: 20,
                                                  width: 1,
                                                  color: colorDivider),
                                            ],
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(
                                                  width: spaceHorizontal / 2),
                                              const SizedBox(
                                                width: 25,
                                                height: 25,
                                                child: Center(
                                                  child: FaIcon(
                                                    FontAwesomeIcons.stickyNote,
                                                    color: colorGreen,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal / 2),
                                              ThemedText(
                                                text: "Comments:",
                                                color: colorBlack,
                                                fontSize: 12,
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal),
                                              ThemedText(
                                                text: model
                                                        .taskcompletedcomments ??
                                                    "",
                                                color: colorBlack,
                                                fontSize: 12,
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal),
                                            ],
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                  width: spaceHorizontal / 2),
                                              const SizedBox(
                                                width: 25,
                                                height: 25,
                                                child: Center(
                                                  child: FaIcon(
                                                    FontAwesomeIcons.stickyNote,
                                                    color: colorGreen,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal / 2),
                                              ThemedText(
                                                text: "Description:",
                                                color: colorBlack,
                                                fontSize: 12,
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal),
                                              Expanded(
                                                child: ThemedText(
                                                  text: model.taskdescription ??
                                                      "",
                                                  color: colorBlack,
                                                  maxLine: 3,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: spaceHorizontal),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
