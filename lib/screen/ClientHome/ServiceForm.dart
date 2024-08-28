import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/ClientHome/model/CareWorker.dart';
import 'package:rcare_2/screen/ClientHome/model/RequestModel/CreateServiceRequest.dart';
import 'package:rcare_2/screen/ClientHome/model/RequestModel/ServiceFormUpdateRequest.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/LabeledCheckbox.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';
import '../home/models/ConfirmedResponseModel.dart';
import 'CareWorkerDialog.dart';
import 'ClientHomeScreen.dart';
import 'model/ClientServiceType.dart';

class ServiceForm extends StatefulWidget {
  final TimeShiteModel model;
  final int indexSelectedFrom;

  const ServiceForm(
      {super.key, required this.model, required this.indexSelectedFrom});

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  final multipleChoiceKey = GlobalKey<_MultipleChoiceState>();
  ServiceFormOption option = ServiceFormOption.add;
  List<String?> options = [];
  List<String> names = [];
  String selectedOption = '';
  String allNames = "";
  Calendar selectedInteral = Calendar.day;
  ClientServiceType? selectedService;
  List<ClientServiceType> serviceList = [];
  List<CareWorker> careWorkerList = [];
  List<ClientServiceType> fundingServiceList = [];
  late DateTime serviceDate;
  late DateTime serviceEndDate;
  int fromHour = 0;
  int fromMin = 0;
  int toHour = 0;
  int toMin = 0;
  int totalWorkMin = 0;
  double diffHours = 0;
  int breakMin = 0;
  String endOfClientServiceDate = "";

  int origionalMins = 0;

  int startBreakMin = 0;
  int endBreakMin = 0;
  int travelMin = 0;
  DateTime? sDate;
  String fromHourService = "00";
  final TextEditingController _controllerFromService = TextEditingController();
  String fromMinuteService = "00";

  String toHourService = "00";
  final TextEditingController _controllerToService = TextEditingController();
  String toMinuteService = "00";

  String hourLaunch = "00";
  final TextEditingController _controllerHourLaunch = TextEditingController();
  String minuteLaunch = "00";


  String fromHourLaunch = "00";
  final TextEditingController _controllerFromLaunch = TextEditingController();
  String fromMinuteLaunch = "00";

  String toHourLaunch = "00";
  final TextEditingController _controllerToLaunch = TextEditingController();
  String toMinuteLaunch = "00";

  String timeSheetTitle = "";

  Map<Day, String> dayToString = {
    Day.mon: '1',
    Day.tue: '2',
    Day.wed: '3',
    Day.thu: '4',
    Day.fri: '5',
    Day.sat: '6',
    Day.sun: '0',
  };


  final TextEditingController _controllerServiceType = TextEditingController();
  final TextEditingController _controllerServiceDate = TextEditingController();
  final TextEditingController _controllerServiceEndDate =
      TextEditingController();
  final TextEditingController _controllerHours = TextEditingController();
  final TextEditingController _controllerHoursDifference =
      TextEditingController();
  final TextEditingController _controllerTravelTime = TextEditingController();
  final TextEditingController _controllerTravelDistance =
      TextEditingController();
  final TextEditingController _controllerTravelDistanceMax =
      TextEditingController();
  final TextEditingController _controllerClientTravelDistance =
      TextEditingController();
  final TextEditingController _controllerComments = TextEditingController();
  final TextEditingController _controllerShiftComments =
      TextEditingController();

  bool isIncludeLaunchBrake = false;
  bool isClientFunding = false;
  bool isRecurringService = false;
  bool allowEdit = false;

  List<String> hourList =
      List.generate(23, (index) => index.toString().padLeft(2, '0'));
  List<String> minuteList =
      List.generate(60, (index) => index.toString().padLeft(2, '0'));

  String timeSheetValidation = "";
  bool isValidEndDate = false;

