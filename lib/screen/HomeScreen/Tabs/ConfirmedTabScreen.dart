import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/Network/ApiUrls.dart';
import 'package:rcare_2/screen/HomeScreen/HomeScreen.dart';
import 'package:rcare_2/screen/HomeScreen/models/ConfirmedResponseModel.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/Preferences.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';

import '../../../Network/API.dart';
import '../../../utils/ColorConstants.dart';
import '../../../utils/ConstantStrings.dart';
import '../../../utils/methods.dart';

class ConfirmedTabScreen extends StatefulWidget {
  const ConfirmedTabScreen({super.key});

  @override
  State<ConfirmedTabScreen> createState() => _ConfirmedTabScreenState();
}

class _ConfirmedTabScreenState extends State<ConfirmedTabScreen> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  List<ConfirmedResponseModel> dataList = [];

  @override
  void initState() {
    super.initState();
    getData(
      fromDate: DateTime.now(),
      toDate: DateTime(DateTime.now().year, DateTime.now().month + 1),
    );
  }

  getData({required DateTime fromDate, required DateTime toDate}) async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType':
          (await Preferences().getPrefInt(Preferences.prefAccountType))
              .toString(),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'fromdate': DateFormat("yyyy/MM/dd").format(fromDate),
      'todate': DateFormat("yyyy/MM/dd").format(toDate),
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endTimeSheets, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            print('res ${response}');

            List jResponse = json.decode(response);
            print("jResponse $jResponse");
            dataList = jResponse
                .map((e) => ConfirmedResponseModel.fromJson(e))
                .toList();
            setState(() {});
            print("models.length${dataList.length}");
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print(e);
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
      backgroundColor: colorLiteBlueBackGround,
      key: _keyScaffold,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: spaceHorizontal, vertical: spaceVertical),
            child: ThemedText(
              text:
                  "Confirmed : ${DateFormat("dd-MM-yyyy").format(fromDate)} - ${DateFormat("dd-MM-yyyy").format(toDate)}",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorGreyText,
            ),
          ),
          const Divider(
            thickness: 1,
            height: 1,
            color: colorGreyBorderD3,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              primary: true,
              itemBuilder: (context, index) {
                ConfirmedResponseModel model = dataList[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  color: colorWhite,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${model.resName} ",
                                          style: const TextStyle(
                                            color: colorGreyText,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                          ),
                                        ),
                                        TextSpan(
                                          text: model.serviceName,
                                          style: const TextStyle(
                                            color: colorGreyLiteText,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.person_crop_circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 1,
                              color: colorGreyBorderD3,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  child: Icon(
                                    Icons.arrow_downward_rounded,
                                    color: colorGreen,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                FaIcon(
                                  FontAwesomeIcons.calendarDays,
                                  color: colorGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Mon, 16-10-2023",
                                  style: TextStyle(
                                    color: colorGreyText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 1,
                                  height: 25,
                                  color: colorGreyBorderD3,
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  CupertinoIcons.time,
                                  color: colorGreen,
                                  size: 18,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "1hrs",
                                  style: TextStyle(
                                    color: colorGreyText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 1,
                                  height: 25,
                                  color: colorGreyBorderD3,
                                ),
                                const SizedBox(width: 5),
                                const Expanded(
                                    child: Icon(
                                  Icons.timelapse_rounded,
                                  color: colorGreen,
                                )),
                                const SizedBox(width: 5),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: colorGreyBorderD3,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.timer,
                                  color: colorGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "12:50:00 - 13:50:00",
                                  style: TextStyle(
                                    color: colorGreyText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Align(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: colorGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
