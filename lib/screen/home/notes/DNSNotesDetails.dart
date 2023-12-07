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
  // final ProgressNoteModel model;
  // final int userId;
  // final int clientId;
  // final int noteId;
  // final int serviceShceduleClientID;
  // final int servicescheduleemployeeID;
  // String? clientName;
  // final String serviceName;
  DSNListModel dsnListModel;

  DNSNotesDetails({
    super.key,
    /* required this.model,*/
    // required this.userId,
    // required this.noteId,
    // required this.clientId,
    // required this.serviceShceduleClientID,
    // required this.servicescheduleemployeeID,
    // this.clientName,
    // required this.serviceName,
    required this.dsnListModel,
  });

  @override
  State<DNSNotesDetails> createState() => _DNSNotesDetailsState();
}

class _DNSNotesDetailsState extends State<DNSNotesDetails> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  DateTime serviceTypeDateTime = DateTime.now();
  String _assesmentScale = "1";
  final TextEditingController _serviceType = TextEditingController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _disscription = TextEditingController();

  // final TextEditingController _assesment_scale = TextEditingController();
  final TextEditingController _assesment_comment = TextEditingController();

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

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

/*  @override
  Widget build(BuildContext context) {
    // print("noteDocModel: ${noteDocModel!.length}");
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
                          if(_disscription.text.isEmpty){
                            showSnackBarWithText(_keyScaffold.currentState, "Description can not be blank",
                                color: colorRed);
                            return;
                          }
                          await saveNoteApiCall();
                          for (File file in selectedImageFilesList) {
                            saveNoteDoc(file);
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
              const SizedBox(height: 20),
              ThemedText(
                text: "Service Schedule Client ${widget.dsnListModel. ?? ""}",
                color: colorFontColor,
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Note Writer : ${model?.createdByName ?? ""}",
                color: colorFontColor,
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Note Date(dd-mm-yyyy)*",
                color: colorFontColor,
                fontSize: 18,
              ),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  padding:
                      const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: true,
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: serviceTypeDateTime,
                            firstDate: DateTime(serviceTypeDateTime.year - 23),
                            lastDate: DateTime(serviceTypeDateTime.year + 23))
                        .then((value) {
                      if (value != null) {
                        setState(() {
                          serviceTypeDateTime = value;
                          _serviceType.text = DateFormat("dd-MM-yyyy").format(
                            serviceTypeDateTime,
                          );
                        });
                      }
                    });
                  },
                  labelTextColor: colorBlack,
                  controller: _serviceType,
                ),
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Subject*",
                color: colorFontColor,
                fontSize: 18,
              ),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: false,
                  labelTextColor: colorBlack,
                  controller: _subject,
                ),
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Description*",
                color: colorFontColor,
                fontSize: 18,
              ),
              ThemedTextField(
                padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                minLine: 4,
                maxLine: 4,
                borderColor: colorGreyBorderD3,
                labelTextColor: colorBlack,
                backgroundColor: colorWhite,
                isReadOnly: false,
                controller: _disscription,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Assessment Scale*",
                color: colorFontColor,
                fontSize: 18,
              ),
              ThemedDropDown(
                defaultValue: _assesmentScale,
                dataString: const [
                  "0",
                  "1",
                  "2",
                  "3",
                  "4",
                  "5",
                  "6",
                  "7",
                  "8",
                  "9",
                  "10",
                ],
                onChanged: (s) {
                  setState(() {
                    _assesmentScale = s;
                  });
                },
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Assessment Comments*",
                color: colorFontColor,
                fontSize: 18,
              ),
              ThemedTextField(
                padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                borderColor: colorGreyBorderD3,
                backgroundColor: colorWhite,
                isReadOnly: false,
                minLine: 3,
                maxLine: 3,
                controller: _assesment_comment,
              ),
              const SizedBox(height: 10),
          Row(children:[
              ThemedText(
                text: "Client Signature",
                color: colorFontColor,
                fontSize: 18,
              ),
            Spacer(),
            SizedBox(
                width: 100,
            child: ThemedButton(
              padding: EdgeInsets.zero,
              title: "Clear",
              fontSize: 14,
              onTap: () {
                _controllerSignature.clear();
              },
            ),
                ),
              ]
          ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorGreyBorderD3),
                ),
                child: signatureImage != null
                    ? Image.memory(signatureImage!)
                    : Signature(
                        backgroundColor: Colors.white,
                        controller: _controllerSignature,
                        width: 300,
                        height: 180,
                      ),
              ),
              const SizedBox(height: spaceVertical),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        clientRating = 1;
                      });
                    },
                    child: const FaIcon(
                      FontAwesomeIcons.solidFaceSmile,
                      color: Colors.amber,
                      size: 48,
                    ),
                  ),
                  Radio<int>(
                      value: 1,
                      groupValue: clientRating,
                      activeColor: colorGreen,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            clientRating = value;
                          });
                        }
                      }),
                  const SizedBox(width: spaceHorizontal),
                  InkWell(
                    onTap: () {
                      setState(() {
                        clientRating = 2;
                      });
                    },
                    child: const FaIcon(
                      FontAwesomeIcons.solidFaceMeh,
                      color: Colors.amber,
                      size: 48,
                    ),
                  ),
                  Radio<int>(
                      value: 2,
                      groupValue: clientRating,
                      activeColor: colorGreen,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            clientRating = value;
                          });
                        }
                      }),
                  const SizedBox(width: spaceHorizontal),
                  InkWell(
                    onTap: () {
                      setState(() {
                        clientRating = 3;
                      });
                    },
                    child: const FaIcon(
                      FontAwesomeIcons.solidFaceFrown,
                      color: Colors.amber,
                      size: 48,
                    ),
                  ),
                  Radio<int>(
                      value: 3,
                      groupValue: clientRating,
                      activeColor: colorGreen,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            clientRating = value;
                          });
                        }
                      }),
                ],
              ),
              const SizedBox(height: spaceVertical),
              SizedBox(
                height: textFiledHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    *//*Expanded(
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Save",
                        fontSize: 14,
                        onTap: () async {
                          await saveNoteApiCall();
                          for (File file in selectedImageFilesList) {
                            saveNoteDoc(file);
                          }
                        },
                      ),
                    ),*//*
                   *//* const Spacer(),
                    const SizedBox(width: spaceHorizontal),
                    SizedBox(
                      width: 100,
                      height: textFiledHeight,
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Clear",
                        fontSize: 14,
                        onTap: () {
                          _controllerSignature.clear();
                        },
                      ),
                    ),*//*
                  ],
                ),
              ),
              const SizedBox(height: spaceVertical),
              SizedBox(
                height: textFiledHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Add Image",
                        fontSize: 14,
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              *//*insetPadding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: boxBorderRadius,
                                    ),*//*
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: ThemedText(
                                      text: 'Camera',
                                    ),
                                    leading: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: colorGreen,
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image =
                                          await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 30,
                                      );
                                      if (image != null) {
                                        setState(() {
                                          print(image.path);
                                          selectedImageFilesList
                                              .add(File(image.path));
                                        });
                                      }
                                    },
                                  ),
                                  const Divider(
                                    color: colorDivider,
                                    height: 1,
                                  ),
                                  ListTile(
                                    title: ThemedText(
                                      text: 'Gallery',
                                    ),
                                    leading: const Icon(
                                      Icons.photo_rounded,
                                      color: colorGreen,
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final ImagePicker picker = ImagePicker();
                                      final List<XFile> image =
                                          await picker.pickMultiImage(
                                        imageQuality: 30,
                                      );
                                      if (image.isNotEmpty) {
                                        setState(() {
                                          for (XFile file in image) {
                                            selectedImageFilesList
                                                .add(File(file.path));
                                            print(file.path);
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: spaceHorizontal),
                    SizedBox(
                      width: 100,
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Refresh",
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: spaceVertical),
              if (noteDocList != null && noteDocList!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: noteDocList!.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      getNoteImage64(noteDocList![index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ThemedText(text: noteDocList![index].name ?? ""),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              deleteNoteDoc(noteDocList![index].name ?? "");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (noteDocImage != null)
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Image.memory(noteDocImage!),
                ),
              if (selectedImageFilesList.isNotEmpty)
                const SizedBox(height: spaceVertical),
              if (selectedImageFilesList.isNotEmpty)
                ThemedText(text: "Selected Images"),
              if (selectedImageFilesList.isNotEmpty)
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedImageFilesList.length,
                  itemBuilder: (context, index) => AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.file(selectedImageFilesList[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  saveNoteApiCall() async {
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          // response = await HttpService().init(request, _keyScaffold);
          Uint8List? signature = await _controllerSignature.toPngBytes();
          String stri =
              "iVBORw0KGgoAAAANSUhEUgAAASwAAACWCAYAAABkW7XSAAAABGdBTUEAALGPC/xhBQAAAPNJREFUeF7t1MEJgDAQRNHtvylLsYQcPYianETCBvQk6HvwOxgmAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgC84pEv7g7abrV3LoNI1t6YWnLLR6r9lxzQqO6cshwUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADviKj9UU7A+mOSSQAAAABJRU5ErkJggg==";
          String strBody = json.encode({
            "NoteID": model != null ? model!.noteID ?? 0 : 0,
            "NoteDate": DateFormat("yyyy/MM/dd").format(DateTime.now()),
            "AssessmentScale": _assesmentScale.toString(),
            "AssessmentComment":
                _assesment_comment.text.isEmpty ? "" : _assesment_comment.text,
            "Description":
                _disscription.text.isNotEmpty ? _disscription.text : "",
            "Subject": _subject.text,
            "img": 0,
            "userID": widget.userId,
            "clientID": widget.clientId,
            "ServiceScheduleClientID": widget.serviceShceduleClientID,
            "bit64Signature":
                signature != null ? "${base64.encode(signature)}" : " ",
            "ClientRating": clientRating.toString(),
            "ssClientIds": "",
            "GroupNote": 0,
            "ssEmployeeID": widget.servicescheduleemployeeID
          });
          log(strBody);
          if (strBody.isEmpty) {
            return;
          }

          Response response = await http.post(
            Uri.parse(
                "https://mycare-web.mycaresoftware.com/MobileAPI/v1.asmx/$endSaveNoteDetails"),
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
              if (selectedImageFilesList.isEmpty) {
                Navigator.pop(context, true);
              }
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
  }*/

}