  Future<void> setEndServiceDate() async {
    endOfClientServiceDate =
        await Preferences().getPrefString(Preferences.prefEndofServiceDate);
    DateTime? endDate = getDateTimeFromEpochTime(endOfClientServiceDate);
    isValidEndDate =  (endDate?.year ??  2999) < 2900;
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setEndServiceDate();

    final Map<int, Map<String, dynamic>> optionsMap = {
      -1: {'option': ServiceFormOption.add, 'title': 'Add New'},
      0: {'option': ServiceFormOption.confirm, 'title': 'Confirmed'},
      1: {'option': ServiceFormOption.unconfirm, 'title': 'Unconfirmed'},
      2: {'option': ServiceFormOption.completed, 'title': 'Completed'},
      5: {'option': ServiceFormOption.funding, 'title': 'Service Details'},
    };

    final optionMap = optionsMap[widget.indexSelectedFrom];

    if (optionMap != null) {
      option = optionMap['option'];
      timeSheetTitle = optionMap['title'];
    } else {
      print("option default");
    }

    allowEdit = option == ServiceFormOption.add ||
        option == ServiceFormOption.unconfirm;
    if (widget.model.serviceDate != null) {
      if (option == ServiceFormOption.unconfirm) {
        loadClientServiceType();
      }
      if (option == ServiceFormOption.confirm) {
        getWorkerListForService();
      }
      isClientFunding = widget.model.fundingsourcename == "Cash" ? false : true;
      sDate = getDateTimeFromEpochTime(widget.model.serviceDate ?? "");
      serviceDate = sDate ?? DateTime.now();
      _controllerServiceType.text = widget.model.serviceName ?? "";
      selectedOption = widget.model.serviceName ?? "";
      _controllerServiceDate.text = DateFormat("dd-MM-yyyy").format(sDate!);
      if (widget.model.tSConfirm == false &&
          widget.model.timeFrom != null &&
          widget.model.timeFrom!.split(":").isNotEmpty) {
        _controllerFromService.text = widget.model.timeFrom!;
        var list = widget.model.timeFrom!.split(":");
        fromHour = int.parse(list.first);
        fromMin = int.parse(list.last);
      }
      if (widget.model.tSConfirm == true &&
          widget.model.tSFrom != null &&
          widget.model.tSFrom!.split(":").isNotEmpty) {
        _controllerFromService.text = widget.model.tSFrom!;
        var list = widget.model.tSFrom!.split(":");
        fromHour = int.parse(list.first);
        fromMin = int.parse(list.last);
      }

      if (widget.model.tSConfirm == false &&
          widget.model.timeUntil != null &&
          widget.model.timeUntil!.split(":").isNotEmpty) {
        _controllerToService.text = widget.model.timeUntil!;
        var list = widget.model.timeUntil!.split(":");
        toHour = int.parse(list.first);
        toMin = int.parse(list.last);
      }
      if (widget.model.tSConfirm == true &&
          widget.model.tSUntil != null &&
          widget.model.tSUntil!.split(":").isNotEmpty) {
        _controllerToService.text = widget.model.tSUntil!;
        var list = widget.model.tSUntil!.split(":");
        toHour = int.parse(list.first);
        toMin = int.parse(list.last);
      }
      if (widget.model.tSHours != null) {
        totalWorkMin = (widget.model.tSHours!.toDouble() * 60).toInt();
      }

      isIncludeLaunchBrake = widget.model.tSLunchBreakSetting ?? false;
      if (widget.model.tSLunchBreak != null &&
          widget.model.tSLunchBreak!.split(":").isNotEmpty) {
        _controllerHourLaunch.text = widget.model.tSLunchBreak!;
        if (widget.model.tSLunchBreak!.split(":").length > 1) {
          // _controllerMinuteLaunch.text = widget.model.tSLunchBreak!.split(":")[1];
        }
      }
      if (widget.model.tSLunchBreakFrom != null &&
          widget.model.tSLunchBreakFrom!.split(":").isNotEmpty) {
        _controllerFromLaunch.text = widget.model.tSLunchBreakFrom!;
      } else {
        _controllerFromLaunch.text = "00:00";
      }
      if (widget.model.tSLunchBreakTo != null &&
          widget.model.tSLunchBreakTo!.split(":").isNotEmpty) {
        _controllerToLaunch.text = widget.model.tSLunchBreakTo!;
      } else {
        _controllerToLaunch.text = "00:00";
      }

      if (widget.model.tSHours != null) {
        _controllerHours.text =
            getTimeStringFromDouble(widget.model.tSHours!.toDouble());
        origionalMins = (widget.model.tSHours! * 60).toInt();
      }
      if (widget.model.tSHoursDiff != null) {
        diffHours = widget.model.tSHoursDiff!.toDouble();
      }
      if (widget.model.tSConfirm == true) {
        timeSheetValidation =
            "Timesheet Submitted.Only comments can be updated!";
      }
      _controllerHoursDifference.text = widget.model.tSHoursDiff.toString();
      _controllerTravelTime.text = getTimeStringFromDouble(
          double.tryParse(widget.model.tSTravelTime.toString()) ?? 0.0);

      _controllerTravelDistance.text =
          widget.model.tSTravelDistance!.toDouble().toString();
      if (widget.model.tSTravelDistance! <= 0.0) {
        _controllerTravelDistance.text = "";
      }

      _controllerTravelDistanceMax.text =
          widget.model.maxTravelDistance!.toDouble().toString();

      _controllerTravelDistanceMax.text =
          widget.model.maxTravelDistance!.toDouble().toString();

      _controllerClientTravelDistance.text =
          widget.model.clienttraveldistance!.toDouble().toString();
      if (widget.model.clienttraveldistance! <= 0.0) {
        _controllerClientTravelDistance.text = "";
      }
      //  isRecurring = false;
      _controllerComments.text = widget.model.comments ?? "";
      _controllerShiftComments.text = widget.model.shiftComments ?? "";
    }
    _controllerServiceType.text =
        selectedOption.isNotEmpty ? selectedOption : "";
    setState(() {});
  }

