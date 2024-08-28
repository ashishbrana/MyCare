import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/ClientHome/model/RequestModel/ClientProfileRequest.dart';
import 'package:rcare_2/screen/login/ChangePassword.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../../appconstant/API.dart';
import '../../../appconstant/ApiUrls.dart';
import '../../../appconstant/GlobalMethods.dart';
import '../../../utils/ConstantStrings.dart';
import '../../../utils/Preferences.dart';
import '../../../utils/methods.dart';
import 'model/ClientProfile.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final GlobalKey<FormState> _keyFormField = GlobalKey<FormState>();

  ///  * [_keyForgotFormField], key of form of forgot dialog form.
  final GlobalKey<FormState> _keyForgotFormField = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPrefName = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerAddress1 = TextEditingController();

  final TextEditingController _controllerSuburb = TextEditingController();
  final TextEditingController _controllerState = TextEditingController();
  final TextEditingController _controllerPincode = TextEditingController();

  final TextEditingController _controllerHomePhone = TextEditingController();
  final TextEditingController _controllerMobile = TextEditingController();
  final TextEditingController _controllerWorkPhone = TextEditingController();
  final TextEditingController _controllerUserName = TextEditingController();
  final TextEditingController _controllerServiceDate = TextEditingController();

  final TextEditingController _controllerCareComments = TextEditingController();
  final TextEditingController _controllerClientNote = TextEditingController();

  final TextEditingController _controllerRiskComments = TextEditingController();

  ClientProfile? _profileModel;

  Uint8List? profileImage;
  late DateTime serviceDate;
  bool isValidEndDate = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfileApiCall();
  }

  _getProfileApiCall() async {
    var params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType':
          (await Preferences().getPrefInt(Preferences.prefAccountType))
              .toString(),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
    };
    isConnected().then((hasInternet) async {
      int accountType =
          await Preferences().getPrefInt(Preferences.prefAccountType);
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(
                    accountType == 2 ? endEmployeeProfile : endClientProfile,
                    params: params)
                .toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          if (response != null && response != "") {
            List jResponse = json.decode(response);
            // ProfileModel responseModel = ProfileModel.fromJson(jResponse);
            print('Profile $jResponse');
            List<ClientProfile> dataList =
                jResponse.map((e) => ClientProfile.fromJson(e)).toList();

            print('res $dataList');

            if (dataList.isNotEmpty) {
              _profileModel = dataList[0];
              print("DATA : ${dataList[0].fullname}");
              serviceDate = getDateTimeFromEpochTime(
                  _profileModel?.endofServiceDate ?? "")!;
              isValidEndDate =  (serviceDate.year) < 2900;
              _controllerFirstName.text = _profileModel!.firstName ?? "";
              _controllerLastName.text = _profileModel!.lastName ?? "";
              _controllerEmail.text = _profileModel!.remail ?? "";
              _controllerPrefName.text = _profileModel!.prefName ?? "";
              _controllerHomePhone.text = _profileModel!.homePhone ?? "";
              _controllerWorkPhone.text = _profileModel!.rmobilephone ?? "";
              _controllerSuburb.text = _profileModel!.city ?? "";
              _controllerState.text = _profileModel!.state ?? "";
              _controllerPincode.text = _profileModel!.pCode ?? "";

              _controllerAddress.text = _profileModel!.address1 ?? "";
              _controllerAddress1.text = _profileModel!.address2 ?? "";
              _controllerMobile.text = _profileModel!.mobilePhone ?? "";
              _controllerUserName.text = _profileModel!.userName ?? "";



              if (isValidEndDate) {
              _controllerServiceDate.text =
              DateFormat("dd-MM-yyyy").format(serviceDate);
              }
              else{
              _controllerServiceDate.text = "No End-Of-Service Date";
              }

              _controllerCareComments.text = _profileModel?.careComments ?? "";
              _controllerRiskComments.text =
                  _profileModel?.riskNotification ?? "";
              _controllerClientNote.text = _profileModel?.careNotesClient ?? "";

              try {
                profileImage = Base64Decoder().convert(
                    (_profileModel!.empProfilePic ?? "")
                        .replaceAll("data:image/png;base64,", ""));
              } catch (e) {
                log("IMAGECONVERTERROR : $e");
              }
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, "Data Not Available!");
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print('ERROR ${e}');
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
        appBar: buildAppBar(context, title: "Profile" , showActionButton: true , onActionButtonPressed: () {
      validateAndSaveProfile();
    },),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: colorLiteBlueBackGround,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: spaceHorizontal,
                              vertical: spaceVertical),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image =
                                            await picker.pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 30,
                                        );
                                        if (image != null) {
                                          setState(() {
                                            _saveProfileImage(File(image.path));
                                          });
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1 / 1,
                                            child: profileImage != null
                                                ? Image.memory(
                                                    profileImage!,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                          color: colorGrey33);
                                                    },
                                                  )
                                                : const Center(
                                                    child: Icon(Icons.person),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: spaceHorizontal),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: space),
                                        createThemedRichTextAndTextField(controller: _controllerFirstName, name: "First Name", isRequired: true),
                                        const SizedBox(height: space),
                                        ThemedRichText(
                                          spanList: [
                                            getTextSpan(
                                              text: "Last Name",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            getTextSpan(
                                              text: "*",
                                              fontSize: 14,
                                              fontColor: colorRed,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: spaceBetween),
                                        SizedBox(
                                          height: 45,
                                          child: ThemedTextField(
                                            isAcceptCharOnly: true,
                                            borderColor: colorGreyBorderD3,
                                            controller: _controllerLastName,
                                            backgroundColor: colorWhite,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: spaceHorizontal),
                                          ),
                                        ),
                                        const SizedBox(height: space),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Preferred Name",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  keyBoardType: TextInputType.emailAddress,
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerPrefName,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Email Address",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  keyBoardType: TextInputType.emailAddress,
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerEmail,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedRichText(
                                spanList: [
                                  getTextSpan(
                                    text: "Address",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  getTextSpan(
                                    text: "*",
                                    fontSize: 14,
                                    fontColor: colorRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerAddress,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedRichText(
                                spanList: [
                                  getTextSpan(
                                    text: "Suburb",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  getTextSpan(
                                    text: "*",
                                    fontSize: 14,
                                    fontColor: colorRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  controller: _controllerSuburb,
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
        Row(
          children: [
        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                              ThemedRichText(
                                spanList: [
                                  getTextSpan(
                                    text: "State",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  getTextSpan(
                                    text: "*",
                                    fontSize: 14,
                                    fontColor: colorRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
            const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  controller: _controllerState,
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
              ]
        )
        ),
            const SizedBox(width: spaceHorizontal / 2),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                              ThemedRichText(
                                spanList: [
                                  getTextSpan(
                                    text: "PostCode",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  getTextSpan(
                                    text: "*",
                                    fontSize: 14,
                                    fontColor: colorRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),

                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  controller: _controllerPincode,
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                  ]
              ),
            ),
          ]),
                              const SizedBox(height: space),
        Row(
          children: [
        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                              ThemedText(
                                text: "Home Phone",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  isAcceptNumbersOnly: true,
                                  keyBoardType: TextInputType.number,
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerHomePhone,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
          ]
        )
        ),

      const SizedBox(width: spaceHorizontal / 2),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                              ThemedText(
                                text: "Mobile No",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  isAcceptNumbersOnly: true,
                                  keyBoardType: TextInputType.number,
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerMobile,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              ]),),]),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "UserName",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: ThemedTextField(
                                        isReadOnly: true,
                                        controller: _controllerUserName,
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorGreyE8,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                      ),
                                    ),
                                    const SizedBox(width: spaceHorizontal / 2),
                                    Expanded(
                                      flex: 4,
                                      child: ThemedButton(
                                        title: "Change Password",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        padding: EdgeInsets.zero,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ChangePassword(),
                                              ));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: spaceVertical),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ThemedText(
                                        text: "Service End Date",
                                        fontSize: 14,
                                        color: colorBlack,
                                      ),
                                      SizedBox(
                                        height: textFiledHeight,
                                        child: ThemedTextField(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: spaceHorizontal),
                                          borderColor: colorGreyBorderD3,
                                          backgroundColor: colorGreyE8,
                                          sufFix: const Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            color: Colors.grey,
                                            size: 30.0,
                                          ),
                                          isReadOnly: true,
                                          hintText: "Select Date",
                                          controller: _controllerServiceDate,
                                        /* onTap: () {
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2101))
                                                .then((value) {
                                              if (value != null) {
                                                setState(() {
                                                  serviceDate = DateTime(
                                                      value.year,
                                                      value.month,
                                                      value.day);
                                                  ;
                                                  _controllerServiceDate.text =
                                                      DateFormat("dd-MM-yyyy")
                                                          .format(
                                                    serviceDate,
                                                  );
                                                });
                                              }
                                            });
                                          },*/
                                        ),
                                      ),
                                    ]),
                              ),
                              const SizedBox(height: spaceBetween),
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: "Client Notes",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              ThemedTextField(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: spaceHorizontal),
                                borderColor: colorGreyBorderD3,
                                backgroundColor: colorWhite,
                                maxLine: 5,
                                minLine: 5,
                                controller: _controllerClientNote,
                              ),
                              const SizedBox(height: spaceBetween),
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: "Care Comments",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: _profileModel?.careNotes ?? "",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorGrey88,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: "Client Goals",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: _profileModel?.clientGoals ?? "",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorGrey88,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: "Risk Notification",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              ThemedTextField(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: spaceHorizontal),
                                borderColor: colorGreyBorderD3,
                                backgroundColor: colorWhite,
                                maxLine: 5,
                                minLine: 5,
                                controller: _controllerRiskComments,
                              ),
                              const SizedBox(height: spaceBetween),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: spaceVertical),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createThemedRichTextAndTextField({
    TextEditingController? controller,
    required String name,
    required bool isRequired,
  }) {
    const double spaceBetween = 8.0;
    const double spaceHorizontal = 16.0;
    const Color colorWhite = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemedRichText(
          spanList: [
            getTextSpan(
              text: name,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            getTextSpan(
              text: "*",
              fontSize: 14,
              fontColor: colorRed,
            ),
          ],
        ),
        const SizedBox(height: spaceBetween),
        SizedBox(
          height: 45,
          child: ThemedTextField(
            isAcceptCharOnly: true,
            borderColor: colorGreyBorderD3,
            controller: controller,
            backgroundColor: colorWhite,
            padding: const EdgeInsets.symmetric(horizontal: spaceHorizontal),
          ),
        ),
      ],
    );
  }


  _saveProfileApiCall() async {
    if (_profileModel != null) {
      ClientProfileRequest request =
          ClientProfileRequest.createProfileRequest(_profileModel!);
      request.authCode =
          (await Preferences().getPrefString(Preferences.prefAuthCode));
      request.clientID = _profileModel!.clientID?.toInt() ?? 0;
      request.firstName = _controllerFirstName.text;
      request.lastName = _controllerLastName.text;
      request.address1 = _controllerAddress.text;
      request.address2 = _controllerAddress1.text;
      request.suburb = _controllerSuburb.text;
      request.homePhone = _controllerHomePhone.text;
      request.mobilePhone = _controllerMobile.text;
      request.email = _controllerEmail.text;
      request.endofServiceDate = DateFormat("dd/MM/yyyy").format(serviceDate!);
      request.riskNotification = _controllerRiskComments.text;
      request.careComments = _controllerClientNote.text;
      request.state = _controllerState.text;
      request.pCode = _controllerPincode.text;
      request.prefName = _controllerPrefName.text;

      String body = jsonEncode(request);

      // log("URL ${getUrl(endSaveEmployeeProfile)}");
      isConnected().then((hasInternet) async {
        if (hasInternet) {

          print(body);
          if (body.isEmpty) {
            return;
          }

          try {
            getOverlay(context);
            // response = await HttpService().init(request, _keyScaffold);
            Response response = await http.post(
                Uri.parse("$masterURL$endSaveClientProfile"),
                headers: {"Content-Type": "application/json"},
                body: body);
            print(
                "response $endSaveClientProfile ${response.body} ${response.request!.url.toString()}");
            if (response != null && response != "") {
              var jResponse =
                  json.decode(stripHtmlIfNeeded(response.body.toString()));
              var dResponse = json.decode(jResponse["d"]);
              if (dResponse["status"] == 1) {
                if(dResponse["message"] != null){
                  String message = dResponse["message"];
                  showSnackBarWithText(_keyScaffold.currentState, message,
                      color: colorGreen);
                }
                else {
                  showSnackBarWithText(_keyScaffold.currentState, "Profile saved successfully!",
                      color: colorGreen);
                }
              } else {
                String message = dResponse["message"];
                showSnackBarWithText(_keyScaffold.currentState, message,
                    color: colorRed);
              }
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, "Something went wrong!",
                  color: colorRed);
            }
            removeOverlay();
          } catch (e) {
            log("SignUp$e");
            removeOverlay();
            throw e;
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

  _saveProfileImage(File image) async {
    closeKeyboard();
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          Response response = await http.post(
            Uri.parse("${baseUrlWithHttp}MobileAPI/v1.asmx/SaveProfilePicForm"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              'auth_code':
                  (await Preferences().getPrefString(Preferences.prefAuthCode)),
              "EmployeeClientID": (_profileModel!.clientID ?? 0).toString(),
              "tableName": 'client',
              "ProfilePic": "${base64.encode(await image.readAsBytes())}",
            }),
          );
          print(response.body);
          print("responseImageUpload ${response.body}");
          if (response.statusCode == 200 || response.statusCode == 201) {
            var jResponse = json.decode(response.body.toString());
            var jrs = json.decode(jResponse["d"]);
            if (jrs["status"] == 1) {
              print("UPLOADED : $jrs Success");
              _getProfileApiCall();
            }
          } else {
            // print("UPLOADED : ${image.path} failed");
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
  validateAndSaveProfile(){
    if (_controllerFirstName.text
        .trim()
        .isEmpty) {
      showSnackBarWithText(
          _keyScaffold.currentState,
          "First name can not be blank!");
    } else if (_controllerLastName.text
        .trim()
        .isEmpty) {
      showSnackBarWithText(
          _keyScaffold.currentState,
          "Last name can not be blank!");
    } else if (_controllerAddress.text
        .trim()
        .isEmpty) {
      showSnackBarWithText(
          _keyScaffold.currentState,
          "Address can not be blank!");
    } else if (_controllerSuburb.text
        .trim()
        .isEmpty) {
      showSnackBarWithText(
          _keyScaffold.currentState,
          "Suburb filed can not be blank!");
    } else if (_controllerEmail.text
        .trim()
        .isEmpty) {
      showSnackBarWithText(
          _keyScaffold.currentState,
          "EmilId can not be blank!");
    } else if (!isValidateEmail(
        _controllerEmail.text)) {
      showSnackBarWithText(
          _keyScaffold.currentState,
          "Please enter valid email ID");
    } else {
      print("checkurl =$masterURL");
      _saveProfileApiCall();
    }
  }
}
