import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rcare_2/screen/home/notes/model/ClientSignatureModel.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


import '../../../appconstant/ApiUrls.dart';
import '../../../utils/ColorConstants.dart';
import '../../../utils/ConstantStrings.dart';
import '../../../utils/Constants.dart';
import '../../../utils/ThemedWidgets.dart';
import '../../../utils/WidgetMethods.dart';
import '../../../utils/methods.dart';
import '../models/DSNListModel.dart';
import '../models/ProgressNoteListByNoteIdModel.dart';
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
  final TextEditingController _taskHeader = TextEditingController();
  final TextEditingController _taskDetails = TextEditingController();
  final TextEditingController _taskComments = TextEditingController();
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

  void validateAndSave() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: colorLiteBlueBackGround,
      appBar: buildAppBar(context, title: "DNS Notes Detail" , showActionButton: true , onActionButtonPressed: () {
        validateAndSave();
      },),
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
              if (widget.dsnListModel.isFutureDate)
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
              if (widget.dsnListModel.isFutureDate)
              const SizedBox(height: 10),
              ThemedText(
                text:
                    "${widget.dsnListModel.sscname ?? ""}",
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              const SizedBox(height: 4),
              ThemedText(
                text: "Note Writer : ${widget.dsnListModel.notewriter ?? ""}",
                color: colorFontColor,
                fontSize: 15,
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
               ThemedTextField(
                  padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                 // isReadOnly: isCompleted,
                 isReadOnly: true,
                  minLine: 6,
                  maxLine: 6,
                  fontSized: 15,
                  labelTextColor: colorBlack,
                  controller: _taskDetails,
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
                padding: const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                minLine: 6,
                maxLine: 6,
                borderColor: colorGreyBorderD3,
                fontSized: 15,
                labelTextColor: colorBlack,
                backgroundColor: colorWhite,
                isReadOnly: false,
                controller: _taskComments,
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
            Uri.parse("$masterURL$endsaveDSNDetails"),
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

