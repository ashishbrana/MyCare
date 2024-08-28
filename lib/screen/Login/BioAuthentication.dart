import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../utils/Preferences.dart';
import '../../utils/methods.dart';
import '../ClientHome/ClientHomeScreen.dart';
import '../home/HomeScreen.dart';

class BioVerificationScreen extends StatefulWidget {
  const BioVerificationScreen({
    Key? key,
    required this.accountType,
    this.phoneNumber,
  }) : super(key: key);

  final String? phoneNumber;
  final int accountType;

  @override
  State<BioVerificationScreen> createState() =>
      _BioVerificationScreenState();
}

class _BioVerificationScreenState extends State<BioVerificationScreen> {
  TextEditingController textEditingController = TextEditingController();

  // ..text = "123456";

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  final formKey = GlobalKey<FormState>();
  String notRegistered = "ToucnID / FaceId Not Congigured Yet";

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) {
        setState(() {
          _supportState = isSupported ? _SupportState.supported : _SupportState.unsupported;
          notRegistered = isSupported ? "Authorize Now" : "Not Authorize Now";

          if (isSupported){
            _authenticate();
          }
          else{
            sendToHome();
          }
        });
      },
    );
   /* if(_supportState == _SupportState.supported){
      print("Supported");

      setState(() {
        notRegistered = "Authorize Now";
      });

    }
    else{
      print("Not Supported");
      setState(() {
        notRegistered = "Not Authorize Now";
      });
    }*/
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      showSnackBarWithText(_keyScaffold.currentState, _authorized);
      if (authenticated) {
        sendToHome();
      }
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Authentication Required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: const TextSpan(
                    text: "Because then only person seeing your data should be you",
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
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 TextButton(
                    onPressed: () {

                    },
                    child: Text(
                      notRegistered,
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
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  sendToHome()  {
    var preferences = Preferences();
    preferences.setPrefBool(Preferences.prefBioAuthneticated, true);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.accountType == 2 ? const HomeScreen() : const ClientHomeScreen(),
        ));
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
