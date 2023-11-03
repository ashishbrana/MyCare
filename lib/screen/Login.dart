import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rcare_2/utils/ConstantStrings.dart';

import '../Network/API.dart';
import '../Network/ApiUrls.dart';
import '../Network/GlobalMethods.dart';
import '../utils/ColorConstants.dart';
import '../utils/Constants.dart';
import '../utils/ThemedWidgets.dart';
import '../utils/methods.dart';

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
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();

  _loginApiCall(bool isFromBooking, String email, String password) {
    var params = {
      'username': "Clark",
      'password': "Super@123",
      'companycode': "mycare",
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
            print('res ${stripHtmlIfNeeded(response)}');

            final jResponse = json.decode(stripHtmlIfNeeded(response));

            print('res ${jResponse['status']}');
            if (jResponse['status'] == 1) {
              print('res success');
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
      backgroundColor: colorGreyExtraLightBackGround,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: spaceHorizontal),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 40, horizontal: spaceHorizontal),
              child: Column(
                children: [
                  Form(
                    key: _keyFormField,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey.shade50,
                      child: Column(
                        children: [
                          ThemedTextField(
                            controller: _controllerEmail,
                            hintText: "Username*",
                            preFix: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().isEmpty) {
                                return "Please enter email!";
                              }
                              if (!isValidateEmail(value.trim())) {
                                return "Please enter valid email!";
                              }
                            },
                            backgroundColor: colorGreyExtraLightBackGround,
                          ),
                          const SizedBox(height: spaceVertical),
                          ThemedTextField(
                            controller: _controllerPassword,
                            hintText: "Password",
                            preFix: const Icon(Icons.password),
                            isPasswordTextField: true,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().isEmpty) {
                                return "Please enter password!";
                              }
                              if (value.length < 8 || value.length > 15) {
                                return "Please enter valid length(between 8 to 15) password!";
                              }
                            },
                            backgroundColor: colorGreyExtraLightBackGround,
                          ),
                          const SizedBox(height: spaceVertical),
                          ThemedTextField(
                            controller: _controllerPassword,
                            hintText: "Compnay Code",
                            preFix: const Icon(Icons.password),
                            isPasswordTextField: true,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().isEmpty) {
                                return "Please enter password!";
                              }
                              if (value.length < 8 || value.length > 15) {
                                return "Please enter valid length(between 8 to 15) password!";
                              }
                            },
                            backgroundColor: colorGreyExtraLightBackGround,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: spaceVertical),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        )),
                    child: ThemedButton(
                      title: "Login",
                      onTap: () {
                        _loginApiCall(
                          widget.isLoginForBooking,
                          _controllerEmail.text.trim(),
                          _controllerPassword.text.trim(),
                        );
                        // if (_keyFormField.currentState != null &&
                        //     _keyFormField.currentState!.validate()) {
                        //   if (_controllerEmail.text == null ||
                        //       _controllerEmail.text.trim().isEmpty) {
                        //     showSnackBarWithText(_keyScaffold.currentState,
                        //         "Please Enter Email!");
                        //   } else if (_controllerPassword.text == null ||
                        //       _controllerEmail.text.trim().isEmpty) {
                        //     showSnackBarWithText(_keyScaffold.currentState,
                        //         "Please Enter Password!");
                        //   } else {
                        //     _loginApiCall(
                        //       widget.isLoginForBooking,
                        //       _controllerEmail.text.trim(),
                        //       _controllerPassword.text.trim(),
                        //     );
                        //   }
                        // }
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
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
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: colorGreyLiteText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ThemedText(
                            text: 'Don\'t have an account yet?',
                            color: colorGreyLiteText,
                            fontWeight: FontWeight.w500,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {});
                            },
                            child: const Text(
                              ' Sign up now',
                              style: TextStyle(
                                color: colorGreyDarkText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }
}
