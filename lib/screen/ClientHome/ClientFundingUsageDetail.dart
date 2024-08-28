import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/ClientHome/ServiceForm.dart';
import 'package:rcare_2/screen/ClientHome/model/ClientFundingUsage.dart';
import 'package:rcare_2/screen/home/models/ConfirmedResponseModel.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/LabeledCheckbox.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import '../CustomView/CustomDateDialog.dart';


DateTime fromDate = DateTime.now();
DateTime toDate = fromDate.addDays(14);
DateTime tempFromDate = DateTime.now();
DateTime tempToDate = DateTime.now();

class ClientFundingUsageDetails extends StatefulWidget {
  final String authCode;
  final String userid;
  final int fundingID;
  final DateTime fromDate;
  final DateTime toDate;

  const ClientFundingUsageDetails({super.key, required this.authCode, required this.userid, required this.fundingID, required this.fromDate, required this.toDate});

  @override
  State<ClientFundingUsageDetails> createState() => _ClientFundingUsageDetailsState();
}

class _ClientFundingUsageDetailsState extends State<ClientFundingUsageDetails> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  String userName = "";
  ClientFundingUsage? fundingCode;
  List<ClientFundingUsage> fundingCodeList = [];
  int selectedExpandedIndex = -1;
  bool showAll = true;

  final TextEditingController _controllerSearch = TextEditingController();
  FocusScopeNode focusNode = FocusScopeNode();
  List<ClientFundingUsage> notesTempList = [];
  FocusScopeNode focusNavigatorNode = FocusScopeNode();

  int lastSelectedRow = -1;

  @override
  void initState() {
    super.initState();
    getFundingUsage();
  }

  getFundingUsage() async {
    var params = {
      'auth_code':
      (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'FundingCodeID': widget.fundingID.toString(),
      'fromdate': showAll ? '' : fromDate.shortDate(),
      'todate': showAll ? '' : toDate.shortDate(),
    };

    String url = getUrl(endClientFundingUsageDetails, params: params).toString();
    if(showAll) {
      String queryString = url;
      queryString = queryString.replaceAll("fromdate", "fromdate=");
      queryString = queryString.replaceAll("todate", "todate=");
      url = queryString;
    }

    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: url,
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
            List<ClientFundingUsage> dataList = jResponse
                .map((e) => ClientFundingUsage.fromJson(e))
                .toList();

            if (dataList.isNotEmpty) {
              fundingCodeList.clear();
              fundingCodeList.addAll(dataList);
              notesTempList.clear();
              notesTempList.addAll(dataList);
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, "Data Not Available!");
            }

            setState(() {
            });
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print('ERROR ${e}');
          fundingCodeList.clear();
          notesTempList.clear();
          showSnackBarWithText(_keyScaffold.currentState, "No claims item for selected period", color: colorGreen);
          setState(() {
          });
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
        body: _buildProgressNoteList()
    );
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
              final trimmedString = string.trim();
              performSearch(trimmedString);
            },
          ),
        ),
      ),
    );
  }

  void performSearch(String searchString) {
    if (searchString.isNotEmpty) {
      notesTempList = [];
      for (ClientFundingUsage model in fundingCodeList) {
        if ((model.name != null &&
            model.name!
                .toLowerCase()
                .contains(searchString.toLowerCase())) ||
            (model.fundinSource != null &&
                model.fundinSource!
                    .toLowerCase()
                    .contains(searchString.toLowerCase()))) {
          notesTempList.add(model);
        }
      }
    } else {
      notesTempList = [];
      notesTempList.addAll(fundingCodeList);
    }
    setState(() {});
  }

  _buildDateDialog() {
    setState(() {});
    showDialog(
      context: context,
      builder: (context) {
        return CustomDateDialog(
          fromDate: fromDate,
          toDate: toDate,
          onApply: (DateTime newFromDate, DateTime newToDate) {
            fromDate = newFromDate;
            toDate = newToDate;
            setState(() {});
            getFundingUsage();
          },
        );
      },
    );
  }

  String getStatusText() {
      return "${DateFormat("dd-MM-yyyy").format(fromDate)} - ${DateFormat("dd-MM-yyyy").format(toDate)}";
  }

  _buildProgressNoteList() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LabeledCheckbox(
              value: showAll,
              label: "Show All",
              leadingCheckbox: false,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                   showAll = value;
                   getFundingUsage();
                  });
                }
              },
            ),
            const SizedBox(width: spaceBetween),
            if(!showAll)
            InkWell(
              onTap: () {
                _buildDateDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: spaceHorizontal,
                  vertical: spaceHorizontal,
                ),
                child: ThemedText(
                  text: getStatusText(),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorGreyText,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            color: colorLiteBlueBackGround,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 10, left: 0),
                  child : SizedBox(
                    height: textFiledHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: spaceHorizontal),
                        Expanded(
                          // height: textFiledHeight,
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
                    text: "Funding Code Usage List",
                    color: Colors.black,
                    fontSize: 20,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: notesTempList.length,
                    primary: true,
                    itemBuilder: (context, index) {
                      ClientFundingUsage model = notesTempList[index];
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
                                                    text: model.isGroupService ? "${model.groupName} - ${model.name}" :
                                                    "${model.name}",
                                                    style:
                                                    const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.blueAccent,
                                                      fontWeight: FontWeight.bold,
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
                                            onTap: () {
                                              if (selectedExpandedIndex == index && selectedExpandedIndex != -1) {
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

                                                      const FaIcon(
                                                        FontAwesomeIcons
                                                            .calendarDays,
                                                        color: colorGreen,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(formatServiceDate(model.startTime),
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      const Icon(
                                                        Icons.access_time_outlined,
                                                        color: colorGreen,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text( "${model.totalHours}hrs",
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 13,
                                                        ),
                                                      ),
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ThemedRichText(
                                              spanList: [
                                                WidgetSpan(
                                                  child: Row(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(width: 40),
                                                      Text("Service Fee: \$${model.totalAmount.toString()} (excl.Expenses)",
                                                        style: const TextStyle(
                                                          color: colorGreyText,
                                                          fontSize: 13,
                                                        ),
                                                      ),
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
                                    getTimesheetsFunding(model);
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
                                  createBalanceRow(title: "Claim Hrs", openBalance: model.totalHours?.toDouble().toStringAsFixed(2) ?? "0.00"),
                                  const SizedBox(height: 7),
                                  createBalanceRow(title: "Quantity", openBalance: model.quantity.toString()),
                                  const SizedBox(height: 7),
                                  createBalanceRow(title: "Processed Claim", openBalance: model.processClaim.toString()),
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

  Widget createBalanceRow({required String title, required String openBalance}) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(
          child: ThemedText(
            text: "$title:",
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: ThemedText(
            text: openBalance,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  getTimesheetsFunding(ClientFundingUsage record) async {
    var params = {
      'auth_code':
      (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
      (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'rosterID': record.rosterID.toString(),
      'fromdate': widget.fromDate.shortDate(),
      'todate': widget.toDate.shortDate(),
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endtimesheetsFunding, params: params).toString(),
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
            List<TimeShiteModel> dataList =
            jResponse.map((e) => TimeShiteModel.fromJson(e)).toList();

            if (dataList.isNotEmpty) {

              Navigator.of(_keyScaffold
                  .currentContext!)
                  .push(MaterialPageRoute(
                builder: (context) =>
                    ServiceForm(
                      model: dataList[0],
                        indexSelectedFrom : 5
                    ),
              ));

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
}
