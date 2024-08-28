import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
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
  List<ProgressNoteModel> filteredList = [];

  int selectedExpandedIndex = -1;
  int lastSelectedRow = -1;

  final TextEditingController _controllerSearch = TextEditingController();
  FocusScopeNode focusNode = FocusScopeNode();
  FocusScopeNode focusNavigatorNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    print("notelist");
    int userid =  (await Preferences().getPrefInt(Preferences.prefUserID));
    Map<String, dynamic> params = {
      'auth_code': (await Preferences().getPrefString(
          Preferences.prefAuthCode)),
      'accountType': (await Preferences().getPrefInt(
          Preferences.prefAccountType)).toString(),
      'fromdate': fromDate.shortDate(),
      'todate': toDate.shortDate(),
      'userid': widget.userId.toString(),
      'NoteID': widget.noteID.toString(),
      'RosterID': widget.rosterID.toString(),
      'isCareworkerSpecific': "1",
    };
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
            List jResponse = json.decode(response);

            dataList =
                jResponse.map((e) => ProgressNoteModel.fromJson(e)).toList();
            filteredList.clear();
            for (int k = 0; k < dataList.length; k++) {
              var model = dataList[k];
              print(userid);
              print(model.createdBy);
              if(model.isConfidential == true && model.createdBy != userid ) {
                //  do not add in list
              }
              else{
                filteredList.add(model);
              }
            }


           // filteredList.addAll(dataList);


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

  Widget createStyledContainer(String labelText, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
      decoration: BoxDecoration(
        color: colorGreen,
        borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
      ),
      width: MediaQuery
          .of(context)
          .size
          .width,
      padding: const EdgeInsets.all(3),
      child: ThemedText(
        text: labelText,
        color: colorWhite,
        fontSize: 12,
        textAlign: TextAlign.center,
      ),
    );
  }

  void performSearch(String searchString) {

    filteredList = searchString.isNotEmpty && searchString.length > 1
          ? dataList
          .where((model) =>
      model.clientName?.toLowerCase().contains(searchString.toLowerCase()) ==
          true ||
          model.clientName?.toLowerCase().contains(searchString.toLowerCase()) ==
              true)
          .toList()
          : List.from(dataList);

      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      appBar: buildAppBar(context, title: "Progress Notes"),
      backgroundColor: colorLiteBlueBackGround,
      body: Column(

        children: [
          const SizedBox(height: 8),
          Container(

                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
              child: FocusScope(
                node: focusNode,
                child: ThemedTextField(
                  borderColor: colorPrimary,
                  controller: _controllerSearch,
                  // currentFocusNode: focusNode,
                  preFix: const  Icon(
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
          if(filteredList.isNotEmpty && filteredList.first.serviceScheduleType == 2)
            Container(
              margin: const EdgeInsets.only(
                top: spaceVertical,
                right: spaceHorizontal * 1.5,
                left: spaceHorizontal * 1.5,
              ),
              child:
              ThemedText(
                text:
                "${dataList[0].groupName}",
                fontSize: 15,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              primary: true,
              itemBuilder: (context, index) {
                ProgressNoteModel model = filteredList[index];
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
                                        fontSize: 15,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
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
                                        MediaQuery
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
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          formatServiceDate(
                                                              model.noteDate),
                                                          style:
                                                          const TextStyle(
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
                                                        const SizedBox(
                                                            width: 5),
                                                         Text(
                                                          model.subject ?? "Progress Note",
                                                          style: const TextStyle(
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
                                            height: 20,
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
                                              servicescheduleemployeeID:
                                              model.serviceScheduleEmpID ?? 0,
                                              serviceShceduleClientID:
                                              model.servicescheduleCLientID ??
                                                  0,
                                              noteId: model.noteID ?? 0,
                                              serviceName: model.serviceName ??
                                                  "",
                                              clientName: model.clientName,
                                              noteWriter: model.createdByName ??
                                                  "",
                                              serviceDate: getDateTimeFromEpochTime(
                                                  model.serviceDate ?? "") ??
                                                  DateTime.now(),
                                            ),
                                      ),
                                    ).then((value) {
                                      if (value != null) {
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
                                    width: 7,
                                    height: 7,
                                  ),
                              Expanded(
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .access_time_outlined,
                                                      color: colorGreen,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      "${model.timeFrom ??
                                                          ""} - ${model
                                                          .timeTo ?? ""}",
                                                      style: const TextStyle(
                                                        color: colorGreyText,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Container(
                                                      width: 1,
                                                      height: 20,
                                                      color: colorGreyBorderD3,
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
                                                      Icons.timelapse,
                                                      color: colorGreen,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      "${model
                                                          .totalHours ??
                                                          ""}hrs",
                                                      style: const TextStyle(
                                                        color: colorGreyText,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Container(
                                                      width: 1,
                                                      height: 20,
                                                      color: colorGreyBorderD3,
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
                                            model.assessmentComment?.trim() ??
                                                "No assessment comment"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              ),],),
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
