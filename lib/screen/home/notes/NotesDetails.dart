import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/notes/model/ClientSignatureModel.dart';
import 'package:rcare_2/screen/home/notes/model/ServiceDetail.dart';
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
import '../models/GroupServiceResponseModel.dart';
import '../models/ProgressNoteListByNoteIdModel.dart';
import '../models/ProgressNoteModel.dart';
import 'model/NoteDocModel.dart';

class ProgressNoteDetails extends StatefulWidget {
  // final ProgressNoteModel model;
  final int userId;
  final int clientId;
  int noteId;
  final int serviceShceduleClientID;
  final int servicescheduleemployeeID;
  String? clientName;
  String serviceName;
  String noteWriter;
  DateTime serviceDate;
  List<GroupServiceModel>? selectedGroupServiceList = [];


  ProgressNoteDetails({
    super.key,
    this.clientName,
    this.selectedGroupServiceList,
    required this.noteId,
    required this.userId,
    required this.clientId,
    required this.serviceShceduleClientID,
    required this.servicescheduleemployeeID,
    required this.serviceName,
    required this.noteWriter,
    required this.serviceDate,
  });

  @override
  State<ProgressNoteDetails> createState() => _ProgressNoteDetailsState();
}

class _ProgressNoteDetailsState extends State<ProgressNoteDetails> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  DateTime serviceTypeDateTime = DateTime.now();
  int userId = 0;
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
  ServiceDetail? serviceDetail;
  ClientSignatureModel? signatureModel;
  List<NoteDocModel>? noteDocList;
  Uint8List? signatureImage;
  Uint8List? noteDocImage;
  List<File> selectedImageFilesList = [];
  int? clientRating;
  String imgPath = "";

  bool isPast = false;
  bool allowEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != 0) {
      if (widget.noteWriter.isEmpty) {
        getServiceDetail();
      } else {
        getData();
      }
    } else {
      //Fill model with defalt value and save with noteid = 0
      allowEdit = true;
      final now = DateTime.now();
      serviceTypeDateTime = DateTime(now.year, now.month, now.day);

      model = ProgressNoteListByNoteIdModel();
      clientRating = 0;
      model?.subject = "Progress Note";
      _subject.text = model!.subject ?? "";
      _serviceType.text = DateFormat("dd-MM-yyyy").format(
        serviceTypeDateTime,
      );
      getServiceDetail();
    }
  }

  getServiceDetail() async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': widget.userId.toString(),
      'ServiceScheduleClientID': widget.serviceShceduleClientID.toString(),
      'ssEmpID': widget.servicescheduleemployeeID.toString(),
    };
    print("getServiceDetail : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(ServiceDetaileByID, params: params).toString(),
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
            List<ServiceDetail> serivceList = [];

            List jResponse = json.decode(response);
            print("jResponse $endAvailableShifts $jResponse");
            serivceList =
                jResponse.map((e) => ServiceDetail.fromJson(e)).toList();
            print("availableDataList : ${serivceList.length}");
            if (serivceList.isNotEmpty) {
              serviceDetail = serivceList.first;
            }

            if (serviceDetail != null && widget.noteId != 0) {
              if (this.serviceDetail != null) {
                final serviceDetail = this.serviceDetail;
                print(serviceDetail?.createdByName);
                model?.createdByName = serviceDetail?.createdByName;
                widget.serviceName = serviceDetail!.serviceName!;
                widget.noteWriter = serviceDetail!.createdByName!;
              }
              getData();
            } else {
              if (this.serviceDetail != null) {
                final serviceDetail = this.serviceDetail;
                print(serviceDetail?.createdByName);
                model?.createdByName = serviceDetail?.createdByName;
                widget.serviceName = serviceDetail!.serviceName!;
                widget.noteWriter = serviceDetail!.createdByName!;
              }
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

  getData() async {
    // userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    userId = await Preferences().getPrefInt(Preferences.prefUserID) as int;
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
            print(userId);
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

              isPast = widget.serviceDate.isPassed;
              allowEdit = (model!.createdBy ?? userId) == userId;
              print("isPast : $allowEdit");
              print("isPast : $isPast");

              _subject.text = model!.subject ?? "";

              _disscription.text = model!.description ?? "";
              _assesmentScale = (model!.asessmentScale ?? 0).toString();
              _assesment_comment.text = model!.asessmentComment ?? "";

              if(model!.clientRating == null || model!.clientRating!.isEmpty){
                model!.clientRating = "0";
              }

              clientRating = int.parse(model!.clientRating ?? "0");
              print("isPast : $clientRating");
              if (this.serviceDetail != null) {
                final serviceDetail = this.serviceDetail;
                model?.createdByName = serviceDetail?.createdByName;
                widget.serviceName = serviceDetail!.serviceName!;
              }

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
            //  print("jResponse $jResponse");
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
    var uri =  "https://$baseUrl/$nestedUrl$endGetNoteDocs?NoteDate=${DateFormat("dd/MM/yy").format(noteDate)}&clientName=$clientName&noteid=${noteid.toString()}";
    var encoded = Uri.encodeFull(uri);
    print("paramsendGetNoteDocs : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url:encoded,
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
            //  print("jResponseGetNoteDocs $jResponse");
            noteDocList =
                jResponse.map((e) => NoteDocModel.fromJson(e)).toList();

            setState(() {});
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

  /*
  'imagePath': model.path != null && model.path!.isNotEmpty
          ? model.path!.toString()
          : "${widget.clientId}/notespic/",
   */

  getNoteImage64(NoteDocModel model) async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'imageName': model.name, //"957-Bump96-161023-1.jpg",
      'imagePath': "${widget.clientId}/notespic/",
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
                    if (allowEdit) Expanded(
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Save",
                        fontSize: 14,
                        onTap: () async {
                          if (_disscription.text.isEmpty) {
                            showSnackBarWithText(_keyScaffold.currentState,
                                "Description can not be blank",
                                color: colorRed);
                            return;
                          }
                          if(isGroupNote()){
                            await saveNoteGroupApiCall();
                          }
                          else{
                            await saveNoteApiCall();
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
                text: "Service Schedule Client ${widget.serviceName ?? ""}",
                color: colorFontColor,
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text:
                    "Note Writer : ${model?.createdByName ?? widget.noteWriter}",
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
                  isEnable: !isPast && allowEdit,
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: serviceTypeDateTime,
                      firstDate: DateTime(serviceTypeDateTime.year - 23),
                      lastDate: DateTime.now(),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          serviceTypeDateTime =
                              DateTime(value.year, value.month, value.day);
                          ;
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: !allowEdit,
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
                    const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                minLine: 4,
                maxLine: 4,
                borderColor: colorGreyBorderD3,
                labelTextColor: colorBlack,
                backgroundColor: colorWhite,
                isReadOnly: !allowEdit,
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
                isDisabled: !allowEdit,
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
                text: "Assessment Comments",
                color: colorFontColor,
                fontSize: 18,
              ),
              ThemedTextField(
                padding:
                    const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                borderColor: colorGreyBorderD3,
                backgroundColor: colorWhite,
                isReadOnly: !allowEdit,
                minLine: 3,
                maxLine: 3,
                controller: _assesment_comment,
              ),
              if (widget.selectedGroupServiceList == null ||
                  widget.selectedGroupServiceList!.isEmpty)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: spaceVertical),
                    (allowEdit  && signatureImage == null && widget.serviceDate.isToday)
                        ? Row(children: [
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
                          ])
                        : Row(children: [
                            ThemedText(
                              text: "Client Signature",
                              color: colorFontColor,
                              fontSize: 18,
                            ),
                          ]),
                    Container(
                      width: 300,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorGreyBorderD3),
                      ),
                      child: signatureImage != null
                          ? Image.memory(signatureImage!)
                          : widget.serviceDate.isToday && allowEdit
                              ? Signature(
                                  backgroundColor: Colors.white,
                                  controller: _controllerSignature,
                                  width: 300,
                                  height: 180,
                                )
                              : null,
                    ),
                    const SizedBox(height: spaceVertical),
                    if ( allowEdit && clientRating == 0 &&
                        widget.serviceDate.isToday)
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
                  ],
                ),
              const SizedBox(height: spaceVertical),
              SizedBox(
                height: textFiledHeight,
                child: Row(
                  children: [
                    if (!isGroupNote() && allowEdit)
                      Expanded(
                        child: ThemedButton(
                          padding: EdgeInsets.zero,
                          title: "Add Image",
                          fontSize: 14,
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
                                          imageQuality: 10,
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
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final List<XFile> image =
                                            await picker.pickMultiImage(
                                          imageQuality: 10,
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
                    if (isGroupNote() == false)
                      const SizedBox(width: spaceHorizontal),

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
                    //  getNoteImage64(noteDocList![index]);
                      imgPath = "";
                      String path = (noteDocList![index].path ?? "");

                      String imageName = noteDocList![index].name ?? "";
                      https://mycare.mycaresoftware.com/Uploads/client/108/notespic/1106-Bob108-211223-1.jpg
                      https://mycare.mycaresoftware.com/Uploads/client/notes/96/notespic/1121-Bump96-211223-2.jpg
                    //  $mainUrl$endDeleteNotePicture?fileName=$imageName&clientId=${widget.clientId.toString()}"
                      if(path.isNotEmpty){
                        imgPath = path+"/"+model!.clientID.toString()+"/notespic/"+imageName;
                        print(imgPath);
                        setState(() {

                        });
                      }

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [

                          ThemedText(text: noteDocList![index].name ?? ""),
                          if (allowEdit) IconButton(
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
              if (imgPath.isNotEmpty)
                SizedBox(
                  height: 200,
                  width: 300,
   // https://mycare.mycaresoftware.com/Uploads/client/notes
                  child: Image.network(imgPath),

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

  bool isGroupNote() {
    return widget.selectedGroupServiceList != null &&  widget.selectedGroupServiceList!.isNotEmpty;
  }

  saveNoteApiCall() async {
    closeKeyboard();
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        String noteIds = "";
        String clientId = "";
        String serviceScheduleClientId = "";
        String ssEmployeeId = "";

          noteIds = (model!.noteID ?? 0).toString();
          serviceScheduleClientId = widget.serviceShceduleClientID.toString();
          clientId = widget.clientId.toString();
          ssEmployeeId = widget.servicescheduleemployeeID.toString();


        try {
          getOverlay(context);
          // response = await HttpService().init(request, _keyScaffold);
          Uint8List? signature = await _controllerSignature.toPngBytes();
          String stri =
              "iVBORw0KGgoAAAANSUhEUgAAASwAAACWCAYAAABkW7XSAAAABGdBTUEAALGPC/xhBQAAAPNJREFUeF7t1MEJgDAQRNHtvylLsYQcPYianETCBvQk6HvwOxgmAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgC84pEv7g7abrV3LoNI1t6YWnLLR6r9lxzQqO6cshwUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADviKj9UU7A+mOSSQAAAABJRU5ErkJggg==";
          String strBody = json.encode({
            "NoteID": noteIds,
            "NoteDate": DateFormat("yyyy/MM/dd").format(DateTime.now()),
            "AssessmentScale": _assesmentScale.toString(),
            "AssessmentComment":
                _assesment_comment.text.isEmpty ? "" : _assesment_comment.text,
            "Description":
                _disscription.text.isNotEmpty ? _disscription.text : "",
            "Subject": _subject.text,
            "img": 0,
            "userID": (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
            "clientID": clientId,
            "ServiceScheduleClientID": serviceScheduleClientId,
            "bit64Signature": _controllerSignature.isNotEmpty
                ? (signature != null ? "${base64.encode(signature)}" : "")
                : "",
            "ClientRating": clientRating.toString(),
            "ssClientIds": "",
            "GroupNote": 0,
            "ssEmployeeID": ssEmployeeId,
          });
          log(strBody);
          if (strBody.isEmpty) {
            return;
          }

          Response response = await http.post(
            Uri.parse("$mainUrl$endSaveNoteDetails"),
            headers: {"Content-Type": "application/json"},
            body: strBody,
          );
          log("response ${response.body} ${response.request}}");
          if (response != "") {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
              widget.noteId = int.parse(jres["message"]);

              print("Response : savedetail with =  ${widget.noteId}");
              showSnackBarWithText(_keyScaffold.currentState, "Success",
                  color: colorGreen);
              if (selectedImageFilesList.isEmpty) {
                Navigator.pop(context, true);
              } else {
                for (File file in selectedImageFilesList) {
                  await saveNoteDoc(file);
                }
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

  saveNoteGroupApiCall() async {
    closeKeyboard();
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        String noteIds = "";
        String clientId = "";
        String serviceScheduleClientId = "";
          noteIds = "0";
          for (GroupServiceModel model in widget.selectedGroupServiceList!) {
            if (model.noteID != null) {
              clientId +=
              "${clientId.isNotEmpty ? "," : ""}${model.rESID ?? "0"}";
              serviceScheduleClientId +=
              "${serviceScheduleClientId.isNotEmpty ? "," : ""}${model.servicescheduleCLientID ?? "0"}";
            }
          }
        try {
          getOverlay(context);
          // response = await HttpService().init(request, _keyScaffold);

          String strBody = json.encode({
            'auth_code': (await Preferences().getPrefString(Preferences.prefAuthCode)),
            "NoteID": 0,
            "NoteDate": DateFormat("yyyy/MM/dd").format(DateTime.now()),
            "AssessmentScale": _assesmentScale.toString(),
            "AssessmentComment": _assesment_comment.text.isEmpty ? "" : _assesment_comment.text,
            "Description": _disscription.text.isNotEmpty ? _disscription.text : "",
            "Subject": _subject.text,
            "userID":  (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
            "ssClientIds": serviceScheduleClientId,
            "ssEmployeeID": widget.servicescheduleemployeeID.toString(),
          });
          log(strBody);
          if (strBody.isEmpty) {
            return;
          }

          Response response = await http.post(
            Uri.parse("$mainUrl$saveNoteDetailsForGroup"),
            headers: {"Content-Type": "application/json"},
            body: strBody,
          );
          log("response ${response.body} ${response.request}}");
          if (response != "") {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
            //  widget.noteId = int.parse(jres["message"]);

           //   print("Response : savedetail with =  ${widget.noteId}");
              showSnackBarWithText(_keyScaffold.currentState, "Note created successfully",
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


  saveNoteDoc(File image) async {
    print("API : saveNoteDoc with =  ${widget.noteId}");
    print("UPLOADING : ${image.path}");

    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          Response response = await http.post(
            Uri.parse("$mainUrl$endSaveNotePicture"),
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

              if (selectedImageFilesList.indexOf(image) ==
                  selectedImageFilesList.length - 1) {
                showSnackBarWithText(
                    _keyScaffold.currentState, "Upload Success",
                    color: colorGreen);
                await Future.delayed(const Duration(seconds: 4));
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
                "$mainUrl$endDeleteNotePicture?fileName=$imageName&clientId=${widget.clientId.toString()}"));
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

  bool get isPassed {
    final now = DateTime.now();
    if (year < now.year) {
      return true;
    } else if (month < now.month) {
      return true;
    } else if (day < now.day) {
      return true;
    } else {
      return false;
    }
  }

  bool get isFutureDate {
    final now = DateTime.now();
    if (year > now.year) {
      return true;
    } else if (month > now.month) {
      return true;
    } else if (day > now.day) {
      return true;
    } else {
      return false;
    }
  }
}
