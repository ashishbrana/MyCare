import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../Network/API.dart';
import '../../Network/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _controllerOldPassword = TextEditingController();
  final TextEditingController _controllerNewPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
  TextEditingController();
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      appBar: buildAppBar(context, title: "Change Password"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: spaceHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: spaceVertical*2),
              ThemedText(
                text: "Current Password",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: spaceBetween),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  isPasswordTextField: true,
                  controller: _controllerOldPassword,
                  padding: EdgeInsets.symmetric(vertical: spaceHorizontal,horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  hintText: "Current Password",
                ),
              ),
              const SizedBox(height: space),
              ThemedText(
                text: "New Password",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: spaceBetween),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  isPasswordTextField: true,
                  padding: EdgeInsets.symmetric(vertical: spaceHorizontal,horizontal: spaceHorizontal),
                  controller: _controllerNewPassword,
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  hintText: "New Password",
                ),
              ),
              const SizedBox(height: space),
              ThemedText(
                text: "Confirm New Password",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: spaceBetween),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  isPasswordTextField: true,
                  controller: _controllerConfirmPassword,
                  padding: EdgeInsets.symmetric(vertical: spaceHorizontal,horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  hintText: "Confirm New Password",
                ),
              ),
              const SizedBox(height: spaceVertical*3),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ThemedButton(
                        title: "Cancel",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
                        fontWeight: FontWeight.w600,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          // Navigator.pop(context);
                           if (_controllerOldPassword.text
                              .trim()
                              .isEmpty) {
                            showSnackBarWithText(_keyScaffold.currentState,
                                "Please enter old password first!");
                          } else if (_controllerNewPassword.text.trim().isEmpty) {
                             showSnackBarWithText(_keyScaffold.currentState,
                                 "Please enter new password first!");
                          }
                           else if (_controllerConfirmPassword.text.trim().isEmpty) {
                             showSnackBarWithText(_keyScaffold.currentState,
                                 "Please enter confirm password first!");
                           }
                           else if (_controllerNewPassword.text.compareTo(_controllerConfirmPassword.text.trim()) != 0) {
                             showSnackBarWithText(_keyScaffold.currentState,
                                 "New password and confirm password does not mathc!");
                           }
                          else {
                             _changePassword();
                          }
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


  // https://mycare-web.mycaresoftware.com/MobileAPI/v1.asmx/ChangeEmployeePassword?UserID=238&UserType=user&NewPassword=Super@123

  _changePassword() async {
    var params = {
      'UserID': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'NewPassword': _controllerNewPassword.text,
      'UserType' : 'user'
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(changePass, params: params).toString(),
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

            var jResponse = json.decode(response);
            if (jResponse["status"] == 1) {
              showSnackBarWithText(_keyScaffold.currentState,jResponse["message"],
                  color: colorGreen);
              Navigator.pop(context, true);
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

}
