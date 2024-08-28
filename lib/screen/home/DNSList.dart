import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/HomeScreen.dart';
import 'package:rcare_2/screen/home/models/DSNListModel.dart';
import 'package:rcare_2/screen/home/notes/DNSNotesDetails.dart';
import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';


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
  int lastSelectedRow = -1;
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
      'fromdate': fromDate.shortDate(),
      'todate': toDate.shortDate(),
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
      appBar: buildAppBar(context, title: "Daily Support Needs"),
      backgroundColor: colorLiteBlueBackGround,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              primary: true,
              itemBuilder: (context, index) {
                DSNListModel model = dataList[index];

                return Container(
                  margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  decoration: BoxDecoration(
                    color: lastSelectedRow == index
                        ? Colors.grey.withOpacity(0.2)
                        : colorWhite,
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
                                                            fontSize: 15,
                                                            color: Colors
                                                                .blueAccent,
                                                            fontWeight: FontWeight
                                                                .bold,

                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                          "\nNote Writer: ${model
                                                              .notewriter}",
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
                                              width: MediaQuery
                                                  .of(context)
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
                                                      Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: (model
                                                            .taskcompleted ??
                                                            false)
                                                            ? colorGreen
                                                            : colorOrange,
                                                        size: 22,
                                                      ),
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
                                if ((getDateTimeFromEpochTime(model.ssdate!) !=
                                    null &&
                                    getDateTimeFromEpochTime(model.ssdate!)!
                                        .isFutureDate ==
                                        false) &&
                                    (widget.userId == model.notewriterid ||
                                        model.notewriterid == 0))
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        lastSelectedRow = index;
                                      });
                                      Navigator.push(
                                        keyScaffold.currentContext!,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DNSNotesDetails(
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
                            if (selectedExpandedIndex == index)
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 7),
                              Expanded(child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ThemedRichText(
                                    spanList: [
                                      WidgetSpan(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time_outlined,
                                              color: colorGreen,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                                width: spaceHorizontal / 2),
                                            ThemedText(
                                              text:
                                              "${model.timefrom ?? ""} - ${model
                                                  .timeto ?? ""}",
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
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  buildTextRowWithAlphaIcon(
                                      "D", model.taskdescription !=
                                      null &&
                                      model.taskdescription!
                                          .isNotEmpty
                                      ? model.taskdescription!
                                      : "No Task Details.."),
                                  const SizedBox(height: 7),
                                  buildTextRowWithAlphaIcon(
                                      "C", model.taskcompletedcomments !=
                                      null &&
                                      model.taskcompletedcomments!
                                          .isNotEmpty
                                      ? model.taskcompletedcomments!
                                      : "No Task Comments.."),
                                ],
                              ),
                                ),],)
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
  updateSelection(int index){
    if (selectedExpandedIndex == index) {
      selectedExpandedIndex = -1;
    } else {
      selectedExpandedIndex = index;
    }
  }
}
