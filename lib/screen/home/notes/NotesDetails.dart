import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/notes/model/ClientSignatureModel.dart';
import 'package:signature/signature.dart';

import '../../../Network/API.dart';
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
  final int noteId;
  String? clientName;
  final String serviceName;

  ProgressNoteDetails({
    super.key,
    /* required this.model,*/ required this.userId,
    required this.noteId,
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
    exportBackgroundColor: Colors.grey,
  );

  ProgressNoteListByNoteIdModel? model;
  ClientSignatureModel? signatureModel;
  NoteDocModel? noteDocModel;
  Uint8List? signatureImage;
  Uint8List? noteDocImage;
  File? imageFile;
  int? clientRating;

  @override
  void initState() {
    /*serviceTypeDateTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(model.noteDate!
                .replaceAll("/Date(", "")
                .replaceAll(")/", "")),
            isUtc: false)
        .add(
      const Duration(hours: 5, minutes: 30),
    );
    _serviceType.text = DateFormat("dd-MM-yyyy").format(
      serviceTypeDateTime,
    );

    _subject.text = widget.model.subject ?? "";

    _disscription.text = widget.model.description ?? "";
    _assesmentScale = widget.model.assessmentScale ?? "";
    _assesment_comment.text = widget.model.assessmentComment ?? "";*/
    super.initState();
    getData();
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
          if (response != null && response != "") {
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
                getNoteDocs(getDateTime(model!.noteDate ?? ""),
                    widget.clientName ?? " ", model!.noteID ?? 0);
              }
              serviceTypeDateTime = DateTime.fromMillisecondsSinceEpoch(
                      int.parse(model!.noteDate!
                          .replaceAll("/Date(", "")
                          .replaceAll(")/", "")),
                      isUtc: false)
                  .add(
                const Duration(hours: 5, minutes: 30),
              );
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
          if (response != null && response != "") {
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
    print("params : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endGetNoteDocs, params: params).toString(),
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
            noteDocModel =
                jResponse.map((e) => NoteDocModel.fromJson(e)).toList()[0];
            if (noteDocModel != null) {
              try {
                getNoteImage64(
                    noteDocModel!.name ?? "", noteDocModel!.path ?? "");
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

  getNoteImage64(String imageName, String imagePath) async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': widget.userId.toString(),
      'imageName': imageName, //"957-Bump96-161023-1.jpg",
      'imagePath': imagePath.isEmpty ? "96/notespic/" : imagePath,
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
          if (response != null && response != "") {
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
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: colorLiteBlueBackGround,
      appBar: buildAppBar(context, title: "Progress Notes Detail"),
      body: model != null
          ? SingleChildScrollView(
              child: Container(
                color: colorWhite,
                margin: const EdgeInsets.symmetric(
                    horizontal: spaceHorizontal, vertical: spaceVertical),
                padding: const EdgeInsets.symmetric(
                    vertical: spaceVertical * 1.5,
                    horizontal: spaceHorizontal * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedText(
                      text:
                          "Service Schedule Client ${widget.serviceName ?? ""}",
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: colorWhite,
                        isReadOnly: true,
                        onTap: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: serviceTypeDateTime,
                                  firstDate:
                                      DateTime(serviceTypeDateTime.year - 23),
                                  lastDate:
                                      DateTime(serviceTypeDateTime.year + 23))
                              .then((value) {
                            if (value != null) {
                              setState(() {
                                serviceTypeDateTime = value;
                                _serviceType.text =
                                    DateFormat("dd-MM-yyyy").format(
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
                        padding:
                            EdgeInsets.symmetric(horizontal: spaceHorizontal),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: spaceHorizontal),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: spaceHorizontal),
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
                          Expanded(
                            child: ThemedButton(
                              padding: EdgeInsets.zero,
                              title: "Save",
                              fontSize: 12,
                              onTap: () async {
                                await saveNoteApiCall();
                                saveNoteDoc();
                              },
                            ),
                          ),
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
                                            final ImagePicker picker =
                                                ImagePicker();
                                            final XFile? image =
                                                await picker.pickImage(
                                              source: ImageSource.camera,
                                              imageQuality: 30,
                                            );
                                            if (image != null) {
                                              setState(() {
                                                print(image.path);
                                                imageFile = File(image.path);
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
                                            final ImagePicker picker =
                                                ImagePicker();
                                            final XFile? image =
                                                await picker.pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 30,
                                            );
                                            if (image != null) {
                                              setState(() {
                                                print(image.path);
                                                imageFile = File(image.path);
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
                    if (noteDocImage != null)
                      SizedBox(
                        height: 200,
                        width: 300,
                        child: Image.memory(noteDocImage!),
                      ),
                    if (imageFile != null)
                      SizedBox(
                        height: 200,
                        width: 300,
                        child: Image.file(imageFile!),
                      ),
                  ],
                ),
              ),
            )
          : buildNoDataAvailable("Data Not Available!"),
    );
  }

  saveNoteApiCall() async {
    if (model != null) {
      Map<String, dynamic> params = <String, dynamic>{
        'NoteID': widget.noteId.toString(),
        "NoteDate": DateFormat("yyyy/MM/dd").format(serviceTypeDateTime),
        "AssessmentScale": "'${_assesmentScale.toString()}'",
        "AssessmentComment":
            _assesment_comment.text.isEmpty ? "null" : _assesment_comment.text,
        "Description":
            _disscription.text.isNotEmpty ? _disscription.text : "null",
        "Subject": _subject.text,
        "img": "null",
        //noteDocImage != null ? base64.encode(noteDocImage!) : "null",
        "userID": widget.userId.toString(),
        "clientID": model!.clientID != null ? model!.clientID!.toString() : "0",
        "ServiceScheduleClientID": model!.serviceScheduleClientID != null
            ? model!.serviceScheduleClientID!.toString()
            : "0",
        "bit64Signature": (await _controllerSignature.toPngBytes()) != null
            ? base64.encode((await _controllerSignature.toPngBytes())!)
            : signatureImage,
        "ClientRating": clientRating.toString(),
        "ssClientIds": model!.serviceScheduleClientID != null
            ? model!.serviceScheduleClientID!.toString()
            : "0",
        "GroupNote": "null",
        "ssEmployeeID": "0",
      };

      print(params);
      isConnected().then((hasInternet) async {
        if (hasInternet) {
          var response;
          HttpRequestModel request = HttpRequestModel(
              url: getUrl(endSaveNoteDetails, params: params).toString(),
              //endSaveEmployeeProfile,
              authMethod: '',
              body: '',
              headerType: '',
              params: "",
              //params.toString(),
              method: 'GET');

          try {
            getOverlay(context);
            response = await HttpService().init(request, _keyScaffold);
            print("response $response");
            if (response != null && response != "") {
              var jResponse = json.decode(response.toString());
              if (jResponse["status"] == 1) {
                showSnackBarWithText(_keyScaffold.currentState, "Success");
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
          showSnackBarWithText(
              _keyScaffold.currentState, stringErrorNoInterNet);
        }
      });
    }
  }

  saveNoteDoc() async {
    if (model != null && imageFile != null) {
      // print("base64 : ${base64.encode(await imageFile!.readAsBytes())}");
      Map<String, dynamic> params = <String, dynamic>{
        'noteID': "957",//widget.noteId.toString(),
        "NoteDate": "16/10/23",//DateFormat("dd/MM/yy").format(serviceTypeDateTime),
        "clientName": "Bump, Donald - 00096",//"${widget.clientName}",
        "noteimageurl": imageFile != null
            ? "data:image/png;base64,${base64.encode(await imageFile!.readAsBytes())}"
            : "null",
      };

      print(params);
      isConnected().then((hasInternet) async {
        if (hasInternet) {
          var response;
          HttpRequestModel request = HttpRequestModel(
              url: /*getUrl(*/
                  endSaveNotePicture /*, params: params).toString()*/,
              //endSaveEmployeeProfile,
              authMethod: '',
              body: '',
              headerType: '',
              params: params.toString(),
              //params.toString(),
              method: 'POST');

          try {
            getOverlay(context);
            response = await HttpService().init(request, _keyScaffold);
            print("response $response");
            if (response != null && response != "") {
              var jResponse = json.decode(response.toString());
              if (jResponse["status"] == 1) {
                showSnackBarWithText(_keyScaffold.currentState, "Success");
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
          showSnackBarWithText(
              _keyScaffold.currentState, stringErrorNoInterNet);
        }
      });
    }
  }
}
