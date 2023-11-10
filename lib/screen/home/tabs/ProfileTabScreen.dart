import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rcare_2/network/ApiUrls.dart';
import 'package:rcare_2/screen/home/models/ProfileModel.dart';
import 'package:rcare_2/screen/login/ChangePassword.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../../Network/API.dart';
import '../../../utils/ConstantStrings.dart';
import '../../../utils/Preferences.dart';
import '../../../utils/methods.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final GlobalKey<FormState> _keyFormField = GlobalKey<FormState>();

  ///  * [_keyForgotFormField], key of form of forgot dialog form.
  final GlobalKey<FormState> _keyForgotFormField = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();

  final TextEditingController _controllerSuburb = TextEditingController();
  final TextEditingController _controllerHomePhone = TextEditingController();
  final TextEditingController _controllerMobile = TextEditingController();
  final TextEditingController _controllerWorkPhone = TextEditingController();
  final TextEditingController _controllerUserName = TextEditingController();

  ProfileModel? _profileModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfileApiCall();
  }

  _getProfileApiCall() async {
    // String acctype=""+ await Preferences().getPrefString(Preferences.prefAccountType);
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
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endEmployeeProfile, params: params).toString(),
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
            print('Profile ${jResponse}');
            List<ProfileModel> dataList =
                jResponse.map((e) => ProfileModel.fromJson(e)).toList();

            print('res $dataList');

            if (dataList.isNotEmpty) {
              _profileModel = dataList[0];
              print("DATA : ${dataList[0].fullname}");
              // userName = _profileModel!.fullname ?? "";
              _controllerFirstName.text = _profileModel!.firstName ?? "";
              _controllerLastName.text = _profileModel!.lastName ?? "";
              _controllerEmail.text = _profileModel!.email ?? "";
              _controllerHomePhone.text = _profileModel!.homePhone ?? "";
              _controllerWorkPhone.text = _profileModel!.workPhone ?? "";
              _controllerSuburb.text =
                  "${_profileModel!.city ?? ""} ${_profileModel!.state ?? ""} ${_profileModel!.postalCode ?? ""}";
              _controllerAddress.text = _profileModel!.address ?? "";
              _controllerMobile.text = _profileModel!.mobileNo ?? "";
              _controllerUserName.text = _profileModel!.userName ?? "";

            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, "Data Not Available!");
            }
            // if (responseModel.status == 1) {
            //   print('res success');
            //
            // } else {
            //   showSnackBarWithText(
            //       _keyScaffold.currentState, jResponse['Message']);
            // }
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
      appBar: buildAppBar(context, title: "Profile"),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Image.network(
                                            "https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1699430153~exp=1699430753~hmac=a141c1497a8aa23749636014e4fea408c3db11ac12fef8513708e0995fa26bcc",
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                  color: colorGrey33);
                                            },
                                          ),
                                        ),
                                        ThemedText(
                                          text: "Upload",
                                          color: colorBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        ThemedText(
                                          text: "Picture",
                                          color: colorBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
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
                                        ThemedRichText(
                                          spanList: [
                                            getTextSpan(
                                              text: "First Name",
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
                                          height: textFiledHeight,
                                          child: ThemedTextField(
                                            borderColor: colorGreyBorderD3,
                                            controller: _controllerFirstName,
                                            backgroundColor: colorWhite,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: spaceHorizontal),
                                          ),
                                        ),
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
                                text: "Email Address",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
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
                              ThemedText(
                                text: "Home Phone",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerHomePhone,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Mobile No",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerMobile,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Work Phone No",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  controller: _controllerWorkPhone,
                                  borderColor: colorGreyBorderD3,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  backgroundColor: colorWhite,
                                ),
                              ),
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
                                        controller: _controllerUserName,
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: spaceHorizontal,
                      ),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ThemedButton(
                                title: "Cancel",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                padding: EdgeInsets.zero,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(width: spaceHorizontal / 2),
                            Expanded(
                              child: ThemedButton(
                                title: "Save",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                padding: EdgeInsets.zero,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
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
}
