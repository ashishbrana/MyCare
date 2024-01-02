import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/GlobalMethods.dart';
import '../../utils/Preferences.dart';
import '../../utils/methods.dart';
import 'models/ClientDocModel.dart';

class ClientDocument extends StatefulWidget {
  final String id;
  final String resId;

  const ClientDocument({super.key, required this.id, required this.resId});

  @override
  State<ClientDocument> createState() => _ClientDocumentState();
}

class _ClientDocumentState extends State<ClientDocument> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  List<ClientDocModel> dataList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    // String acctype=""+ await Preferences().getPrefString(Preferences.prefAccountType);
    var params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'type': "ClientDocs",
      'userid': widget.resId,
      'compcode':
          (await Preferences().getPrefString(Preferences.prefComepanyCode))
              .toString(),
      'id': widget.id,
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endGetDocs, params: params).toString(),
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
            dataList =
                jResponse.map((e) => ClientDocModel.fromJson(e)).toList();
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
      backgroundColor: colorWhite,
      appBar: buildAppBar(context, title: "Client Document"),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: dataList.length,
                primary: true,
                itemBuilder: (context, index) {
                  ClientDocModel model = dataList[index];
                  return InkWell(
                    onTap: () {
                      launchUrlMethod(
                          "https://mycare.mycaresoftware.com/Uploads/client/5/MyDocs/${model.name ?? ""}");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: spaceHorizontal * 1.5),
                      margin: const EdgeInsets.only(top: spaceVertical),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ThemedText(
                            text: model.name ?? "",
                            color: colorLiteBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          ThemedText(
                            text:  formatServiceDate(model.createdon),
                            color: colorGreyDarkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 50,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                child: ThemedButton(
                  title: "Close",
                  padding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: spaceVertical),
          ],
        ),
      ),
    );
  }
}
