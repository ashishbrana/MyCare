import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rcare_2/screen/home/HomeScreen.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';
import 'models/CareWorkerModel.dart';
import 'models/ConfirmedResponseModel.dart';
import 'notes/NotesDetails.dart';

class CareWorkerList extends StatefulWidget {
  final int userId;
  final int rosterID;
  final TimeShiteModel model;

  const CareWorkerList(
      {super.key,
      required this.userId,
      required this.rosterID,
      required this.model});

  @override
  State<CareWorkerList> createState() => _CareWorkerListState();
}

class _CareWorkerListState extends State<CareWorkerList> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  List<CareWorkerModel> dataList = [];

  int selectedExpandedIndex = -1;
  int lastSelectedRow = -1;
  int userId = 0;


  @override
  void initState() {
    super.initState();
    print("INITSTATE");
    getData();
  }

  getData() async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': widget.userId.toString(),
      'RosterID': widget.rosterID.toString(),
      'usertype': "2",
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

            List jResponse = json.decode(response);
            print("jResponse $jResponse");
            dataList =
                jResponse.map((e) => CareWorkerModel.fromJson(e)).toList();

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
      appBar: buildAppBar(context, title: "Care Workers"),
      backgroundColor: colorLiteBlueBackGround,
      body: Column(
        children: [
          if(widget.model.isGroupService)
            Container(
              margin: const EdgeInsets.only(
                top: spaceVertical,
                right: spaceHorizontal * 1.5,
                left: spaceHorizontal * 1.5,
              ),
              child:
              ThemedText(
                text:
                "${widget.model.groupName}",
                fontSize: 15,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              primary: true,
              itemBuilder: (context, index) {
                CareWorkerModel model = dataList[index];
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
                                                        "${model.careWorkerName} - ",
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.blueAccent,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: model.serviceType,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.blueAccent,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (model.showNoteIcon(widget.userId) && !widget.model.isGroupService)
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  lastSelectedRow = index;
                                                });

                                                Navigator.push(
                                                  keyScaffold.currentContext!,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProgressNoteDetails(
                                                      userId:
                                                          widget.model.empID ??
                                                              0,
                                                      noteId: model.noteID ?? 0,
                                                      clientId:
                                                          widget.model.rESID ??
                                                              0,
                                                      servicescheduleemployeeID:
                                                          widget.model
                                                                  .servicescheduleemployeeID ??
                                                              0,
                                                      serviceShceduleClientID:
                                                          widget.model
                                                                  .serviceShceduleClientID ??
                                                              0,
                                                      serviceName: widget.model
                                                              .serviceName ??
                                                          "",
                                                      clientName:
                                                          "${widget.model.resName} - ${widget.model.rESID.toString().padLeft(5, "0")}",
                                                      noteWriter: model.careWorkerName ?? "",
                                                      serviceDate:
                                                          getDateTimeFromEpochTime(
                                                                  widget.model
                                                                          .serviceDate ??
                                                                      "") ??
                                                              DateTime.now(),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const FaIcon(
                                                // FontAwesomeIcons.notesMedical,
                                                Icons.note_alt_outlined,
                                                size: 22,
                                                color: colorGreen,
                                              ),
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
                                                            formatServiceDate(model.serviceDate),
                                                          style: const TextStyle(
                                                            color:
                                                                colorGreyText,
                                                            fontSize: 14,
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
                                                        /* const SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                        ),*/
                                                        const SizedBox(
                                                            width: 5),
                                                        const Icon(
                                                          CupertinoIcons.time,
                                                          color: colorGreen,
                                                          size: 14,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          "${model.totalhours}hrs",
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
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        /* const SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                        ),*/
                                                        const SizedBox(
                                                            width: 5),
                                                        const Icon(
                                                          Icons.timer,
                                                          color: colorGreen,
                                                          size: 14,
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
                            if(selectedExpandedIndex == index)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (model.isPrivate(widget.userId) == false)
                                const SizedBox(height: 7),
                                if (model.isPrivate(widget.userId) == false)
                                buildTextRowWithAlphaIcon("D", model.getDescription(widget.userId)),
                                if (model.isPrivate(widget.userId) == false)
                                const SizedBox(height: 7),
                                if (model.isPrivate(widget.userId) == false)
                                buildTextRowWithAlphaIcon("A",  model.assessmentComments !=
                                    null &&
                                    model.assessmentComments!
                                        .isNotEmpty
                                    ? model.assessmentComments!
                                    : "No assessment comment provided."),
                                const SizedBox(height: 7),
                                ThemedRichText(
                                  spanList: [
                                    getTextSpan(
                                      text: "Client : ",
                                      fontColor: colorBlack,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    getTextSpan(
                                      text: model.clientName ?? "",
                                      fontColor: colorBlack,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                              ],
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
