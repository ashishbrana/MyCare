import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rcare_2/screen/Login/BioAuthentication.dart';
import 'package:rcare_2/screen/Login/model/OtpResponse.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;
import '../../appconstant/ApiUrls.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/methods.dart';
import '../ClientHome/ClientHomeScreen.dart';
import '../Login/model/AuthResponse.dart';
import 'HomeScreen.dart';

class PinCodeVerificationScreen extends StatefulWidget {
  const PinCodeVerificationScreen({
    Key? key,
    required this.accountType,
    this.phoneNumber,
  }) : super(key: key);

  final String? phoneNumber;
  final int accountType;

  @override
  State<PinCodeVerificationScreen> createState() =>
      _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen>
    with CodeAutoFill {
  TextEditingController textEditingController = TextEditingController();

  // ..text = "123456";

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  String message = "OTP will be sent on registered mobile number / Email";
  final formKey = GlobalKey<FormState>();
  String? appSignature;
  String? otpCode;

  bool invalidOtp = false;
  int resendTime = 60;
  late Timer countdownTimer;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
    listenForCode();
    askFor2FA();

    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
  }

  @override
  void codeUpdated() {
    setState(() {
      print("codeUpdated");
      otpCode = code!;
      textEditingController.text = otpCode!;
    });
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdownTimer.isActive) {
          resendTime = resendTime - 1;
        }
      });
      if (resendTime < 1) {
        countdownTimer.cancel();
      }
    });
  }

  stopTimer() {
    if (countdownTimer.isActive) {
      countdownTimer.cancel();
    }
  }

  String strFormatting(n) => n.toString().padLeft(2, '0');

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  askFor2FA() async {
    // closeKeyboard();
    log("Response askFor2FA");
    final preferences = Preferences();

    var authCode = await preferences.getPrefString(Preferences.prefAuthCode);
    var userType = await preferences.getPrefInt(Preferences.prefAccountType);
    var loginUserId = await preferences.getPrefInt(Preferences.prefUserID);
    var companyCode =
        await preferences.getPrefString(Preferences.prefCompanyCode);

    var params = {
      'auth_code': authCode,
      'UserType': userType == 2 ? "user" : "client",
      'LoginUserId': loginUserId,
      'CompanyCode': companyCode,
      // Corrected the key name to avoid duplicate keys
    };
    String req = jsonEncode(params);
    log("Response $req");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        getOverlay(context);
        try {
          String req = jsonEncode(params);
          log("Response $req");
          Response response = await http.post(
              Uri.parse("$masterURL$twoFactorAuthentication"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(params));
          log("Response $twoFactorAuthentication : ${response.body}");
          if (response != null && response != "") {
            print('res ${response}');

            final jResponse = json.decode(response.body);
            var dResponse = json.decode(jResponse["d"]);
            print('res ${dResponse}');
            AuthResponse responseModel = AuthResponse.fromJson(dResponse);
            if (responseModel.status == 1) {
              print('res success');
              message = responseModel.message ?? message;
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

  vefify2FA() async {
    // closeKeyboard();
    log("Response askFor2FA");
    final preferences = Preferences();

    var authCode = await preferences.getPrefString(Preferences.prefAuthCode);
    var userType = await preferences.getPrefInt(Preferences.prefAccountType);
    var loginUserId = await preferences.getPrefInt(Preferences.prefUserID);
    var companyCode = await preferences.getPrefString(Preferences.prefCompanyCode);

    var params = {
      'auth_code': authCode,
      'Code': currentText,
      'UserType': userType == 2 ? "user" : "client",
      'LoginUserId': loginUserId,
      'CompanyCode': companyCode,
      // Corrected the key name to avoid duplicate keys
    };
    String req = jsonEncode(params);
    log("Response $req");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        getOverlay(context);
        try {
          String req = jsonEncode(params);
          log("Response $req");
          Response response = await http.post(
              Uri.parse("$masterURL$verifyTwoFactorAuthentication"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(params));
          log("Response $twoFactorAuthentication : ${response.body}");

          if (response != null && response != "") {
            print('res ${response}');

            final jResponse = json.decode(response.body);
            var dResponse = json.decode(jResponse["d"]);
            OtpResponse responseModel = OtpResponse.fromJson(dResponse);
            if (responseModel.status == 1) {
              print('responseModel ${responseModel.message!}');
              //sendToHome();
              preferences.setPrefBool(Preferences.prefAuthneticated, true);
              sendToBio();
            } else {
              print('responseModel ${responseModel.message!}');
              //  showSnackBarWithText(_keyScaffold.currentState, responseModel.message!);
              snackBar(responseModel.message!);
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
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {},
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height / 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  // child: Image.asset(Constants.otpGifImage),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: const TextSpan(
                    text: "Enter 6 digit code",
                    children: [
                      TextSpan(
                        text: "",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 30,
                  ),
                  child: PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 6,
                    obscureText: true,
                    obscuringCharacter: '*',
                    /*  obscuringWidget: const FlutterLogo(
                      size: 24,
                    ),*/
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 3) {
                        return "I'm from validator";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                        inactiveColor: Colors.grey,
                        selectedColor: Colors.grey,
                        selectedFillColor: Colors.white,
                        activeColor: Colors.grey),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      debugPrint("Completed");
                    },
                    // onTap: () {
                    //   print("Pressed");
                    // },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasError ? "*Please fill up all the cells properly" : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  resendTime != 0
                      ? Text(
                          'You can resend OTP after ${strFormatting(resendTime)} second(s)',
                          style: const TextStyle(fontSize: 18),
                        )
                      : TextButton(
                          onPressed: () {
                            // Your code here
                            //  snackBar("OTP resend!!");
                            textEditingController.clear();
                            askFor2FA();
                            resendTime = 60;
                            startTimer();
                            listenForCode();
                          },
                          child: const Text(
                            "RESEND",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                decoration: BoxDecoration(
                    color: colorGreen,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.shade200,
                          offset: const Offset(1, -2),
                          blurRadius: 5),
                      BoxShadow(
                          color: Colors.green.shade200,
                          offset: const Offset(-1, 2),
                          blurRadius: 5)
                    ]),
                child: ButtonTheme(
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      formKey.currentState!.validate();
                      // conditions for validating
                      if (currentText.length != 6) {
                        errorController!.add(ErrorAnimationType
                            .shake); // Triggering error shake animation
                        setState(() => hasError = true);
                      } else {
                        setState(
                          () {
                            hasError = false;
                            //  snackBar("OTP Verified!!");
                            vefify2FA();
                          },
                        );
                      }
                    },
                    child: Center(
                      child: Text(
                        "VERIFY".toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              /*  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: TextButton(
                      child: const Text("Clear"),
                      onPressed: () {
                        textEditingController.clear();
                      },
                    ),
                  ),
                  Flexible(
                    child: TextButton(
                      child: const Text("Set Text"),
                      onPressed: () {
                        setState(() {
                          textEditingController.text = "123456";
                        });
                      },
                    ),
                  ),
                ],
              )*/
            ],
          ),
        ),
      ),
    );
  }

  sendToBio() {
    _loadSessionStartTime();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BioVerificationScreen(accountType: widget.accountType),
      ),
    );
  }

  Future<void> _loadSessionStartTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime? sessionStartTime =  DateTime.now();
      prefs.setString('sessionStartTime', sessionStartTime!.toIso8601String());
  }

  sendToHome() async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.accountType == 2
              ? const HomeScreen()
              : const ClientHomeScreen(),
        ));
  }
}
