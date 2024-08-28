import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/HomeScreen.dart';
import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/GlobalMethods.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';
import 'models/ConfirmedResponseModel.dart';
import 'models/GroupServiceResponseModel.dart';
import 'notes/NotesDetails.dart';
class GroupNoteList extends StatefulWidget {

  final TimeShiteModel selectedModel;

  const GroupNoteList({super.key, required this.selectedModel});

  @override
  State<GroupNoteList> createState() => _GroupNoteListState();
}

class _GroupNoteListState extends State<GroupNoteList> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  List<GroupServiceModel> mainListGroupService = [];
  List<GroupServiceModel> tempListGroupService = [];


  int selectedExpandedIndex = -1;
  int lastSelectedRow = -1;
  var userid = Preferences().getPrefInt(Preferences.prefUserID);

  @override
  void initState() {
    super.initState();
    getGroupServices();
  }

  _buildGroupServiceList() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: colorLiteBlueBackGround,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(widget.selectedModel.allowAddGroupNote())
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(
                    top: spaceVertical,
                    right: spaceHorizontal * 1.5,
                    left: spaceHorizontal * 1.5,
                  ),


                  child: ThemedButton(
                    title: "Add Group Note",
                    padding: EdgeInsets.zero,
                    onTap: () {
                      if (keyScaffold.currentContext != null) {
                        List<GroupServiceModel> temp = [];
                        for (GroupServiceModel model in tempListGroupService) {
                          if (model.isSelected) {
                            temp.add(model);
                          }
                        }
                        if (temp.isNotEmpty) {
                          Navigator.of(keyScaffold.currentContext!)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => ProgressNoteDetails(
                                userId: temp.first.serviceScheduleEmpID ?? 0,
                                clientId:
                                temp.first.servicescheduleCLientID ?? 0,
                                noteId: temp.first.noteID ?? 0,
                                serviceShceduleClientID:
                                temp.first.servicescheduleCLientID ?? 0,
                                servicescheduleemployeeID: widget.selectedModel.servicescheduleemployeeID ?? 0,
                                serviceName: temp.first.groupname ?? "",
                                clientName: temp.first.clientName,
                                noteWriter: temp.first.notewriter ?? "",
                                selectedGroupServiceList: temp,
                                serviceDate: getDateTimeFromEpochTime(
                                    widget.selectedModel?.serviceDate ?? "") ??
                                    DateTime.now(),
                              ),
                            ),
                          )
                              .then((value) {
                            if (value != null && value) {
                              mainListGroupService.clear();
                              tempListGroupService.clear();
                              getGroupServices();
                            }
                          });
                        } else {
                          showSnackBarWithText(keyScaffold.currentState,
                              "Please select at list a note!");
                        }
                      }
                    },
                    fontSize: 16,
                  ),
                ),
            if(tempListGroupService.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(
                top: spaceVertical,
                right: spaceHorizontal * 1.5,
                left: spaceHorizontal * 1.5,
              ),
              child:
                ThemedText(
                  text:
                  "${tempListGroupService[0].groupname} - ${tempListGroupService[0].serviceType}",
                  fontSize: 15,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
            ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tempListGroupService.length,
                    primary: true,
                    itemBuilder: (context, index) {
                      GroupServiceModel model = tempListGroupService[index];
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
                                      ThemedText(
                                        text:
                                        "${model.clientName} - ${model.serviceType}",
                                        fontSize: 15,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
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
                                              setState(() {
                                                updateSelection(index);
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
                                            child: ThemedRichText(
                                              spanList: [
                                                WidgetSpan(
                                                  child: Row(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      const FaIcon(
                                                        FontAwesomeIcons
                                                            .calendarDays,
                                                        color: colorGreen,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                          spaceHorizontal /
                                                              2),
                                                      ThemedText(
                                                        text: formatServiceDate(
                                                            model.serviceDate),
                                                        color: colorGreyText,
                                                        fontSize: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Container(
                                                        width: 1,
                                                        height: 20,
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
                                                    children: [
                                                      const FaIcon(
                                                        Icons
                                                            .access_time_outlined,
                                                        color: colorGreen,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                          spaceHorizontal /
                                                              2),
                                                      ThemedText(
                                                        text:
                                                        "${model.startTime} - ${model.endTime}",
                                                        color: colorGreyText,
                                                        fontSize: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Container(
                                                        width: 1,
                                                        height: 20,
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
                                                    children: [
                                                      const FaIcon(
                                                        Icons.timelapse_outlined,
                                                        color: colorGreen,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                          spaceHorizontal /
                                                              2),
                                                      ThemedText(
                                                        text:
                                                        "${model.totalhours} hrs",
                                                        color: colorGreyText,
                                                        fontSize: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Container(
                                                        width: 1,
                                                        height: 20,
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
                                          if (model.allowAddNote())
                                          Checkbox(
                                            value: model.isCompleted
                                                ? model.isCompleted
                                                : model.isSelected,
                                            activeColor: colorGreen,
                                            shape: model.isCompleted
                                                ? const CircleBorder()
                                                : RoundedRectangleBorder(
                                                borderRadius:
                                                boxBorderRadius),
                                            onChanged: model.isCompleted
                                                ? null
                                                : (value) {
                                              if (value != null) {
                                                model.isSelected = value;
                                                setState(() {});
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (model.allowAddNote())
                                InkWell(
                                  onTap: () {
                                    print("progressnote 3");
                                    setState(() {
                                      lastSelectedRow = index;
                                    });
                                    //Edit Group note
                                    if (keyScaffold.currentContext != null) {
                                      if (keyScaffold.currentContext != null) {
                                        Navigator.of(keyScaffold.currentContext!).push(
                                          MaterialPageRoute(
                                            builder: (context) => ProgressNoteDetails(
                                              userId: model.serviceScheduleEmpID ?? 0,
                                              clientId: model.rESID ?? 0,
                                              noteId: model.noteID ?? 0,
                                              serviceShceduleClientID: model.servicescheduleCLientID ?? 0,
                                              servicescheduleemployeeID: widget.selectedModel.servicescheduleemployeeID ?? 0,
                                              serviceName: model.groupname ?? "",
                                              clientName: model.clientName,
                                              noteWriter: model.notewriter ?? "",
                                              serviceDate: getDateTimeFromEpochTime(model.serviceDate ?? "") ?? DateTime.now(),
                                            ),
                                          ),
                                        ).then((value) {
                                          print("=============");
                                          if (value != null && value) {
                                            mainListGroupService.clear();
                                            tempListGroupService.clear();
                                            getGroupServices();
                                          }
                                        });
                                      }
                                    }
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
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 7),
                                  buildTextRowWithAlphaIcon("D", model.description !=
                                      null &&
                                      model.description!
                                          .isNotEmpty
                                      ? model.description!
                                      : "No description provided."),
                                  const SizedBox(height: 7),
                                  buildTextRowWithAlphaIcon("A",  model.assessmentcomments !=
                                      null &&
                                      model.assessmentcomments!
                                          .isNotEmpty
                                      ? model.assessmentcomments!
                                      : "No assessment comment provided."),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      launchUrlMethod(
                                          "http://maps.google.com/?q=${model.resAddress}");
                                    },
                                    child: buildIconTextRow(FontAwesomeIcons.locationDot, model.resAddress ?? ""),
                                  ),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      launchUrlMethod(
                                          "tel:${model.resHomePhone}");
                                    },
                                    child: buildIconTextRow(FontAwesomeIcons.phoneVolume,model.resHomePhone ?? ""),
                                  ),
                                  const SizedBox(height: 7),
                                  InkWell(
                                    onTap: () {
                                      launchUrlMethod(
                                          "tel:${model.resMobilePhone}");
                                    },
                                    child: buildIconTextRow(FontAwesomeIcons.mobileAlt,model.resMobilePhone ?? ""),
                                  ),
                                  const SizedBox(height: 7),
                                ],
                              ),
                      ),]
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

  updateSelection(int index){
    if (selectedExpandedIndex == index) {
      selectedExpandedIndex = -1;
    } else {
      selectedExpandedIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      appBar: buildAppBar(context, title: "Group Notes"),
      backgroundColor: colorLiteBlueBackGround,
      body: _buildGroupServiceList(),
    );
  }

  getGroupServices() async {
    if (widget.selectedModel != null) {
      Map<String, dynamic> params = {
        'auth_code':
        (await Preferences().getPrefString(Preferences.prefAuthCode)),
        'userid':
        (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
        'RosterID': (widget.selectedModel!.rosterID ?? "0").toString(),
        'ssEmployeeID':
        (widget.selectedModel!.servicescheduleemployeeID ?? "0").toString(),
      };
      print("params : $params");
      isConnected().then((hasInternet) async {
        if (hasInternet) {
          HttpRequestModel request = HttpRequestModel(
              url: getUrl(endClientGroupList, params: params).toString(),
              authMethod: '',
              body: '',
              headerType: '',
              params: '',
              method: 'GET');
          getOverlay(context);

          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            List jResponse = json.decode(response);
            mainListGroupService.clear();
            mainListGroupService.addAll(
                jResponse.map((e) => GroupServiceModel.fromJson(e)).toList());
            tempListGroupService.clear();
            tempListGroupService.addAll(mainListGroupService);

            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          try {
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
}