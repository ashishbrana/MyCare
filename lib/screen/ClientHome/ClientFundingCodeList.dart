import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../chart/PieChartContent.dart';
import '../../chart/chart_container.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import 'ClientFundingUsageDetail.dart';
import 'model/ClientFundingCode.dart';

class ClientFundingCodeList extends StatefulWidget {
  final String authCode;
  final String userid;
  final int fundingID;
  final DateTime fromDate;
  final DateTime toDate;

  const ClientFundingCodeList(
      {super.key,
      required this.authCode,
      required this.userid,
      required this.fundingID,
      required this.fromDate,
      required this.toDate});

  @override
  State<ClientFundingCodeList> createState() => _ClientFundingCodeListState();
}

class _ClientFundingCodeListState extends State<ClientFundingCodeList> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  ClientFundingCode? fundingCode;

  List<ClientFundingCode> fundingCodeList = [];
  List<ClientFundingCode> filteredList = [];

  int selectedExpandedIndex = -1;
  int lastSelectedRow = -1;

  final TextEditingController _controllerSearch = TextEditingController();
  FocusScopeNode focusNode = FocusScopeNode();
  FocusScopeNode focusNavigatorNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    getFundingCode();
  }

  getFundingCode() async {
    var params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'FundingID': widget.fundingID.toString(),
      'fromdate': widget.fromDate.shortDate(),
      'todate': widget.toDate.shortDate(),
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endClientFundingCodeDetails, params: params).toString(),
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
            List<ClientFundingCode> dataList = jResponse.map((e) => ClientFundingCode.fromJson(e)).toList();

            if (dataList.isNotEmpty) {
              fundingCodeList.clear();
              fundingCodeList.addAll(dataList);
              filteredList.clear();
              filteredList.addAll(dataList);
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, "Data Not Available!");
            }

            setState(() {});
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
        backgroundColor: colorLiteBlueBackGround,
        appBar: _buildAppBar(),
        body: _buildProgressNoteList());
  }

  _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: SizedBox(
        height: 40,
        child: FocusScope(
          node: focusNode,
          child: ThemedTextField(
            borderColor: colorPrimary,
            controller: _controllerSearch,
            preFix: const Icon(
              Icons.search,
              color: Color(0XFFBBBECB), // You can customize the color if needed
              size: 28, // You can customize the size if needed
            ),
            sufFix: SizedBox(
              height: 40,
              width: 40,
              child: InkWell(
                onTap: () {
                  _controllerSearch.text = "";
                  performSearch(_controllerSearch.text);
                },
                child: Icon(
                  _controllerSearch.text.isNotEmpty ? Icons.cancel : null,
                  size: 20, // Adjust the size as needed
                  color: Color(0XFFBBBECB), // Adjust the color as needed
                ),
              ),
            ),
            padding: EdgeInsets.zero,
            hintText: "Search...",
            onTap: () {
              focusNavigatorNode.unfocus();
              focusNode.requestFocus();
            },
            onChanged: (string) {
              performSearch(string.trim());
            },
          ),
        ),
      ),
    );
  }

  void performSearch(String trimmedString) {
    if (trimmedString.isNotEmpty) {
      filteredList = [];
      for (ClientFundingCode model in fundingCodeList) {
        if ((model.serviceType != null &&
            model.serviceType!
                .toLowerCase()
                .contains(trimmedString.toLowerCase())) ||
            (model.clientFundingName != null &&
                model.clientFundingName!
                    .toLowerCase()
                    .contains(trimmedString.toLowerCase()))) {
          filteredList.add(model);
        }
      }
    } else {
      filteredList = [];
      filteredList.addAll(fundingCodeList);
    }
    setState(() {});
  }
  _buildProgressNoteList() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: colorLiteBlueBackGround,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  child: SizedBox(
                    height: textFiledHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: spaceHorizontal),
                        Expanded(
                          child: ThemedButton(
                            padding: EdgeInsets.zero,
                            title: "Back",
                            fontSize: 14,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  decoration: BoxDecoration(
                    color: colorTransparent,
                    borderRadius: boxBorderRadius,
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(3),
                  child: ThemedText(
                    text: "Funding Code List",
                    color: Colors.black,
                    fontSize: 20,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    primary: true,
                    itemBuilder: (context, index) {
                      ClientFundingCode model = filteredList[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        margin:
                            const EdgeInsets.only(top: 8, right: 15, left: 15),
                        color: lastSelectedRow == index
                            ? Colors.grey.withOpacity(0.2)
                            : colorWhite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${model.fundingSourceName} - ${model.serviceType} - \$${model.balanceAmount
                          ?.toDouble()
                          .toStringAsFixed(2) ??
                      "0.00"}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.blueAccent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 1,
                                        color: colorGreyBorderD3,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              if (selectedExpandedIndex ==
                                                      index &&
                                                  selectedExpandedIndex != -1) {
                                                selectedExpandedIndex = -1;
                                              } else {
                                                selectedExpandedIndex = index;
                                              }
                                              setState(() {});
                                            },
                                            child: const SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Icon(
                                                Icons.arrow_downward_rounded,
                                                color: colorGreen,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ThemedRichText(
                                              spanList: [
                                                WidgetSpan(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color: colorGreen,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          model.code ?? "",
                                                          maxLines: 4,
                                                          style: const TextStyle(
                                                            color:
                                                                colorGreyText,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        width: 1,
                                                        height: 25,
                                                        color:
                                                            colorGreyBorderD3,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      lastSelectedRow = index;
                                    });
                                    if ((model.utilizeTotal?.toDouble() ?? 0) ==
                                        0) {
                                      showSnackBarWithText(
                                          _keyScaffold.currentState,
                                          "No services created for this funding code",
                                          color: colorGreen);
                                      return;
                                    }
                                    final authCode = await Preferences()
                                        .getPrefString(
                                            Preferences.prefAuthCode);
                                    final userId = (await Preferences()
                                            .getPrefInt(Preferences.prefUserID))
                                        .toString();

                                    Navigator.of(_keyScaffold.currentContext!)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          ClientFundingUsageDetails(
                                        authCode: authCode,
                                        userid: userId,
                                        fundingID:
                                            model.fundingCodeID?.toInt() ?? 0,
                                        fromDate: widget.fromDate,
                                        toDate: widget.toDate,
                                      ),
                                    ));
                                  },
                                  child: const Align(
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: colorGreen,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (selectedExpandedIndex == index)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 7),
                                  createBalanceRow(
                                      title: "Budget",
                                      openBalance: model.budgetAmount
                                              ?.toDouble()
                                              .toStringAsFixed(2) ??
                                          "0.00", boxColor: Colors.white),
                                  const SizedBox(height: 7),
                                  createBalanceRow(
                                      title: "Open Balance",
                                      openBalance: model.openBalance
                                              ?.toDouble()
                                              .toStringAsFixed(2) ??
                                          "0.00", boxColor: Colors.white),
                                  const SizedBox(height: 7),
                                  createBalanceRow(
                                      title: "Utilised",
                                      openBalance: model.utilizeTotal
                                              ?.toDouble()
                                              .toStringAsFixed(2) ??
                                          "0.00", boxColor: Colors.red),
                                  const SizedBox(height: 7),
                                  createBalanceRow(
                                      title: "Balance",
                                      openBalance: model.balanceAmount
                                              ?.toDouble()
                                              .toStringAsFixed(2) ??
                                          "0.00", boxColor: Colors.green),
                                  ChartContainer(
                                      title: '',
                                      color: Colors.white,
                                      chart: PieChartContent(pieChartSectionData: model.getSectionData(MediaQuery.of(context).size.width))
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget createBalanceRow(
      {required String title, required String openBalance , required Color boxColor }) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Container(
            width: 10.0,
            height: 10.0,
            color: boxColor,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: ThemedText(
            text: "$title:",
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: ThemedText(
            text: "\$$openBalance",
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
