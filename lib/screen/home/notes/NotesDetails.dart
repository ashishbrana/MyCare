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
import '../models/ProgressNoteListByNoteIdModel.dart';
import '../models/ProgressNoteModel.dart';
import 'model/NoteDocModel.dart';

class ProgressNoteDetails extends StatefulWidget {
  // final ProgressNoteModel model;
  final int userId;
  final int clientId;
  final int noteId;
  final int serviceShceduleClientID;
  final int servicescheduleemployeeID;
  String? clientName;
  final String serviceName;

  ProgressNoteDetails({
    super.key,
    /* required this.model,*/ required this.userId,
    required this.noteId,
    required this.clientId,
    required this.serviceShceduleClientID,
    required this.servicescheduleemployeeID,
    this.clientName,
    required this.serviceName,
  });

  @override
  State<ProgressNoteDetails> createState() => _ProgressNoteDetailsState();
}

class _ProgressNoteDetailsState extends State<ProgressNoteDetails> {
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
    if (widget.noteId != 0) {
      getData();
    } else {
      //Fill model with defalt value and save with noteid = 0
      model = ProgressNoteListByNoteIdModel();
      model?.subject = "Progress Note";
      _subject.text = model!.subject ?? "";
      _serviceType.text = DateFormat("dd-MM-yyyy").format(
        serviceTypeDateTime,
      );
    }
  }

  getData() async {
    // userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': widget.userId.toString(),
      'NoteID': widget.noteId.toString(),
    };
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endNoteDetailsByID, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          removeOverlay();
          if (response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponse $jResponse");
            model = jResponse
                .map((e) => ProgressNoteListByNoteIdModel.fromJson(e))
                .toList()[0];
            if (model != null) {
              if (model!.clientsignature != null) {
                getClientSignatureData(model!.clientsignature!);
              }
              if (model!.noteID != 0) {
                getNoteDocs(getDateTimeFromEpochTime(model!.noteDate ?? "")!,
                    widget.clientName ?? " ", model!.noteID ?? 0);
              }
              serviceTypeDateTime =
                  getDateTimeFromEpochTime(model!.noteDate ?? "")!;
              _serviceType.text = DateFormat("dd-MM-yyyy").format(
                serviceTypeDateTime,
              );

              _subject.text = model!.subject ?? "";

              _disscription.text = model!.description ?? "";
              _assesmentScale = (model!.asessmentScale ?? 0).toString();
              _assesment_comment.text = model!.asessmentComment ?? "";
              clientRating = int.parse(model!.clientRating ?? "3");
              // print("models.length : ${dataList.length}");
            }
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

  getClientSignatureData(String imageName) async {
    // userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': widget.userId.toString(),
      'clientSignature': imageName,
    };
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endGetClientSignature, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          removeOverlay();
          if (response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponse $jResponse");
            signatureModel = jResponse
                .map((e) => ClientSignatureModel.fromJson(e))
                .toList()[0];
            if (signatureModel != null) {
              try {
                signatureImage = const Base64Decoder().convert(
                    (signatureModel!.clientsignature ?? "")
                        .replaceAll("data:image/png;base64,", ""));
              } catch (e) {
                log("IMAGECONVERTERROR : $e");
              }
            }
            setState(() {});
          }
          /*else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }*/
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

  getNoteDocs(DateTime noteDate, String clientName, int noteid) async {
    Map<String, dynamic> params = {
      'NoteDate': DateFormat("dd/MM/yy").format(noteDate),
      'clientName': clientName,
      'noteid': noteid.toString(),
    };
    print("paramsendGetNoteDocs : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url:
                "https://$baseUrl/$nestedUrl$endGetNoteDocs?NoteDate=${DateFormat("dd/MM/yy").format(noteDate)}&clientName=$clientName&noteid=${noteid.toString()}",
            //getUrl(endGetNoteDocs, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          removeOverlay();
          if (response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponseGetNoteDocs $jResponse");
            noteDocList =
                jResponse.map((e) => NoteDocModel.fromJson(e)).toList();
            // if (noteDocModel != null) {
            //   try {
            //     for (NoteDocModel model in noteDocModel!) {
            //       getNoteImage64(model);
            //     }
            //   } catch (e) {
            //     log("IMAGECONVERTERROR : $e");
            //   }
            // }
            setState(() {});
          }
          /*else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }*/
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

  getNoteImage64(NoteDocModel model) async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': widget.userId.toString(),
      'imageName': model.name, //"957-Bump96-161023-1.jpg",
      'imagePath': model.path != null && model.path!.isNotEmpty
          ? model.path!.toString()
          : "${widget.clientId}/notespic/",
    };
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endGetImageBase64, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          removeOverlay();
          if (response != "") {
            // print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponse $jResponse");
            signatureModel = jResponse
                .map((e) => ClientSignatureModel.fromJson(e))
                .toList()[0];
            if (signatureModel != null &&
                signatureModel!.noteImagebase64 != null &&
                signatureModel!.noteImagebase64 != "null") {
              try {
                noteDocImage = const Base64Decoder().convert(
                    (signatureModel!.noteImagebase64 ?? "")
                        .replaceAll("data:image/png;base64,", ""));
                setState(() {});
              } catch (e) {
                log("IMAGECONVERTERROR : $e");
              }
            }
            setState(() {});
          }
          /*else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }*/
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
    // print("noteDocModel: ${noteDocModel!.length}");
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: colorLiteBlueBackGround,
      appBar: buildAppBar(context, title: "Progress Notes Detail"),
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
                        fontSize: 12,
                        onTap: () async {
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
                        fontSize: 12,
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
                text: "Service Schedule Client ${widget.serviceName ?? ""}",
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
              ThemedText(
                text: "Client Signature",
                color: colorFontColor,
                fontSize: 18,
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
                    /*Expanded(
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Save",
                        fontSize: 12,
                        onTap: () async {
                          await saveNoteApiCall();
                          for (File file in selectedImageFilesList) {
                            saveNoteDoc(file);
                          }
                        },
                      ),
                    ),*/
                    const Spacer(),
                    const SizedBox(width: spaceHorizontal),
                    SizedBox(
                      width: 100,
                      height: textFiledHeight,
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Clear",
                        fontSize: 12,
                        onTap: () {
                          _controllerSignature.clear();
                        },
                      ),
                    ),
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
                        title: "Capture Image From Camera",
                        fontSize: 12,
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              /*insetPadding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: boxBorderRadius,
                                    ),*/
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
                        fontSize: 12,
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
  }

  saveNoteDoc(File image) async {
    print("UPLOADING : ${image.path}");

    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          Response response = await http.post(
            Uri.parse(
                "https://mycare-web.mycaresoftware.com/MobileAPI/v1.asmx/saveNotePicture"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "noteId": widget.noteId.toString(),
              "NoteDate": DateFormat("dd/MM/yy").format(serviceTypeDateTime),
              "clientName": "${widget.clientName}",
              "noteimageurl":
                  "data:image/png;base64, ${base64.encode(await image.readAsBytes())}",
            }),
          );
          print("responseImageUpload ${response.body}");
          if (response.statusCode == 200 || response.statusCode == 201) {
            var jResponse = json.decode(response.body.toString());
            var jrs = json.decode(jResponse["d"]);
            if (jrs["status"] == 1) {
              print("UPLOADED : ${image.path} Success");
              showSnackBarWithText(_keyScaffold.currentState, "Upload Success",
                  color: colorGreen);
              if (selectedImageFilesList.indexOf(image) ==
                  selectedImageFilesList.length - 1) {
                Navigator.pop(context, true);
              }
            }
          } else {
            print("UPLOADED : ${image.path} failed");
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

  deleteNoteDoc(String imageName) async {
    print("UPLOADING : $imageName");
    if (model != null) {
      isConnected().then((hasInternet) async {
        if (hasInternet) {
          try {
            getOverlay(context);
            Response response = await http.get(Uri.parse(
                "https://mycare-web.mycaresoftware.com/MobileAPI/v1.asmx/$endDeleteNotePicture?fileName=$imageName&clientId=${widget.clientId.toString()}"));
            print("responseDELETERESPONSE ${response.body}");
            if (response.statusCode == 200 || response.statusCode == 201) {
              var jResponse = json.decode(
                  stripHtmlIfNeeded(response.body.toString()).toString());
              if (jResponse["status"] == 1) {
                print("DELETED : $imageName Success");
                if (model != null && model!.noteID != 0) {
                  getNoteDocs(getDateTimeFromEpochTime(model!.noteDate ?? "")!,
                      widget.clientName ?? " ", model!.noteID ?? 0);
                }
                showSnackBarWithText(_keyScaffold.currentState, "Success",
                    color: colorGreen);
              }
            } else {
              print("DELETED : $imageName failed");
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
          showSnackBarWithText(
              _keyScaffold.currentState, stringErrorNoInterNet);
        }
      });
    }
  }
}
