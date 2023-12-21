import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/notes/model/ClientSignatureModel.dart';
import 'package:rcare_2/utils/Images.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../../network/API.dart';
import '../../../network/ApiUrls.dart';
import '../../../utils/ColorConstants.dart';
import '../../../utils/ConstantStrings.dart';
import '../../../utils/Constants.dart';
import '../../../utils/Preferences.dart';
import '../../../utils/ThemedWidgets.dart';
import '../../../utils/WidgetMethods.dart';
import '../../../utils/methods.dart';
import '../models/DSNListModel.dart';
import '../models/ProgressNoteListByNoteIdModel.dart';
import '../models/ProgressNoteModel.dart';
import 'model/NoteDocModel.dart';

class DNSNotesDetails extends StatefulWidget {
  final int userId;
  final int serviceShceduleClientID;
  DSNListModel dsnListModel;

  DNSNotesDetails({
    super.key,
    required this.userId,
    required this.serviceShceduleClientID,
    required this.dsnListModel,
  });

  @override
  State<DNSNotesDetails> createState() => _DNSNotesDetailsState();
}

class _DNSNotesDetailsState extends State<DNSNotesDetails> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  DateTime serviceTypeDateTime = DateTime.now();
  String _assesmentScale = "1";
  final TextEditingController _taskHeader = TextEditingController();
  final TextEditingController _taskDetails = TextEditingController();
  final TextEditingController _taskComments = TextEditingController();

  // final TextEditingController _assesment_scale = TextEditingController();
  final TextEditingController _noteWriter = TextEditingController();

  final SignatureController _controllerSignature = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  ProgressNoteListByNoteIdModel? model;
  ClientSignatureModel? signatureModel;
  List<NoteDocModel>? noteDocList;
  Uint8List? signatureImage;
  Uint8List? noteDocImage;
  List<File> selectedImageFilesList = [];
  int? clientRating;
  bool isTaskCompleted = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    print('task ${widget.dsnListModel.taskcompleted!}');
    _taskHeader.text = widget.dsnListModel.taskname ?? "";
    _taskDetails.text = widget.dsnListModel.taskdescription ?? "";
    _noteWriter.text = widget.dsnListModel.notewriter ?? "";
    _taskComments.text = widget.dsnListModel.taskcompletedcomments ?? "";
    isTaskCompleted = widget.dsnListModel.taskcompleted!;
    isCompleted = widget.dsnListModel.taskcompleted!;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: colorLiteBlueBackGround,
      appBar: buildAppBar(context, title: "DNS Notes Detail"),
      body: SingleChildScrollView(
        child: Container(
          color: colorWhite,
          margin: const EdgeInsets.symmetric(
              horizontal: spaceHorizontal, vertical: spaceVertical),
          padding: const EdgeInsets.symmetric(
              vertical: spaceVertical * 1.5, horizontal: spaceHorizontal * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: textFiledHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Save",
                        fontSize: 14,
                        onTap: () async {
                          // if(_taskComments.text.isEmpty){
                          //   showSnackBarWithText(_keyScaffold.currentState, "Description can not be blank",
                          //       color: colorRed);
                          //   return;
                          // }

                          print(
                              "widget.dsnListModel!.timefrom ${widget.dsnListModel!.toJson()}");
                          print(
                              "widget.dsnListModel!.timefrom ${widget.dsnListModel!.timeto}");
                          if (widget.dsnListModel != null &&
                              widget.dsnListModel!.timefrom != null) {
                            DateTime date = getDateTimeFromEpochTime(
                                widget.dsnListModel!.ssdate!)!;
                            if (date.isBefore(DateTime.now()) || date.isToday) {
                              await saveDNSApiCall();
                            } else {
                              showSnackBarWithText(_keyScaffold.currentState,
                                  "You are not allowed to complete DSN for future date!");
                            }
                          } else {
                            showSnackBarWithText(_keyScaffold.currentState,
                                "You are not allowed to complete DSN for future date!");
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: spaceHorizontal),
                    Expanded(
                      // height: textFiledHeight,
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Cancel",
                        fontSize: 14,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (getDateTimeFromEpochTime(widget.dsnListModel.ssdate!) !=
                      null &&
                  getDateTimeFromEpochTime(widget.dsnListModel.ssdate!)!
                      .isAfter(DateTime.now()))
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    color: colorRed,
                    child: ThemedText(
                      text: "Future dates can not be completed!",
                      fontSize: 14,
                      maxLine: 2,
                      color: colorWhite,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              ThemedText(
                text:
                    "Service Schedule Client ${widget.dsnListModel.sscname ?? ""}",
                color: colorFontColor,
                fontSize: 16,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Task Header*",
                color: colorFontColor,
                fontSize: 15,
              ),
              SizedBox(
                child: ThemedTextField(
                  padding:
                      const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: true,
                  fontSized: 15,
                  minLine: 2,
                  maxLine: 2,
                  labelTextColor: colorBlack,
                  controller: _taskHeader,
                ),
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Task Details*",
                color: colorFontColor,
                fontSize: 15,
              ),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: isCompleted,
                  minLine: 2,
                  maxLine: 2,
                  fontSized: 15,
                  labelTextColor: colorBlack,
                  controller: _taskDetails,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ThemedText(
                    text: "Task Completed*",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  Radio<bool>(
                    value: true,
                    groupValue: isTaskCompleted,
                    activeColor: colorGreen,
                    onChanged: isCompleted
                        ? null
                        : (bool? value) {
                            if (value != null) {
                              setState(() {
                                isTaskCompleted = value;
                              });
                            }
                          },
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isTaskCompleted = true;
                      });
                    },
                    child: ThemedText(
                      text: "Yes",
                      color: colorBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Radio<bool>(
                    value: false,
                    groupValue: isTaskCompleted,
                    activeColor: colorGreen,
                    onChanged: isCompleted
                        ? null
                        : (bool? value) {
                            if (value != null) {
                              setState(() {
                                isTaskCompleted = value;
                              });
                            }
                          },
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isTaskCompleted = false;
                      });
                    },
                    child: ThemedText(
                      text: "No",
                      color: colorBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Task Comments*",
                color: colorFontColor,
                fontSize: 15,
              ),
              ThemedTextField(
                padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                minLine: 4,
                maxLine: 4,
                borderColor: colorGreyBorderD3,
                fontSized: 15,
                labelTextColor: colorBlack,
                backgroundColor: colorWhite,
                isReadOnly: false,
                controller: _taskComments,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Note Writes*",
                color: colorFontColor,
                fontSize: 15,
              ),
              ThemedTextField(
                padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                borderColor: colorGreyBorderD3,
                backgroundColor: colorWhite,
                isReadOnly: true,
                fontSized: 15,
                controller: _noteWriter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  saveDNSApiCall() async {
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          // response = await HttpService().init(request, _keyScaffold);
          String strBody = json.encode({
            "DSNId":
                widget.dsnListModel != null ? widget!.dsnListModel.id ?? 0 : 0,
            "DSNComments":
                _taskComments.text.isNotEmpty ? _taskComments.text : "",
            "isDSNCompleted": isTaskCompleted ? "1" : "0",
            "userID": widget.userId,
            "ServiceScheduleClientID": widget.serviceShceduleClientID,
          });
          log(strBody);
          if (strBody.isEmpty) {
            return;
          }

          Response response = await http.post(
            Uri.parse("$mainUrl$endsaveDSNDetails"),
            headers: {"Content-Type": "application/json"},
            body: strBody,
          );
          log("response ${response.body} ${response.request}}");
          if (response != "") {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
              showSnackBarWithText(_keyScaffold.currentState, "Success",
                  color: colorGreen);
              Navigator.pop(context, true);
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          log("SignUp$e");
          removeOverlay();
          // throw e;
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }
}

extension DateHelpers on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }
}
