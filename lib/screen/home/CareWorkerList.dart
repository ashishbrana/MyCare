import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/HomeScreen.dart';

import '../../Network/API.dart';
import '../../network/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import 'models/CareWorkerModel.dart';

class CareWorkerList extends StatefulWidget {
  final int userId;
  final int rosterID;

  const CareWorkerList(
      {super.key, required this.userId, required this.rosterID});

  @override
  State<CareWorkerList> createState() => _CareWorkerListState();
}

class _CareWorkerListState extends State<CareWorkerList> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  List<CareWorkerModel> dataList = [];

  int selectedExpandedIndex = 0;

  iniState() {
    super.initState();
    print("init");
    getData();
  }

  getData() async {
    // userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': widget.userId.toString(),
      'RosterID': widget.rosterID.toString(),
    };
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endCareWorkersList, params: params).toString(),
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
            dataList =
                jResponse.map((e) => CareWorkerModel.fromJson(e)).toList();
            print("models.length : ${dataList.length}");

            setState(() {});
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
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
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              primary: true,
              itemBuilder: (context, index) {
                CareWorkerModel model = dataList[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
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
                                                  "${model.careWorkerName} ",
                                              style: const TextStyle(
                                                color: colorGreyText,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextSpan(
                                              text: model.serviceType,
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
                                      const FaIcon(
                                        FontAwesomeIcons.calendarDays,
                                        size: 16,
                                      ),
                                    const SizedBox(
                                        width: spaceHorizontal / 2),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.person_crop_circle,
                                        color: Colors.white,
                                        size: 16,
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
                                          selectedExpandedIndex = index;
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
                                                  Text(
                                                    // model.serviceDate!,
                                                    model.serviceDate != null
                                                        ? DateFormat(
                                                                "EEE,dd-MM-yyyy")
                                                            .format(
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                    int.parse(model
                                                                        .serviceDate!
                                                                        .replaceAll(
                                                                            "/Date(",
                                                                            "")
                                                                        .replaceAll(
                                                                            ")/",
                                                                            "")),
                                                                    isUtc:
                                                                        false)
                                                                .add(
                                                              Duration(
                                                                  hours: 5,
                                                                  minutes:
                                                                      30),
                                                            ),
                                                          )
                                                        : "",
                                                    style: TextStyle(
                                                      color: colorGreyText,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Container(
                                                    width: 1,
                                                    height: 25,
                                                    color: colorGreyBorderD3,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            WidgetSpan(
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Icon(
                                                    CupertinoIcons.time,
                                                    color: colorGreen,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${model.totalhours}hrs",
                                                    style: const TextStyle(
                                                      color: colorGreyText,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Container(
                                                    width: 1,
                                                    height: 25,
                                                    color: colorGreyBorderD3,
                                                  ),
                                                  const SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                            WidgetSpan(
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Icon(
                                                    Icons.timer,
                                                    color: colorGreen,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${model.timeFrom ?? " "} - ${model.timeTo ?? " "}",
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
                      ExpandableContainer(
                        expanded: selectedExpandedIndex == index,
                        expandedHeight: 225,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedRichText(
                                spanList: [
                                  getTextSpan(
                                    text: "Client : ",
                                    fontColor: colorBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  getTextSpan(
                                    text: model.clientName ?? "",
                                    fontColor: colorBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
