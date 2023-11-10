import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Network/API.dart';
import '../../Network/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  ///  * [_keyFormField], key of form of sign form.
  final GlobalKey<FormState> _keyFormField = GlobalKey<FormState>();

  ///  * [_keyForgotFormField], key of form of forgot dialog form.
  final GlobalKey<FormState> _keyForgotFormField = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  String? firebaseToken;
  final TextEditingController _controllerOldPassword = TextEditingController();
  final TextEditingController _controllerNewPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      appBar: buildAppBar(context, title: "Forgot Password"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: spaceHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: spaceVertical * 2),
              ThemedRichText(
                spanList: [
                  getTextSpan(
                    text: "Company Code",
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
                  backgroundColor: colorWhite,
                  hintText: "Company Code*",
                ),
              ),
              const SizedBox(height: space),
              ThemedRichText(
                spanList: [
                  getTextSpan(
                    text: "User Type",
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
                  backgroundColor: colorWhite,
                  hintText: "User Type*",
                ),
              ),
              const SizedBox(height: space),
              ThemedRichText(
                spanList: [
                  getTextSpan(
                    text: "User Email",
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
                  backgroundColor: colorWhite,
                  hintText: "User Email*",
                ),
              ),
              const SizedBox(height: spaceVertical * 3),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ThemedButton(
                        title: "Cancel",
                        fontSize: 16,
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
                        title: "Reset",
                        fontSize: 16,
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
              const SizedBox(height: space),
            ],
          ),
        ),
      ),
    );
  }

  _forgotApiCall(String userId, String userTye, String password) {
    var params = {
      'UserID': userId,
      'UserType': userTye,
      'NewPassword': password,
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(changePass, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'POST');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          if (response != null && response != "") {
            print('res ${response}');

            final jResponse = json.decode(response);
            // LoginResponseModel responseModel =
            // LoginResponseModel.fromJson(jResponse);
            // print('res ${jResponse['status']}');
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
          removeOverlay();
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }
}
