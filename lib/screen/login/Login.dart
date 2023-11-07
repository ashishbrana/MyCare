import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rcare_2/utils/ConstantStrings.dart';
import 'package:rcare_2/utils/Preferences.dart';

import '../../Network/API.dart';
import '../../Network/ApiUrls.dart';
import '../../Network/GlobalMethods.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/Constants.dart';
import '../../utils/Images.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import '../home/HomeScreen.dart';
import 'model/LoginResponseModel.dart';

class Login extends StatefulWidget {
  bool isLoginForBooking = false;

  Login({super.key, this.isLoginForBooking = false});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ///  * [_keyFormField], key of form of sign form.
  final GlobalKey<FormState> _keyFormField = GlobalKey<FormState>();

  ///  * [_keyForgotFormField], key of form of forgot dialog form.
  final GlobalKey<FormState> _keyForgotFormField = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  String? firebaseToken;
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerCompanyCode = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();

  _loginApiCall(String username, String password, String comapanyCode) {
    closeKeyboard();
    var params = {
      'username': username,
      'password': password,
      'companycode': comapanyCode,
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endLogin, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          if (response != null && response != "") {
            print('res ${response}');

            final jResponse = json.decode(response);
            LoginResponseModel responseModel =
                LoginResponseModel.fromJson(jResponse);
            print('res ${jResponse['status']}');
            if (responseModel.status == 1) {
              print('res success');
              Preferences().setPrefString(
                  Preferences.prefAuthCode, responseModel.authcode ?? "");
              Preferences().setPrefInt(
                  Preferences.prefAccountType, responseModel.accountType ?? 0);
              Preferences().setPrefInt(
                  Preferences.prefUserID, responseModel.userid ?? 0);
              Preferences().setPrefString(
                  Preferences.prefUserFullName, responseModel.fullName ?? "");
              sendToHome();
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, jResponse['Message']);
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          removeOverlay();
        } finally {
          removeOverlay();
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(
                '${Constants.imagePath}login_bg.png',
                fit: BoxFit.fitHeight,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // width: double/.infinity,
                      child: Image.asset(
                        '${Constants.imagePath}login_top.png',
                        fit: BoxFit.contain,
                        // height: MediaQuery.of(context).size.height ,
                        width: MediaQuery.of(context).size.width * .5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        color: Colors.white,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: spaceHorizontal),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 40, horizontal: spaceHorizontal),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Form(
                                  key: _keyFormField,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.grey.shade50,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ThemedTextField(
                                          borderColor: colorGreyBorderD3,
                                          controller: _controllerUsername,
                                          // hintText: "Username",
                                          labelText: "Username",
                                          labelFontWeight: FontWeight.w500,
                                          preFix: const FaIcon(
                                              FontAwesomeIcons.solidCircleUser,
                                              color: colorPrimary),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.trim().isEmpty) {
                                              return "Please enter Username!";
                                            }
                                          },
                                          backgroundColor:
                                              colorGreyExtraLightBackGround,
                                        ),
                                        const SizedBox(height: spaceVertical),
                                        ThemedTextField(
                                          borderColor: colorGreyBorderD3,
                                          controller: _controllerPassword,
                                          // hintText: "Password",
                                          labelText: "Password",
                                          labelFontWeight: FontWeight.w500,
                                          preFix: const FaIcon(
                                              FontAwesomeIcons.lock,
                                              color: colorPrimary),
                                          isPasswordTextField: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.trim().isEmpty) {
                                              return "Please enter password!";
                                            }
                                            if (value.length < 8 ||
                                                value.length > 15) {
                                              return "Please enter valid length(between 8 to 15) password!";
                                            }
                                          },
                                          backgroundColor:
                                              colorGreyExtraLightBackGround,
                                        ),
                                        const SizedBox(height: spaceVertical),
                                        ThemedTextField(
                                          borderColor: colorGreyBorderD3,
                                          controller: _controllerCompanyCode,
                                          // hintText: "Company Code",
                                          labelText: "Company Code",
                                          labelFontWeight: FontWeight.w500,
                                          preFix: const FaIcon(
                                              FontAwesomeIcons.key,
                                              color: colorPrimary),
                                          isPasswordTextField: false,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.trim().isEmpty) {
                                              return "Please enter company code!";
                                            }
                                          },
                                          backgroundColor:
                                              colorGreyExtraLightBackGround,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: spaceVertical),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MaterialButton(
                                      color: colorGreen,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const FaIcon(
                                              FontAwesomeIcons.powerOff,
                                              color: Colors.white),
                                          const SizedBox(width: 10),
                                          ThemedText(
                                            text: "Log In",
                                            color: colorWhite,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        if (_keyFormField.currentContext !=
                                                null &&
                                            _keyFormField.currentState!
                                                .validate()) {
                                          _loginApiCall(
                                              _controllerUsername.text.trim(),
                                              _controllerPassword.text.trim(),
                                              _controllerCompanyCode.text
                                                  .trim());
                                        }
                                        // sendToHome();
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // _buildForgotPassWordDialog();
                          },
                          child: const Text(
                            'FORGOT YOUR PASSWORD ?',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  sendToHome() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      },
    );
  }
}
