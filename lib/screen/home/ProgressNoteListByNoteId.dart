import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/network/ApiUrls.dart';

import '../../Network/API.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import 'HomeScreen.dart';

import 'models/ProgressNoteModel.dart';
import 'notes/NotesDetails.dart';

class ProgressNoteListByNoteId extends StatefulWidget {
  final int userId;
  final int noteID;
  final int rosterID;

  const ProgressNoteListByNoteId(
      {super.key,
      required this.userId,
      required this.noteID,
      required this.rosterID});

  @override
  State<ProgressNoteListByNoteId> createState() =>
      _ProgressNoteListByNoteIdState();
}

class _ProgressNoteListByNoteIdState extends State<ProgressNoteListByNoteId> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  List<ProgressNoteModel> dataList = [];

  int selectedExpandedIndex = -1;

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
      'fromdate': DateFormat("yyyy/MM/dd").format(fromDate),
      'todate': DateFormat("yyyy/MM/dd").format(toDate),
      'userid': widget.userId.toString(),
      'NoteID': widget.noteID.toString(),
      'RosterID': widget.rosterID.toString(),
      'isCareworkerSpecific': "1",
    };
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endProgressNotesList, params: params).toString(),
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
                jResponse.map((e) => ProgressNoteModel.fromJson(e)).toList();
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
              text: "Progress Note",
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
                ProgressNoteModel model = dataList[index];
                return Container(
                  margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: boxBorderRadius,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  flex: 8,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ThemedText(
                                        text: "${model.serviceName} ",
                                        color: colorBlack,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                      ThemedRichText(spanList: [
                                        getTextSpan(
                                          text: "Note Writer: ",
                                          fontColor: colorGreyLiteText,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        getTextSpan(
                                          text: model.createdByName ?? "",
                                          fontColor: colorGreyLiteText,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                      ]),
                                      const SizedBox(height: 8),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                              textAlign: TextAlign.left,
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
                                                        const SizedBox(
                                                            width: 5),
                                                        const FaIcon(
                                                          FontAwesomeIcons
                                                              .calendarDays,
                                                          color: colorGreen,
                                                          size: 14,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          // model.serviceDate!,
                                                          model.noteDate != null
                                                              ? DateFormat(
                                                                      "EEE,dd-MM-yyyy")
                                                                  .format(
                                                                  DateTime.fromMillisecondsSinceEpoch(
                                                                          int.parse(model.noteDate!.replaceAll("/Date(", "").replaceAll(
                                                                              ")/",
                                                                              "")),
                                                                          isUtc:
                                                                              false)
                                                                      .add(
                                                                    Duration(
                                                                        hours:
                                                                            5,
                                                                        minutes:
                                                                            30),
                                                                  ),
                                                                )
                                                              : "",
                                                          style: TextStyle(
                                                            color:
                                                                colorGreyText,
                                                            fontSize: 12,
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
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        /*const SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        const Icon(
                                                          CupertinoIcons.time,
                                                          color: colorGreen,
                                                          size: 14,
                                                        ),*/
                                                        const SizedBox(
                                                            width: 5),
                                                        const Text(
                                                          "Progress Note",
                                                          style: TextStyle(
                                                            color:
                                                                colorGreyText,
                                                            fontSize: 12,
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
                                InkWell(
                                  onTap: () {
                                    Navigator.of(keyScaffold.currentContext ??
                                            context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProgressNoteDetails(
                                          // model: model,
                                          userId:
                                              model.serviceScheduleEmpID ?? 0,
                                              clientId: model.clientID ?? 0,
                                          servicescheduleemployeeID: model.serviceScheduleEmpID ?? 0,
                                          serviceShceduleClientID: model.servicescheduleCLientID ?? 0,
                                          noteId: model.noteID ?? 0,
                                          serviceName: model.serviceName ?? "",
                                          clientName: model.clientName, noteWriter: model.createdByName ?? "",
                                                serviceDate:   getDateTimeFromEpochTime(model.serviceDate ?? "") ?? DateTime.now(),
                                        ),
                                      ),
                                    );
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
                              expandedHeight: 90,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 30,
                                          height: 30,
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                        Icons.timer,
                                                        color: colorGreen,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "${model.timeFrom ?? ""} - ${model.timeTo ?? ""}",
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                        Icons.timer,
                                                        color: colorGreen,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Total Hours: ${model.totalHours ?? ""}hrs",
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                        Icons.timer,
                                                        color: colorGreen,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Created By: ${model.createdByName ?? ""}",
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
                                              ],
                                            ),
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
