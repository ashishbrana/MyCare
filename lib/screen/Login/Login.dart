import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rcare_2/screen/ClientHome/ClientHomeScreen.dart';
import 'package:rcare_2/utils/ConstantStrings.dart';
import 'package:rcare_2/utils/Preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import '../home/HomeScreen.dart';
import '../home/PinAutentication.dart';
import 'model/LoginResponseModel.dart';

class Login extends StatefulWidget {
  bool isLoginForBooking = false;
  bool showLogo = false;

  Login({super.key, this.isLoginForBooking = false});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int accountType = 2;
  bool is2FA = false;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );
  ImageCache cacheManager = ImageCache();

  ///  * [_keyFormField], key of form of sign form.
  final GlobalKey<FormState> _keyFormField = GlobalKey<FormState>();

  ///  * [_keyForgotFormField], key of form of forgot dialog form.
  final GlobalKey<FormState> _keyForgotFormField = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();


  String? firebaseToken;
  String? version;
  String? code;

  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerCompanyCode = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
     getData();
    clearCache();
    /*  auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported)
    );*/
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      print(_packageInfo.version);
      _packageInfo = info;
    });
  }

  getData() async {
    _controllerUsername.text =
        (await FlutterKeychain.get(key: "username") ?? "");
    _controllerPassword.text =
        (await FlutterKeychain.get(key: "password") ?? "");
    _controllerCompanyCode.text =
        (await FlutterKeychain.get(key: "companycode") ?? "");
  }

  Future<void> _loadSessionStartTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime? sessionStartTime =  DateTime.now();
    prefs.setString('sessionStartTime', sessionStartTime!.toIso8601String());
  }

  _loginApiCall(String username, String password, String comapanyCode) async {
    closeKeyboard();

    setUpAllUrls(comapanyCode == "nhc" ? "nhc-northside" : comapanyCode);

    var devicename = "";
    var devicetype = "";
    var appversion = "";
    var osversion = "";

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      osversion = androidInfo.version.release.toString();
      devicename = androidInfo.model;
      devicetype = "android";
      appversion = _packageInfo.version;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      osversion = iosInfo.systemVersion;
      devicename = iosInfo.utsname.machine;
      devicetype = "ios";
      appversion = _packageInfo.version;
    }
    appVersion = appversion;
    deviceType = devicetype;

    var params = {
      'username': username,
      'password': password,
      'companycode': comapanyCode,
      'appversion': appversion,
      'devicename': devicename,
      'devicetype': devicetype,
      'osversion': osversion,
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
            _loadSessionStartTime();
            if (responseModel.is2FA != null) {
              is2FA = responseModel.is2FA!;
            }
            print('res ${jResponse['status']}');
            if (responseModel.status == 1) {
              print('res success');

              final preferences = Preferences();
              preferences.setLoginPreferences(responseModel, comapanyCode);

              if (responseModel.accountType == 3) {
                Preferences().setPrefString(Preferences.prefEndofServiceDate,
                    responseModel.endofServiceDate ?? "");
              }
              await FlutterKeychain.put(key: "username", value: username);
              await FlutterKeychain.put(key: "password", value: password);
              await FlutterKeychain.put(
                  key: "companycode", value: comapanyCode);
              setUpAllUrls(
                  comapanyCode == "nhc" ? "nhc-northside" : comapanyCode);

              if (responseModel.accountType == 2) {
                sendToHome(responseModel.accountType!);
              } else if (responseModel.accountType == 3) {
                sendToHome(responseModel.accountType!);
              }
            } else if (responseModel.status == 1 &&
                responseModel.accountType != 2) {
              showSnackBarWithText(
                  _keyScaffold.currentState, "User can not login");
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, jResponse['message']);
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

  clearCache() {
    CachedNetworkImage.evictFromCache(logoUrl);
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
                    if (!widget.showLogo)
                      Container(
                        // width: double/.infinity,
                        child: Image.asset(
                          '${Constants.imagePath}login_top.png',
                          fit: BoxFit.contain,
                          // height: MediaQuery.of(context).size.height ,
                          width: MediaQuery.of(context).size.width * .5,
                        ),
                      ),
                    if (widget.showLogo)
                      Container(
                        height: 150,
                        width: 150,
                        child: CachedNetworkImage(
                          imageUrl: logoUrl,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    if (!widget.showLogo)
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
                              child: AutofillGroup(
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
                                              autofillHints: [
                                                AutofillHints.username
                                              ],
                                              labelText: "Username",
                                              labelFontWeight: FontWeight.w500,
                                              preFix: const FaIcon(
                                                  FontAwesomeIcons
                                                      .solidCircleUser,
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
                                            const SizedBox(
                                                height: spaceVertical),
                                            ThemedTextField(
                                              borderColor: colorGreyBorderD3,
                                              controller: _controllerPassword,
                                              // hintText: "Password",
                                              autofillHints: [
                                                AutofillHints.password
                                              ],
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
                                                if (value.length < 5 ||
                                                    value.length > 15) {
                                                  return "Please enter valid length(between 5 to 15) password!";
                                                }
                                              },
                                              backgroundColor:
                                                  colorGreyExtraLightBackGround,
                                            ),
                                            const SizedBox(
                                                height: spaceVertical),
                                            ThemedTextField(
                                              borderColor: colorGreyBorderD3,
                                              controller:
                                                  _controllerCompanyCode,
                                              // hintText: "Company Code",
                                              labelText: "Company Code",
                                              labelFontWeight: FontWeight.w500,
                                              preFix: const FaIcon(
                                                  FontAwesomeIcons.key,
                                                  color: colorPrimary),
                                              isPasswordTextField: false,
                                              onChanged: (value) {
                                                _controllerCompanyCode.value =
                                                    TextEditingValue(
                                                        text:
                                                            value.toLowerCase(),
                                                        selection:
                                                            _controllerCompanyCode
                                                                .selection);
                                              },
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
                                                  _controllerUsername.text
                                                      .trim(),
                                                  _controllerPassword.text
                                                      .trim(),
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
                      ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 8, right: 15, left: 15),
                      decoration: BoxDecoration(
                        color: colorTransparent,
                        borderRadius: boxBorderRadius,
                      ),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(3),
                      child: ThemedText(
                        text: _packageInfo.version,
                        color: Colors.white,
                        fontSize: 20,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () {
                    //         // _buildForgotPassWordDialog();
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => const ForgotPassword(),
                    //             ));
                    //       },
                    //       child: const Text(
                    //         'FORGOT YOUR PASSWORD ?',
                    //         style: TextStyle(
                    //           fontSize: 16.0,
                    //           fontWeight: FontWeight.w500,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(height: 20),
                    //   ],
                    // ),
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

  sendToHome(int accountType) async {
    widget.showLogo = true;
   // is2FA = true;
    setState(() {
      // Here you can write your code for open new view
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => is2FA
                ? PinCodeVerificationScreen(accountType: accountType)
                : (accountType == 2
                    ? const HomeScreen()
                    : const ClientHomeScreen()),
          ));
    });
  }

  sendToHome1() async {
    widget.showLogo = true;
    setState(() {
      // Here you can write your code for open new view
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
    });
  }

  sendToClientHome() {

    widget.showLogo = true;
    setState(() {
      // Here you can write your code for open new view
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ClientHomeScreen(),
          ));
    });
  }
}

