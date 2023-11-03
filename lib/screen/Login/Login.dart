import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rcare_2/screen/HomeScreen/HomeScreen.dart';
import 'package:rcare_2/utils/ConstantStrings.dart';

import '../../Network/API.dart';
import '../../Network/ApiUrls.dart';
import '../../Network/GlobalMethods.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/Constants.dart';
import '../../utils/Images.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';

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

  _loginApiCall(bool isFromBooking, String username, String password,
      String comapnyCode) {
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
                                          hintText: "Username*",
                                          labelText: "Username*",
                                          preFix: SvgPicture.asset(
                                            "assets/SVG/user_login.svg",
                                            height: 24,
                                            alignment: Alignment.centerLeft,
                                          ),
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
                                          hintText: "Password",
                                          labelText: "Password",
                                          preFix: SvgPicture.asset(
                                            "assets/SVG/lock-solid.svg",
                                            height: 24,
                                            alignment: Alignment.centerLeft,
                                          ),
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
                                          hintText: "Company Code",
                                          labelText: "Company Code",
                                          preFix: SvgPicture.asset(
                                            "assets/svg/svg_BookTripTo.svg",
                                            height: 24,
                                            alignment: Alignment.centerLeft,
                                          ),
                                          isPasswordTextField: true,
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
                                  height: 50,
                                  child: MaterialButton(
                                    color: colorGreen,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.login,
                                          color: colorWhite,
                                        ),
                                        ThemedText(
                                          text: "Log In",
                                          color: colorWhite,
                                        )
                                      ],
                                    ),
                                    onPressed: () {},
                                  ),
                                )
                                /*  Container(
                                    decoration: const BoxDecoration(
                                      color: colorGreen,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(0),
                                      ),),
                                    child:
                                  */ /*ThemedButton(
                                    title: "Log In",
                                    onTap: () {
                                      sendToHome();
                                      // if (_keyFormField.currentState != null &&
                                      //     _keyFormField.currentState!.validate()) {
                                      //   if (_controllerUsername.text == null ||
                                      //       _controllerUsername.text.trim().isEmpty) {
                                      //     showSnackBarWithText(_keyScaffold.currentState,
                                      //         "Please Enter Email!");
                                      //   } else if (_controllerPassword.text == null ||
                                      //       _controllerUsername.text.trim().isEmpty) {
                                      //     showSnackBarWithText(_keyScaffold.currentState,
                                      //         "Please Enter Password!");
                                      //   } else {
                                      //     _loginApiCall(
                                      //       widget.isLoginForBooking,
                                      //       _controllerUsername.text.trim(),
                                      //       _controllerPassword.text.trim(),
                                      //       _controllerCompanyCode.text.trim()
                                      //     );
                                      //   }
                                      // }
                                    },
                                  ),*/ /*
                                ),*/
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
