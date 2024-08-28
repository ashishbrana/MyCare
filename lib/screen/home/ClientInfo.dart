import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import 'models/ClientInfomationModel.dart';

class ClientInfo extends StatefulWidget {
  final String clientId;

  const ClientInfo({super.key, required this.clientId});

  @override
  State<ClientInfo> createState() => _ClientInfoState();
}

class _ClientInfoState extends State<ClientInfo> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  String userName = "";
  ClientInformationModel? userModel;

  final TextEditingController _controllerCareComment = TextEditingController();
  final TextEditingController _controllerRiskNotification =
      TextEditingController();
  final TextEditingController _controllerClientGoals = TextEditingController();
  final TextEditingController _controllerProvidedComments = TextEditingController();

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    var params = {
      'auth_code': (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType': (await Preferences().getPrefInt(Preferences.prefAccountType)).toString(),
      'userid': widget.clientId,
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endClientProfile, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          if (response != "") {
            List jResponse = json.decode(response);
            print('Profile $jResponse');
            List<ClientInformationModel> dataList = jResponse
                .map((e) => ClientInformationModel.fromJson(e))
                .toList();
            if (dataList.isNotEmpty) {
              userModel = dataList[0];
              print(
                  "DATA : ${userModel!.careComments} ${userModel!.riskNotification} ${userModel!.clientGoals}");
              userName = userModel!.fullname ?? "";
              _controllerCareComment.text = userModel!.careComments ?? "";
              _controllerRiskNotification.text = userModel!.riskNotification ?? "";
              _controllerClientGoals.text = userModel!.clientGoals ?? "";
              _controllerProvidedComments.text = userModel!.careNotesClient ?? "";
            } else {
              showSnackBarWithText(_keyScaffold.currentState, "Data Not Available!");
            }
            setState(() {

            });

            print('res $dataList');
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
      appBar: buildAppBar(context, title: "Client Information"),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spaceHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: space),
                Row(
                  children: [
                    ThemedText(
                      text: "Client Name : ",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    ThemedText(
                      text: userName,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                const SizedBox(height: space),
                ThemedText(
                  text: "Care Comments : ",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: spaceBetween),
                ThemedTextField(
                  controller: _controllerCareComment,
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  fontSized: 12,
                  minLine: 7,
                  maxLine: 7,
                  isReadOnly: true,
                ),
                const SizedBox(height: space),
                ThemedText(
                  text: "Risk Notification : ",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: spaceBetween),
                ThemedTextField(
                  controller: _controllerRiskNotification,
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: true,
                  fontSized: 12,
                  minLine: 7,
                  maxLine: 7,
                ),
                const SizedBox(height: space),
                ThemedText(
                  text: "Client Goals :",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: spaceBetween),
                ThemedTextField(
                  controller: _controllerClientGoals,
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: true,
                  fontSized: 12,
                  minLine: 7,
                  maxLine: 7,
                ),
                const SizedBox(height: space),
                ThemedText(
                  text: "Client Provided Comments:",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: spaceBetween),
                ThemedTextField(
                  controller: _controllerProvidedComments,
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: true,
                  fontSized: 12,
                  minLine: 7,
                  maxLine: 7,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
