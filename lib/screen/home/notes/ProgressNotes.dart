import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/HomeScreen.dart';
import 'package:rcare_2/screen/home/notes/NotesDetails.dart';


import '../../../appconstant/API.dart';
import '../../../appconstant/ApiUrls.dart';
import '../../../utils/ColorConstants.dart';
import '../../../utils/ConstantStrings.dart';
import '../../../utils/Constants.dart';
import '../../../utils/Preferences.dart';
import '../../../utils/ThemedWidgets.dart';
import '../../../utils/methods.dart';
import '../models/ProgressNoteModel.dart';

class ProgressNote extends StatefulWidget {
  const ProgressNote({super.key});

  @override
  State<ProgressNote> createState() => ProgressNoteState();
}

class ProgressNoteState extends State<ProgressNote> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  String userName = "";
  List<ProgressNoteModel> dataList = [];
  List<ProgressNoteModel> tempList = [];
  int selectedExpandedIndex = -1;


  @override
  void initState() {
    super.initState();

    getData(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  getData({required DateTime fromDate, required DateTime toDate}) async {
    // userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    int userid =  (await Preferences().getPrefInt(Preferences.prefUserID));
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
      'isCareworkerSpecific': "1",
      'rosterid': "0",
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(progressNotesList, params: params).toString(),
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
            tempList.clear();
            for (int k = 0; k < dataList.length; k++) {
              var model = dataList[k];
              if(model.isConfidential == true && model.createdBy != userid ) {
              //  do not add in list
              }
              else{
                tempList.add(model);
              }
            }
           // tempList.addAll(dataList);
            print("models.length : ${dataList.length}");

            int accType =
                await Preferences().getPrefInt(Preferences.prefAccountType);

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
      // appBar: buildAppBar(context, title: 'Progress Notes'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: spaceHorizontal, vertical: spaceVertical),
            child: ThemedText(
              text:
                  "ProgressNotes : ${DateFormat("dd-MM-yyyy").format(fromDate)} - ${DateFormat("dd-MM-yyyy").format(toDate)}",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorGreyText,
            ),
          ),
          const Divider(
            thickness: 1,
            height: 1,
            color: colorGreyBorderD3,
          ),
          Expanded(
            child: Container(
              color: colorLiteBlueBackGround,
              child: _buildList(list: tempList),
            ),
          ),
        ],
      ),
    );
  }

  _buildList({required List<ProgressNoteModel> list}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          thickness: 1,
          height: 1,
          color: colorGreyBorderD3,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            primary: true,
            itemBuilder: (context, index) {
              ProgressNoteModel model = list[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                  text: "${model.serviceName}",
                                fontSize: 15,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              ThemedText(
                                  text: "Note Writer: ${model.createdByName}",
                                  color: colorGreyLiteText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                              const SizedBox(height: 8),
                              Container(
                                width: MediaQuery.of(context).size.width,
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
                                  const SizedBox(width: 5),
                                  FaIcon(
                                    FontAwesomeIcons.calendarDays,
                                    color: colorGreen,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                      formatServiceDate(model.noteDate),
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
                                  const SizedBox(width: 5),
                                  ThemedText(
                                      text: "Progress Note",
                                      color: colorGreyText,
                                      fontSize: 14)
                                ],
                              ),
                              ThemedText(
                                  text: "Timesheet",
                                  color: colorLiteBlue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            print("progressnote 1");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProgressNoteDetails(
                                    userId: model.serviceScheduleEmpID ?? 0,
                                    clientId: model.clientID ?? 0,
                                    noteId: model.noteID ?? 0,
                                    serviceShceduleClientID:
                                        model.servicescheduleCLientID ?? 0,
                                    servicescheduleemployeeID:
                                        model.serviceScheduleEmpID ?? 0,
                                    serviceName: model.serviceName ?? "",
                                    clientName: model.clientName,
                                    noteWriter: model.createdByName ?? "",
                                    serviceDate: getDateTimeFromEpochTime(
                                            model.serviceDate ?? "") ??
                                        DateTime.now()),
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
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: FaIcon(
                                          Icons.access_time_rounded,
                                          color: colorGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: spaceHorizontal),
                                    Expanded(
                                      child: ThemedText(
                                        text: "Time " +
                                            (model.timeFrom ?? "") +
                                            " - " +
                                            (model.timeTo ?? ""),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: FaIcon(
                                          Icons.access_time,
                                          color: colorGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: spaceHorizontal),
                                    Expanded(
                                      child: ThemedText(
                                        text: "Total Hours " +
                                            (model.totalHours ?? "") +
                                            "hrs",
                                        fontSize: 12,
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
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                  child: FaIcon(
                                    Icons.note_alt_sharp,
                                    color: colorGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: spaceHorizontal),
                              Expanded(
                                child: ThemedText(
                                  text: "Created By " +
                                      (model.createdByName ?? ""),
                                  fontSize: 12,
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
    );
  }
}