  showConfirmationDialog(
      {required void Function() onYesTap,
      required void Function() onNoTap,
      String? extendedText}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: boxBorderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 20),
                ThemedText(
                  text: "Delete Service",
                  color: colorBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(child:
                ThemedText(
                  text: "Are you sure you want to Delete\nthis Service Schedule?",
                  color: colorBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),

                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: spaceVertical),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  const SizedBox(width: spaceHorizontal * 2),
                  Expanded(
                    child: ThemedButton(
                      title: "OK",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      padding: EdgeInsets.zero,
                      onTap: onYesTap,
                    ),
                  ),
                  const SizedBox(width: spaceHorizontal),
                  Expanded(
                    child: ThemedButton(
                      title: "Cancel",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      padding: EdgeInsets.zero,
                      onTap: onNoTap,
                    ),
                  ),
                  const SizedBox(width: spaceHorizontal * 2),
                ],
              ),
            ),
            const SizedBox(height: spaceVertical),
          ],
        ),
      ),
    );
  }

  validateAndSaveForm(){
    int startMinTs = (fromHour * 60) + fromMin;
    int endMinTs = (toHour * 60) + toMin;
    if (endMinTs < startMinTs) {
      endMinTs = endMinTs + 1440;
    }

    if (option == ServiceFormOption.add) {
      if (_controllerServiceDate.text == "") {
        showSnackBarWithText(
            _keyScaffold.currentState,
            "Please select service date",
            color: colorRed);
        return;
      }
      if (selectedService == null) {
        showSnackBarWithText(
            _keyScaffold.currentState,
            isClientFunding
                ? "Please select funding service type"
                : "Please select service type",
            color: colorRed);
        return;
      }
      if (startMinTs == 0) {
        showSnackBarWithText(
            _keyScaffold.currentState,
            "Please enter valid From Time",
            color: colorRed);
        return;
      }
      if (endMinTs == 0) {
        showSnackBarWithText(
            _keyScaffold.currentState,
            "Please enter a valid Until Time",
            color: colorRed);
        return;
      }
      if (startMinTs == endMinTs) {
        showSnackBarWithText(
            _keyScaffold.currentState,
            "Please enter a valid Until Time",
            color: colorRed);
        return;
      }

      saveTimeSheet();
    } else if (option ==
        ServiceFormOption.unconfirm) {
      updateTimeSheet();
    } else if (option ==
        ServiceFormOption.confirm) {
      updateShiftComment();
    }
  }
  bool showSaveButtonOnBar(){

    if (option == ServiceFormOption.unconfirm || option == ServiceFormOption.completed || option == ServiceFormOption.funding){
      return false;
    }
    else if (option == ServiceFormOption.confirm || option == ServiceFormOption.add){
      return true;
    }
    else if (option != ServiceFormOption.funding && !(widget.model.completeCW ?? false)){
      return false;
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: colorLiteBlueBackGround,
      appBar: buildAppBar(context, title: timeSheetTitle , showActionButton: showSaveButtonOnBar() , onActionButtonPressed: () {
        validateAndSaveForm();
      },),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: spaceHorizontal, vertical: spaceVertical),
          child: Column(
            children: [
              Container(
                color: colorWhite,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    if (option != ServiceFormOption.add)
                    const SizedBox(height: 10),
              if (option == ServiceFormOption.unconfirm)
                    SizedBox(
                      height: textFiledHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!showSaveButtonOnBar())
                            const SizedBox(width: spaceHorizontal),
                          if (option != ServiceFormOption.funding &&
                              !(widget.model.completeCW ?? false))
                            Expanded(
                              child: ThemedButton(
                                padding: EdgeInsets.zero,
                                title: "Save",
                                fontSize: 14,
                                onTap: () async {
                                  validateAndSaveForm();
                                }
                              ),
                            ),
                          if (widget.indexSelectedFrom == 1)
                            const SizedBox(width: spaceHorizontal),
                          if (widget.indexSelectedFrom == 1)
                            Expanded(
                              // height: textFiledHeight,
                              child: ThemedButton(
                                padding: EdgeInsets.zero,
                                title: "Delete",
                                fontSize: 14,
                                onTap: () async {
                                  showConfirmationDialog(onYesTap: () {
                                    Navigator.pop(context);
                                    if (keyScaffold.currentState != null) {
                                      keyScaffold.currentState!
                                          .closeEndDrawer();
                                    }
                                    deleteService();
                                  }, onNoTap: () {
                                    Navigator.pop(context);
                                    if (keyScaffold.currentState != null) {
                                      keyScaffold.currentState!
                                          .closeEndDrawer();
                                    }
                                  });
                                },
                              ),
                            ),
                          const SizedBox(width: spaceHorizontal),
                        ],
                      ),
                    ),
                    if (widget.indexSelectedFrom >= 0)
                      Column(children: [
                        SizedBox(height: option == ServiceFormOption.unconfirm ? 20 : 10),
                        ThemedText(
                          text: widget.model.resName ?? "",
                          color: colorBlack,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: spaceVertical / 2),
                        ThemedText(
                          text: widget.model.isGroupService ? widget.model.groupName ?? "" : widget.model.serviceName ?? "",
                          color: colorBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(height: spaceVertical / 2),
                        Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * .9,
                            color: colorDivider),
                        const SizedBox(height: spaceVertical / 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: colorGreen,
                              size: 18,
                            ),
                            const SizedBox(width: spaceHorizontal),
                            Text(
                              formatServiceDate(widget.model.serviceDate),
                              style: const TextStyle(
                                color: colorBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.timer,
                              color: colorGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.model.shift ?? "",
                              style: const TextStyle(
                                  color: colorBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        const SizedBox(height: spaceVertical / 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.time,
                              color: colorGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.model.totalHours}hrs",
                              style: const TextStyle(
                                  color: colorBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            const SizedBox(width: spaceHorizontal),
                            ThemedText(
                              text:
                                  "Lunch Break : ${widget.model.tSLunchBreak ?? ""}",
                              color: colorBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            ThemedText(
                              text:
                                  "Travel Dist.: ${widget.model.tSTravelDistance?.toDouble().toString() ?? "0.00"}",
                              color: colorBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        if (option == ServiceFormOption.confirm ||
                            option == ServiceFormOption.completed)
                          const SizedBox(height: 7),
                        if (option == ServiceFormOption.confirm ||
                            option == ServiceFormOption.completed)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Text(
                              "Care Worker:",
                              style: TextStyle(
                                  color: colorBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.model.emplName}",
                              style: const TextStyle(
                                  color: colorBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            if ((option == ServiceFormOption.confirm ||
                                option == ServiceFormOption.completed) && careWorkerList.length > 1)
                              TextButton(
                              onPressed: () {
                                // Handle button press
                                _showAllCareWorker(context);

                              },
                              child: const Text(
                                '(Show all)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  /* decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,*/
                                ),
                              ),
                            ),
                          ]

                          ),
                        const SizedBox(height: spaceVertical/2),
                        Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * .9,
                            color: colorDivider),
                        const SizedBox(height: spaceVertical),
                      ])
                  ],
                ),
              ),
              const SizedBox(height: spaceVertical),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isValidEndDate)
                    ThemedText(
                      text: "Service End Date ${DateFormat("dd-MM-yyyy").format(getDateTimeFromEpochTime(endOfClientServiceDate) ?? DateTime(2101))}",
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    if (isValidEndDate)
                    const SizedBox(height: spaceBetween),
                    ThemedText(
                      text: "Service Date",
                      fontSize: 14,
                      color: colorBlack,
                    ),
                    SizedBox(
                      height: textFiledHeight,
                      child: ThemedTextField(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: allowEdit ? colorWhite : colorGreyE8,
                        sufFix: allowEdit
                            ? const Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.grey,
                                size: 30.0,
                              )
                            : null,
                        isReadOnly: true,
                        hintText: "Select Date",
                        controller: _controllerServiceDate,
                        onTap: allowEdit
                            ? () {
                                showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().addDays(1),
                                        firstDate: DateTime.now().addDays(1),
                                        lastDate: getDateTimeFromEpochTime(
                                    endOfClientServiceDate) ??
                                    DateTime(2101))
                                    .then((value) {
                                  if (value != null) {
                                    setState(() {
                                      serviceDate = DateTime(
                                          value.year, value.month, value.day);
                                      ;
                                      _controllerServiceDate.text =
                                          DateFormat("dd-MM-yyyy").format(
                                        serviceDate,
                                      );
                                      loadClientServiceType();
                                    });
                                  }
                                });
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: spaceBetween),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      LabeledCheckbox(
                        value: isClientFunding,
                        label: "Client Funding",
                        leadingCheckbox: false,
                        onChanged: (_controllerServiceDate.text.isNotEmpty)
                            ? (bool? value) {
                          if (value != null) {
                            setState(() {
                              isClientFunding = value;
                              _controllerServiceType.text = "";
                              selectedService = null;
                              options = isClientFunding
                                  ? fundingServiceList
                                  .map((obj) => obj.serviceTypeName)
                                  .toList()
                                  : serviceList
                                  .map((obj) => obj.serviceTypeName)
                                  .toList();
                            });
                          }
                        }
                            : null,
                        isReadOnly: !(allowEdit &&
                            option != ServiceFormOption.unconfirm &&
                            _controllerServiceDate.text.isNotEmpty),
                      ),
                      const SizedBox(width: 5),
                      if(option != ServiceFormOption.add)
                      Text(
                        "${widget.model.fundingsourcename}",
                        style: const TextStyle(
                            color: colorBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ]),


                    Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ThemedText(
                            text: isClientFunding
                                ? "Funding Service Type"
                                : "Service Type",
                            fontSize: 14,
                            color: colorBlack,
                          ),
                          SizedBox(
                            height: textFiledHeight,
                            child: ThemedTextField(
                                hintText: "Select Service Type",
                                padding: const EdgeInsets.symmetric(
                                    horizontal: spaceHorizontal),
                                borderColor: colorGreyBorderD3,
                                backgroundColor: option == ServiceFormOption.add
                                    ? colorWhite
                                    : colorGreyE8,
                                isReadOnly: true,
                                sufFix: allowEdit
                                    ? const Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Colors.grey,
                                        size: 30.0,
                                      )
                                    : null,
                                controller: _controllerServiceType,
                                onTap: option == ServiceFormOption.add
                                    ? () async {
                                        if (isClientFunding &&
                                            fundingServiceList.isEmpty) {
                                          showSnackBarWithText(
                                              keyScaffold.currentState,
                                              "No funded services available for current period");
                                          return;
                                        }
                                        if (!isClientFunding &&
                                            serviceList.isEmpty) {
                                          showSnackBarWithText(
                                              keyScaffold.currentState,
                                              "Please contact administrator to setup service types for current period");
                                          return;
                                        }

                                        options = isClientFunding
                                            ? fundingServiceList
                                                .map((obj) =>
                                                    obj.serviceTypeName)
                                                .toList()
                                            : serviceList
                                                .map((obj) =>
                                                    obj.serviceTypeName)
                                                .toList();
                                        print(option);
                                        if (_controllerServiceDate
                                            .text.isNotEmpty) {
                                          _showSingleSelectAlert(context);
                                          _controllerServiceType.text =
                                              selectedOption;
                                        }
                                        setState(() {});
                                      }
                                    : null),
                          ),
                        ]),
                    const SizedBox(height: spaceBetween),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "From Time*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  sufFix: const Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: Colors.grey,
                                    size: 30.0,
                                  ),
                                  controller: _controllerFromService,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  onTap: () async {
                                    if (option == ServiceFormOption.add ||
                                        option == ServiceFormOption.unconfirm) {
                                      showTimePickerDialog(
                                        initialTimeText:
                                            _controllerFromService.text,
                                        onTimePick: (hours, minutes) {
                                          fromHour = hours;
                                          fromMin = minutes;
                                          calculateHours();
                                          _controllerFromService.text =
                                              "${get2CharString(hours)}:${get2CharString(minutes)}";

                                          _controllerToService.text =
                                              "${get2CharString(toHour)}:${get2CharString(toMin)}";

                                          setState(() {});
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "Until Time*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  sufFix: const Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: Colors.grey,
                                    size: 30.0,
                                  ),
                                  controller: _controllerToService,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  onTap: () async {
                                    if (option == ServiceFormOption.add ||
                                        option == ServiceFormOption.unconfirm) {
                                      showTimePickerDialog(
                                        initialTimeText:
                                            _controllerToService.text,
                                        onTimePick: (hours, minutes) {
                                          toHour = hours;
                                          toMin = minutes;
                                          calculateHours();
                                          _controllerToService.text =
                                              "${get2CharString(hours)}:${get2CharString(minutes)}";
                                          setState(() {});
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "Hours(hh:mm)",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  controller: _controllerHours,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  onTap: () async {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: spaceBetween),
                    if (option == ServiceFormOption.completed)
                      Row(
                        children: [
                          ThemedText(
                            text: "TS Lunch Break*",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          Radio<bool>(
                            value: true,
                            groupValue: isIncludeLaunchBrake,
                            activeColor: colorGreen,
                            onChanged: widget.model.tSConfirm == true
                                ? null
                                : (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        isIncludeLaunchBrake = value;
                                      });
                                    }
                                  },
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isIncludeLaunchBrake = true;
                              });
                            },
                            child: ThemedText(
                              text: "Yes",
                              color: colorBlack,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Radio<bool>(
                            value: false,
                            groupValue: isIncludeLaunchBrake,
                            activeColor: colorGreen,
                            onChanged: widget.model.tSConfirm == true
                                ? null
                                : (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        isIncludeLaunchBrake = value;
                                      });
                                    }
                                  },
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isIncludeLaunchBrake = false;
                              });
                            },
                            child: ThemedText(
                              text: "No",
                              color: colorBlack,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: spaceBetween),
                    if (isIncludeLaunchBrake)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch Break",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        controller: _controllerHourLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorGreyE8,
                                        isReadOnly: true,
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: spaceBetween),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch From",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        sufFix: const Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color: Colors.grey,
                                          size: 30.0,
                                        ),
                                        controller: _controllerFromLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        isReadOnly: true,
                                        onTap: widget.model.tSConfirm == true
                                            ? () {}
                                            : () async {
                                                showTimePickerDialog(
                                                  initialTimeText:
                                                      _controllerFromLaunch
                                                          .text,
                                                  onTimePick: (hours, minutes) {
                                                    int tempstartBreakMin =
                                                        (hours * 60) + minutes;
                                                    int startMinTs =
                                                        (fromHour * 60) +
                                                            fromMin;
                                                    int endMinTs =
                                                        (toHour * 60) + toMin;
                                                    if (endMinTs < startMinTs) {
                                                      endMinTs =
                                                          endMinTs + 1440;
                                                      if (tempstartBreakMin <
                                                          startMinTs) {
                                                        tempstartBreakMin +=
                                                            1440;
                                                      }
                                                    }

                                                    print(
                                                        startMinTs.toString());
                                                    print(endMinTs.toString());
                                                    print(tempstartBreakMin
                                                        .toString());

                                                    if (tempstartBreakMin <
                                                            startMinTs ||
                                                        tempstartBreakMin >
                                                            endMinTs) {
                                                      showSnackBarWithText(
                                                          _keyScaffold
                                                              .currentState,
                                                          "Please enter valid lunch break time",
                                                          color: colorRed);
                                                      return;
                                                    } else {
                                                      startBreakMin =
                                                          tempstartBreakMin;
                                                    }

                                                    _controllerFromLaunch.text =
                                                        "${get2CharString(hours)}:${get2CharString(minutes)}";
                                                    String diff =
                                                        findDurationDifference(
                                                            _controllerFromLaunch
                                                                .text,
                                                            _controllerToLaunch
                                                                .text);
                                                    _controllerHourLaunch.text =
                                                        diff;
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: spaceHorizontal / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch To",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        sufFix: const Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color: Colors.grey,
                                          size: 30.0,
                                        ),
                                        controller: _controllerToLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        isReadOnly: true,
                                        onTap: widget.model.tSConfirm == true
                                            ? () {}
                                            : () async {
                                                showTimePickerDialog(
                                                  initialTimeText:
                                                      _controllerToLaunch.text,
                                                  onTimePick: (hours, minutes) {
                                                    int tempEndBreakMin =
                                                        (hours * 60) + minutes;
                                                    int startMinTs =
                                                        (fromHour * 60) +
                                                            fromMin;

                                                    int endMinTs =
                                                        (toHour * 60) + toMin;
                                                    if (endMinTs < startMinTs) {
                                                      endMinTs =
                                                          endMinTs + 1440;
                                                    }
                                                    if (tempEndBreakMin <
                                                        startBreakMin) {
                                                      tempEndBreakMin =
                                                          tempEndBreakMin +
                                                              1440;
                                                    }
                                                    print(startBreakMin
                                                        .toString());
                                                    print(endMinTs.toString());
                                                    print(tempEndBreakMin
                                                        .toString());

                                                    if (startBreakMin == 0 &&
                                                        endMinTs > 1440) {
                                                      showSnackBarWithText(
                                                          _keyScaffold
                                                              .currentState,
                                                          "Please enter start lunch break time",
                                                          color: colorRed);
                                                      return;
                                                    }

                                                    print(startBreakMin
                                                        .toString());
                                                    print(endMinTs.toString());
                                                    print(tempEndBreakMin
                                                        .toString());
                                                    print(
                                                        startMinTs.toString());

                                                    if (tempEndBreakMin <
                                                            startBreakMin ||
                                                        tempEndBreakMin <
                                                            startMinTs) {
                                                      showSnackBarWithText(
                                                          _keyScaffold
                                                              .currentState,
                                                          "Please enter valid lunch break time",
                                                          color: colorRed);
                                                      return;
                                                    } else {
                                                      endBreakMin =
                                                          tempEndBreakMin;
                                                    }

                                                    _controllerToLaunch.text =
                                                        "${get2CharString(hours)}:${get2CharString(minutes)}";
                                                    breakMin = endBreakMin -
                                                        startBreakMin;
                                                    print(breakMin.toString());
                                                    int h =
                                                        (breakMin / 60).toInt();
                                                    int m =
                                                        (breakMin % 60).toInt();
                                                    print(h.toString());
                                                    print(m.toString());
                                                    _controllerHourLaunch.text =
                                                        "${get2CharString(h)}:${get2CharString(m)}";
                                                    /* String diff =
                                                        findDurationDifference(
                                                            _controllerFromLaunch
                                                                .text,
                                                            _controllerToLaunch
                                                                .text);*/
                                                    calculateHours();

                                                    setState(() {});
                                                  },
                                                );
                                              },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: spaceHorizontal / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch Break",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        controller: _controllerToLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        isReadOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: spaceBetween),
                    if (widget.indexSelectedFrom < 0)
                      LabeledCheckbox(
                          value: isRecurringService,
                          label: "Recurring",
                          leadingCheckbox: false,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                isRecurringService = value;
                                if (selectedInteral == Calendar.day &&
                                    isRecurringService) {
                                  print('Selected Sizes: $selectedInteral');
                                  multipleChoiceKey.currentState?.selectAll();
                                } else {
                                  print('Selected Sizes: $selectedInteral');
                                  multipleChoiceKey.currentState?.reset();
                                }
                              });
                            }
                          }),
                    if (isRecurringService)
                      Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ThemedRichText(spanList: [
                              getTextSpan(
                                text: "Interval (Single Choice)",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontColor: colorBlack,
                              )
                            ]),
                            const SizedBox(height: spaceBetween),
                            SingleChoice(
                              key: UniqueKey(),
                              onChanged: (selectedValues) {
                                // Perform any actions with the selected values
                                print('Selected Sizes: $selectedValues');
                                selectedInteral = selectedValues;
                                print('Selected Sizes: $selectedInteral');
                                if (selectedValues == Calendar.day) {
                                  print('Selected Sizes: $selectedValues');
                                  multipleChoiceKey.currentState?.selectAll();
                                } else {
                                  multipleChoiceKey.currentState?.reset();
                                }
                              },
                              initialSelection: Calendar.day,
                            ),
                            const SizedBox(height: spaceBetween * 2),
                            ThemedRichText(spanList: [
                              getTextSpan(
                                text: "Days (Multiple Choice)",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontColor: colorBlack,
                              )
                            ]),
                            const SizedBox(height: spaceBetween),
                            MultipleChoice(
                              key: multipleChoiceKey,
                            ),
                            const SizedBox(height: spaceBetween),
                            ThemedText(
                              text: "Service End",
                              fontSize: 14,
                              color: colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(
                              height: textFiledHeight,
                              child: ThemedTextField(
                                hintText: "Select Date",
                                sufFix: const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Colors.grey,
                                  size: 30.0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: spaceHorizontal),
                                borderColor: colorGreyBorderD3,
                                backgroundColor: colorWhite,
                                isReadOnly: true,
                                controller: _controllerServiceEndDate,
                                onTap:  () {
                                  showDatePicker(
                                          context: context,
                                          initialDate:
                                              serviceDate.addDays(1),
                                          firstDate: serviceDate.addDays(1),
                                          lastDate: getDateTimeFromEpochTime(
                                                  endOfClientServiceDate) ??
                                              DateTime(2101))
                                      .then((value) {
                                    if (value != null) {
                                      setState(() {
                                        serviceEndDate = DateTime(
                                            value.year, value.month, value.day);
                                        _controllerServiceEndDate.text =
                                            DateFormat("dd-MM-yyyy").format(
                                          serviceEndDate,
                                        );
                                      });
                                    }
                                  });
                                } ,
                              ),
                            ),
                          ]),
                    if (option != ServiceFormOption.add)
                      const SizedBox(height: spaceBetween),
                    if (option != ServiceFormOption.add)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemedText(
                                  text: "SubTotal",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                ThemedText(
                                    text:
                                        "\$${widget.model.calculatedDost ?? "0"}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                          ),
                          const SizedBox(width: spaceHorizontal / 2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemedText(
                                  text: "Expense",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                ThemedText(
                                    text:
                                        "\$${widget.model.expenseTotal ?? "0"}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                          ),
                          const SizedBox(width: spaceHorizontal / 2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemedText(
                                  text: "Total (incl GST)",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                ThemedText(
                                    text:
                                        "\$${widget.model.totalAmountwithGST ?? "0"}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (option != ServiceFormOption.add)
                      const SizedBox(height: spaceBetween),
                    if (option != ServiceFormOption.add)
                      Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ThemedRichText(spanList: [
                              getTextSpan(
                                text: "Shift Comments",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontColor: colorBlack,
                              ),
                            ]),
                            const SizedBox(height: spaceBetween),
                            ThemedTextField(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: spaceHorizontal),
                              borderColor: colorGreyBorderD3,
                              backgroundColor: option == ServiceFormOption.add
                                  ? colorWhite
                                  : colorGreyE8,
                              maxLine: 5,
                              minLine: 5,
                              isReadOnly: option != ServiceFormOption.add,
                              controller: _controllerShiftComments,
                            ),
                          ]),
                    const SizedBox(height: spaceBetween),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: spaceBetween),
                          ThemedRichText(spanList: [
                            getTextSpan(
                              text: "Client Comments",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontColor: colorBlack,
                            ),
                          ]),
                          const SizedBox(height: spaceBetween),
                          ThemedTextField(
                            padding: const EdgeInsets.symmetric(
                                horizontal: spaceHorizontal),
                            borderColor: colorGreyBorderD3,
                            backgroundColor:
                                (option == ServiceFormOption.funding ||
                                        option == ServiceFormOption.completed)
                                    ? colorGreyE8
                                    : colorWhite,
                            maxLine: 5,
                            minLine: 5,
                            isReadOnly: (option == ServiceFormOption.funding ||
                                option == ServiceFormOption.completed),
                            controller: _controllerComments,
                          ),
                        ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  calculateHours() {
    print(fromHour);
    print(fromMin);
    print(toHour);
    print(toMin);
    print(origionalMins);
    print(breakMin);

    int diff = ((toHour * 60) + toMin) - ((fromHour * 60) + fromMin);
    if (diff < 0) {
      diff = diff + 1440;
    }
    totalWorkMin = diff;
    print(diff);
    int totalHours = (diff / 60).toInt();
    int totalMin = (diff % 60).toInt();
    _controllerHours.text =
        "${get2CharString(totalHours)}:${get2CharString(totalMin)}";
    print(diff);
    print(origionalMins);
    double diffMin = ((((diff - breakMin) - origionalMins) * 100) / 60) / 100;
    print(diffMin);
    String stdiffMin = diffMin.toStringAsFixed(2);
    diffHours = double.parse(stdiffMin);
    _controllerHoursDifference.text = "$diffHours";
  }

  showTimePickerDialog(
      {required String? initialTimeText,
      required void Function(int hours, int minutes) onTimePick}) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialTimeText != null
            ? int.tryParse(initialTimeText.split(":").first) ??
                TimeOfDay.now().hour
            : TimeOfDay.now().hour,
        minute: initialTimeText != null
            ? int.tryParse(initialTimeText.split(":").last) ??
                TimeOfDay.now().minute
            : TimeOfDay.now().minute,
      ),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (newTime != null) {
      onTimePick(newTime.hour, newTime.minute);
    }
  }

  String findDurationDifference(String dataFromString, String dataToString) {
    int fromHourLaunch = dataFromString.isNotEmpty
        ? int.tryParse(dataFromString.split(":").first) ?? TimeOfDay.now().hour
        : TimeOfDay.now().hour;
    int fromMinuteLaunch = dataFromString.isNotEmpty
        ? int.tryParse(dataFromString.split(":").last) ?? TimeOfDay.now().minute
        : TimeOfDay.now().minute;
    int toHourLaunch = dataToString.isNotEmpty
        ? int.tryParse(dataToString.split(":").first) ?? TimeOfDay.now().hour
        : TimeOfDay.now().hour;
    int toMinuteLaunch = dataToString.isNotEmpty
        ? int.tryParse(dataToString.split(":").last) ?? TimeOfDay.now().minute
        : TimeOfDay.now().minute;

    Duration difference = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, toHourLaunch, toMinuteLaunch)
        .difference(DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, fromHourLaunch, fromMinuteLaunch));
    int hour = difference.inHours;
    int minute = difference.inMinutes;
    breakMin = (hour * 60) + minute;

    setState(() {
      if (hour >= 0) {
        hourLaunch = hour < 10 ? "0$hour" : hour.toString();
        if (minute >= 0) {
          minuteLaunch = (minute % 60) < 10
              ? "0${(minute % 60)}"
              : (minute % 60).toString();
        } else {
          minuteLaunch = "00";
        }
      } else {
        hourLaunch = "00";
        minuteLaunch = "00";
      }
    });
    print("Launch : $hourLaunch:$minuteLaunch");
    return "$hourLaunch:$minuteLaunch";
  }

  get2CharString(int data) {
    return data > 9 ? data.toString() : "0$data";
  }

  saveTimeSheet() async {
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          CreateServiceRequest request = CreateServiceRequest();
          request.authCode =
              await Preferences().getPrefString(Preferences.prefAuthCode);
          request.userid =
              (await Preferences().getPrefInt(Preferences.prefUserID));
          request.serviceDate = serviceDate.shortDate();
          request.timeFrom = "1899-12-30 ${_controllerFromService.text}";
          request.timeUntil = "1899-12-30 ${_controllerToService.text}";
          request.totalHours = totalWorkMin / 60;
          request.servicetypeID = selectedService?.serviceTypeid;
          request.comments = _controllerComments.text;
          request.shiftComments = _controllerShiftComments.text;
          request.isFunded = isClientFunding ? 1 : 0;
          request.rate = double.parse(selectedService?.baseRate ?? "0.0");
          request.isRecurring = isRecurringService;
          if (isRecurringService) {
            request.interval = selectedInteral == Calendar.day
                ? 1
                : (selectedInteral == Calendar.week ? 7 : 14);
            request.daysOfWeek = multipleChoiceKey.currentState?.selection
                .map((day) => dayToString[day]!)
                .join(',');
            request.endOfServiceDate = serviceEndDate.shortDate();
          } else {
            request.interval = 0;
            request.daysOfWeek = "";
            request.endOfServiceDate = "";
          }
          print("4");

          String body = json.encode(request);
          print(body);

          if (body.isEmpty) {
            return;
          }

          Response response = await http.post(
              Uri.parse("$masterURL$createServiceRequest"),
              headers: {"Content-Type": "application/json"},
              body: body);
          log("Response $endSaveTimesheet : ${response.body}");
          if (response != null) {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
              var message =  jres["message"].toString();
              if (message.contains("Insufficient")){
                var sucessMessage = message.split("\n");
                if(sucessMessage.length > 0) {
                  showSufficentBalance(
                      _keyScaffold.currentState, sucessMessage[0], color: colorOrange);
                }
              }
              else {
                showSnackBarWithText(_keyScaffold.currentState, "Success",
                    color: colorGreen);
                Navigator.pop(context, 0);
              }
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          log("SignUp $e");
          removeOverlay();
          throw e;
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  updateTimeSheet() async {
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          ServiceFormUpdateRequest request = ServiceFormUpdateRequest();
          request.authCode =
              await Preferences().getPrefString(Preferences.prefAuthCode);
          request.userid =
              (await Preferences().getPrefInt(Preferences.prefUserID));
          request.serviceDate = serviceDate.shortDate();
          request.timeFrom = "1899-12-30 ${_controllerFromService.text}";
          request.timeUntil = "1899-12-30 ${_controllerToService.text}";
          request.totalHours = totalWorkMin / 60;
          request.servicetypeID = widget.model.tsservicetype;
          request.comments = _controllerComments.text;
          request.isFunded = isClientFunding ? 1 : 0;
          request.rosterId = widget.model.rosterID;
          print("4");

          String body = json.encode(request);
          print(body);

          if (body.isEmpty) {
            return;
          }

          Response response = await http.post(
              Uri.parse("$masterURL$updateServiceRequest"),
              headers: {"Content-Type": "application/json"},
              body: body);
          log("Response $endSaveTimesheet : ${response.body}");
          if (response != null) {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
              showSnackBarWithText(_keyScaffold.currentState, "Success",
                  color: colorGreen);
              Navigator.pop(context, 0);
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          log("SignUp $e");
          removeOverlay();
          throw e;
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  deleteService() async {
    print("availableDataList getAvailableShiftsData");
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      "RosterID": widget.model.rosterID.toString()
    };
    print("getAvailableShiftsData : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endDeleteService, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          print("availableDataList $endAvailableShifts $response");
          removeOverlay();
          if (response != null && response != "") {
            print('res ${response}');
            showSnackBarWithText(
                _keyScaffold.currentState, "Deleted Successfully!",
                color: colorGreen);
            Navigator.pop(context, 0);
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          setState(() {});
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  loadFundingServiceType() async {
    print("availableDataList getAvailableShiftsData");
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      "servicedate": DateFormat("yyyy-MM-dd").format(serviceDate)
    };
    print("getAvailableShiftsData : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(getFundingServiceType, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          print("availableDataList $endAvailableShifts $response");
          removeOverlay();
          if (response != null && response != "") {
            print('res $response');

            List jResponse = json.decode(response);
            fundingServiceList.clear();
            fundingServiceList =
                jResponse.map((e) => ClientServiceType.fromJson(e)).toList();
            print("availableDataList : ${fundingServiceList.length}");
            if (option == ServiceFormOption.unconfirm) {
              print("selected service : ${fundingServiceList.length}");
              if (isClientFunding) {
                selectedService = fundingServiceList.firstWhere((service) =>
                    service.serviceTypeid == widget.model.tsservicetype);
              }
            } else {
              setState(() {});
            }
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          setState(() {});
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  loadClientServiceType() async {
    print("ServiceForm loadClientServiceType");
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      "servicedate": DateFormat("yyyy-MM-dd").format(serviceDate)
    };
    print("getAvailableShiftsData : $params");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(getServiceType, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          print("Response $endAvailableShifts $response");
          removeOverlay();
          if (response != null && response != "") {
            List jResponse = json.decode(response);
            serviceList.clear();
            serviceList =
                jResponse.map((e) => ClientServiceType.fromJson(e)).toList();
            print("serviceList : ${serviceList.length}");
            // setState(() {});

            if (option == ServiceFormOption.unconfirm) {
              print("ServiceForm loadClientServiceType");
              print(widget.model.tsservicetype);
              if (!isClientFunding) {
                selectedService = serviceList.firstWhere((service) =>
                    service.serviceTypeid == widget.model.tsservicetype);
              }
            } else {
              setState(() {});
            }

            loadFundingServiceType();
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          setState(() {});
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  updateShiftComment() async {
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          String body = json.encode({
            'auth_code':
                (await Preferences().getPrefString(Preferences.prefAuthCode)),
            'RosterId': widget.model.rosterID != null
                ? widget.model.rosterID.toString()
                : "0",
            'SSCId': widget.model.serviceShceduleClientID ?? 0,
            'userid': (await Preferences().getPrefInt(Preferences.prefUserID)),
            'ShiftComments': "${_controllerComments.text} ",
          });
          print(body);

          Response response = await http.post(
              Uri.parse("$masterURL$updateShiftComments"),
              headers: {"Content-Type": "application/json"},
              body: body);
          // response = await HttpService().init(request, _keyScaffold);
          log("Response $updateShiftCommentsAndSendRiskAlert : ${response.body}");
          if (response != null) {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
              showSnackBarWithText(_keyScaffold.currentState, "Success",
                  color: colorGreen);
              Navigator.pop(context, 0);
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          log("SignUp $e");
          removeOverlay();
          throw e;
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  getWorkerListForService() async {
    Map<String, dynamic> params = {
      'auth_code': (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userId': (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      "rosterId": widget.model.rosterID.toString(),
      "usertype": "3"
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endCareWorkersList, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          print(response);

          if (response != null && response.isNotEmpty) {
              List jResponse = json.decode(response);
              careWorkerList.clear();
              careWorkerList = jResponse.map((e) => CareWorker.fromJson(e)).toList();
              names = careWorkerList.map((obj) => "${obj.careWorkerName?? ""} : ${obj.timeFrom?? ""} - ${obj.timeTo?? ""}" ).toList();
              setState(() {});
            loadFundingServiceType();
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
          setState(() {});
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }
  Future<void> _showAllCareWorker(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CareWorkerDialog(careWorkerList: careWorkerList); // Pass the data here
      },
    );
  }

  Future<void> _showSingleSelectAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          title: const Text('Select Service'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  visualDensity: VisualDensity(horizontal: 0, vertical: 0),
                  tileColor:
                      options[index]! == selectedOption ? Colors.green : null,
                  title: Text(options[index]!),
                  onTap: () {
                    setState(() {
                      selectedOption = options[index]!;
                      selectedService = isClientFunding
                          ? fundingServiceList[index]
                          : serviceList[index];
                      _controllerServiceType.text =
                          selectedOption.isNotEmpty ? selectedOption : "test";
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

enum Calendar { day, week, fortnight }

class SingleChoice extends StatefulWidget {
  const SingleChoice(
      {super.key, required this.initialSelection, this.onChanged});

  final Calendar initialSelection;
  final ValueChanged<Calendar>? onChanged;

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
          value: Calendar.day,
          label: Text('Daily'),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.week,
          label: Text('Weekly'),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.fortnight,
          label: Text('Fortnightly'),
        ),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          calendarView = newSelection.first;
          if (widget.onChanged != null) {
            widget.onChanged!(calendarView);
          }
        });
      },
    );
  }
}

enum Day { mon, tue, wed, thu, fri, sat, sun }

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key});

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  Set<Day> selection = <Day>{
    Day.mon,
    Day.tue,
    Day.wed,
    Day.thu,
    Day.fri,
    Day.sat,
    Day.sun
  };

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Day>(
      segments: const <ButtonSegment<Day>>[
        ButtonSegment<Day>(value: Day.mon, label: Text('M')),
        ButtonSegment<Day>(value: Day.tue, label: Text('T')),
        ButtonSegment<Day>(value: Day.wed, label: Text('W')),
        ButtonSegment<Day>(
          value: Day.thu,
          label: Text('T'),
        ),
        ButtonSegment<Day>(value: Day.fri, label: Text('F')),
        ButtonSegment<Day>(
          value: Day.sat,
          label: Text('S'),
        ),
        ButtonSegment<Day>(value: Day.sun, label: Text('S')),
      ],
      selected: selection,
      showSelectedIcon: false,
      onSelectionChanged: (Set<Day> newSelection) {
        setState(() {
          selection = newSelection;
        });
      },
      multiSelectionEnabled: true,
    );
  }

  void selectAll() {
    setState(() {
      print("selectAll");
      selection = <Day>{
        Day.mon,
        Day.tue,
        Day.wed,
        Day.thu,
        Day.fri,
        Day.sat,
        Day.sun
      };
    });
  }

  void reset() {
    setState(() {
      print("reset");
      selection = <Day>{Day.mon};
    });
  }
}

String timeToDecimal(int minute) {
  double value = ((minute * 100) / 60) / 100;
  return value.toStringAsFixed(2);
}

String getTimeStringFromDouble(double value) {
  if (value < 0) return 'Invalid Value';
  int totalMin = (value * 60).round();
  int hour = (totalMin / 60).toInt();
  int min = totalMin % 60;
  String hourValue = getHourString(hour);
  String minuteString = getMinuteString(min);

  return '$hourValue:$minuteString';
}

String getMinuteString(int decimalValue) {
  return '$decimalValue'.padLeft(2, '0');
}

String getHourString(int flooredValue) {
  return '$flooredValue'.padLeft(2, '0');
}

enum ServiceFormOption { confirm, unconfirm, completed, add, funding }
