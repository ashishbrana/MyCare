import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../Network/API.dart';
import '../../network/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';
import 'models/ConfirmedResponseModel.dart';

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    final hour = this.hour.toString().padLeft(2, "0");
    final min = this.minute.toString().padLeft(2, "0");
    return "$hour:$min";
  }
}

class TimeSheetForm extends StatefulWidget {
  final TimeShiteResponseModel model;

  const TimeSheetForm({super.key, required this.model});

  @override
  State<TimeSheetForm> createState() => _TimeSheetFormState();
}

class _TimeSheetFormState extends State<TimeSheetForm> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  String fromHourService = "00";
  String fromMinuteService = "00";
  String toHourService = "00";
  String toMinuteService = "00";

  String hourLaunch = "00";
  String minuteLaunch = "00";
  String fromHourLaunch = "00";
  String fromMinuteLaunch = "00";
  String toHourLaunch = "00";
  String toMinuteLaunch = "00";

  final TextEditingController _controllerServiceType = TextEditingController();
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
  final TextEditingController _controllerTimeSheetComments =
      TextEditingController();

  bool isIncludeLaunchBrake = false;
  bool isRiskAlert = false;

  List<String> hourList = [
    "00",
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
  ];

  List<String> minuteList = [
    "00",
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
    "46",
    "47",
    "48",
    "49",
    "50",
    "51",
    "52",
    "53",
    "54",
    "55",
    "56",
    "57",
    "58",
    "59",
    "60",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controllerServiceType.text = widget.model.serviceName ?? "";
    if (widget.model.timeFrom != null &&
        widget.model.timeFrom!.split(":").isNotEmpty) {
      fromHourService = widget.model.timeFrom!.split(":")[0];
      if (widget.model.timeFrom!.split(":").length > 1) {
        fromMinuteService = widget.model.timeFrom!.split(":")[1];
      }
    }
    if (widget.model.timeUntil != null &&
        widget.model.timeUntil!.split(":").isNotEmpty) {
      toHourService = widget.model.timeUntil!.split(":")[0];
      if (widget.model.timeUntil!.split(":").length > 1) {
        toMinuteService = widget.model.timeUntil!.split(":")[1];
      }
    }
    isIncludeLaunchBrake = widget.model.lunchBreakSetting ?? false;
    if (widget.model.lunchBreak != null &&
        widget.model.lunchBreak!.split(":").isNotEmpty) {
      hourLaunch = widget.model.lunchBreak!.split(":")[0];
      if (widget.model.lunchBreak!.split(":").length > 1) {
        minuteLaunch = widget.model.lunchBreak!.split(":")[1];
      }
    }
    if (widget.model.lunchBreakFrom != null &&
        widget.model.lunchBreakFrom!.split(":").isNotEmpty) {
      fromHourLaunch = widget.model.lunchBreakFrom!.split(":")[0];
      if (widget.model.lunchBreakFrom!.split(":").length > 1) {
        fromMinuteLaunch = widget.model.lunchBreakFrom!.split(":")[1];
      }
    }
    if (widget.model.lunchBreakTo != null &&
        widget.model.lunchBreakTo!.split(":").isNotEmpty) {
      toHourLaunch = widget.model.lunchBreakTo!.split(":")[0];
      if (widget.model.lunchBreakTo!.split(":").length > 1) {
        toMinuteLaunch = widget.model.lunchBreakTo!.split(":")[1];
      }
    }
    _controllerHours.text = widget.model.tSHours.toString();
    _controllerHoursDifference.text = widget.model.tSHoursDiff.toString();
    _controllerTravelTime.text = widget.model.tSTravelTime.toString();
    _controllerTravelDistance.text = widget.model.tSTravelDistance.toString();
    _controllerTravelDistanceMax.text =
        widget.model.maxTravelDistance.toString();
    _controllerClientTravelDistance.text =
        widget.model.clienttraveldistance.toString();
    isRiskAlert = false;
    _controllerTimeSheetComments.text = widget.model.comments ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorLiteBlueBackGround,
      appBar: buildAppBar(context, title: "Timesheet Form"),
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
                    ThemedText(
                      text: widget.model.resName ?? "",
                      color: colorBlack,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: spaceVertical / 2),
                    ThemedText(
                      text: widget.model.serviceName ?? "",
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
                        const FaIcon(
                          FontAwesomeIcons.calendarDays,
                          color: colorGreen,
                          size: 14,
                        ),
                        const SizedBox(width: spaceHorizontal),
                        Text(
                          // model.serviceDate!,
                          widget.model.serviceDate != null
                              ? DateFormat("EEE,dd-MM-yyyy").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(widget.model.serviceDate!
                                              .replaceAll("/Date(", "")
                                              .replaceAll(")/", "")),
                                          isUtc: false)
                                      .add(
                                    const Duration(hours: 5, minutes: 30),
                                  ),
                                )
                              : "",
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
                        // Container(height: 20, width: 1, color: colorDivider),
                        // const SizedBox(width: 5),
                        // const Icon(
                        //   CupertinoIcons.time,
                        //   color: colorGreen,
                        //   size: 14,
                        // ),
                        // const SizedBox(width: 5),
                        // Text(
                        //   "${widget.model.totalHours}hrs",
                        //   style: const TextStyle(
                        //       color: colorBlack,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w500),
                        // ),
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
                              "Lunch Break : ${widget.model.lunchBreak ?? ""}",
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
                              "Travel Dist.: ${widget.model.tSTravelTime ?? ""}",
                          color: colorBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                    const SizedBox(height: spaceVertical),
                    Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width * .9,
                        color: colorDivider),
                    const SizedBox(height: spaceVertical),
                    /*  SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .85,
                      child: ThemedButton(
                        title: "Cancel",
                        padding: EdgeInsets.zero,
                        fontSize: 16,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: spaceVertical / 1.5),*/
                  ],
                ),
              ),
              const SizedBox(height: spaceVertical),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedText(
                      text: "Service Type",
                      fontSize: 14,
                      color: colorBlack,
                    ),
                    SizedBox(
                      height: textFiledHeight,
                      child: ThemedTextField(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: colorWhite,
                        isReadOnly: true,
                        controller: _controllerServiceType,
                      ),
                    ),
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
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size.fromHeight(40), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(fromHourService),
                                  onPressed: () async{
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (BuildContext? context, Widget? child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: false),
                                          child: child!,
                                        );
                                      },
                                    );


                                    if(pickedTime != null ){
                                      print("24h: ${pickedTime.to24hours()}");
                                      String timeOfDay = pickedTime.to24hours();

                                      setState(() {
                                        fromHourService = timeOfDay;
                                      });
                                    }else{
                                      print("Time is not selected");
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
                                child: ThemedDropDown(
                                  defaultValue: fromMinuteService,
                                  dataString: minuteList,
                                  onChanged: (value) {
                                    setState(() {
                                      fromMinuteService = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: spaceBetween),
                    Row(
                      children: [
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
                                child: ThemedDropDown(
                                  defaultValue: toHourService,
                                  dataString: hourList,
                                  onChanged: (value) {
                                    setState(() {
                                      toHourService = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            children: [
                              ThemedText(
                                text: "",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedDropDown(
                                  defaultValue: toMinuteService,
                                  dataString: minuteList,
                                  onChanged: (value) {
                                    setState(() {
                                      toMinuteService = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: spaceBetween),
                    ThemedText(
                      text: "TS Lunch Break*",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: spaceBetween),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isIncludeLaunchBrake,
                          activeColor: colorGreen,
                          onChanged: (bool? value) {
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
                          onChanged: (bool? value) {
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
                                      child: ThemedDropDown(
                                        defaultValue: hourLaunch,
                                        dataString: hourList,
                                        isDisabled: true,
                                        onChanged: (String) {},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: spaceHorizontal / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ThemedText(
                                      text: "",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedDropDown(
                                        defaultValue: minuteLaunch,
                                        dataString: minuteList,
                                        isDisabled: true,
                                        onChanged: (String) {},
                                      ),
                                    ),
                                  ],
                                ),
                              )
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
                                      child: ThemedDropDown(
                                        defaultValue: fromHourLaunch,
                                        dataString: hourList,
                                        onChanged: (value) {
                                          setState(() {
                                            fromHourLaunch = value;
                                            findDurationDifference();
                                          });
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
                                  children: [
                                    ThemedText(
                                      text: "",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedDropDown(
                                        defaultValue: fromMinuteLaunch,
                                        dataString: minuteList,
                                        onChanged: (value) {
                                          setState(() {
                                            fromMinuteLaunch = value;
                                            findDurationDifference();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
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
                                      child: ThemedDropDown(
                                        defaultValue: toHourLaunch,
                                        dataString: hourList,
                                        onChanged: (value) {
                                          setState(() {
                                            toHourLaunch = value;
                                            findDurationDifference();
                                          });
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
                                  children: [
                                    ThemedText(
                                      text: "",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedDropDown(
                                        defaultValue: toMinuteLaunch,
                                        dataString: minuteList,
                                        onChanged: (value) {
                                          setState(() {
                                            toMinuteLaunch = value;
                                            findDurationDifference();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: spaceBetween),
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
                                  text: "Hours(hh:mm)",
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  controller: _controllerHours,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: "Hours Diff.",
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  controller: _controllerHoursDifference,
                                ),
                              ),
                            ],
                          ),
                        )
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
                                  text: "Travel Time",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                                getTextSpan(
                                  text: "",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorRed,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  controller: _controllerTravelTime,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: "Travel Dist (km)",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                                getTextSpan(
                                  text: "",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorRed,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  controller: _controllerTravelDistance,
                                ),
                              ),
                            ],
                          ),
                        )
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
                                  text: "Max Travel Dist.",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                                getTextSpan(
                                  text: "",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorRed,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _controllerTravelDistanceMax,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ThemedRichText(spanList: [
                                getTextSpan(
                                  text: "Client Travel Dist.",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorBlack,
                                ),
                                getTextSpan(
                                  text: "",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontColor: colorRed,
                                ),
                              ]),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  controller: _controllerClientTravelDistance,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: spaceBetween),
                    Row(
                      children: [
                        ThemedRichText(spanList: [
                          getTextSpan(
                            text: "Risk Alert :",
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
                        Radio<bool>(
                          value: true,
                          groupValue: isRiskAlert,
                          activeColor: colorGreen,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                isRiskAlert = value;
                              });
                            }
                          },
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isRiskAlert = true;
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
                          groupValue: isRiskAlert,
                          activeColor: colorGreen,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                isRiskAlert = value;
                              });
                            }
                          },
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isRiskAlert = false;
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
                    ThemedRichText(spanList: [
                      getTextSpan(
                        text: "TimeSheet Comments",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontColor: colorBlack,
                      ),
                      if (isRiskAlert)
                        getTextSpan(
                          text: "*",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontColor: colorRed,
                        ),
                    ]),
                    const SizedBox(height: spaceBetween),
                    ThemedTextField(
                      padding: const EdgeInsets.symmetric(
                          horizontal: spaceHorizontal),
                      borderColor: colorGreyBorderD3,
                      backgroundColor: colorWhite,
                      maxLine: 5,
                      minLine: 5,
                      controller: _controllerTimeSheetComments,
                    ),
                    const SizedBox(height: spaceBetween),
                    const SizedBox(height: spaceBetween),
                    SizedBox(
                      height: 50,
                      child: ThemedButton(
                        title: "Save",
                        padding: EdgeInsets.zero,
                        onTap: () {
                          saveTimeSheet();
                        },
                      ),
                    ),
                    const SizedBox(height: spaceBetween),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  findDurationDifference() {
    Duration difference = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            int.parse(toHourLaunch),
            int.parse(toMinuteLaunch))
        .difference(DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            int.parse(fromHourLaunch),
            int.parse(fromMinuteLaunch)));
    int hour = difference.inHours;
    int minute = difference.inMinutes;

    setState(() {
      if (hour >= 0) {
        hourLaunch = hour < 10 ? "0${hour}" : hour.toString();
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
  }

  saveTimeSheet() async {
    if (widget.model != null) {
      Map<String, dynamic> params = <String, dynamic>{
        'auth_code':
            (await Preferences().getPrefString(Preferences.prefAuthCode)),
        'timesheetID':
            (await Preferences().getPrefString(Preferences.prefAuthCode)),
        'RosterID':
            (await Preferences().getPrefString(Preferences.prefAuthCode)),
        'TSFrom': "$fromHourService:$fromMinuteService",
        'TSUntil': "$toHourService:$toMinuteService",
        'TSLunchBreakSetting': isIncludeLaunchBrake.toString(),
        'TSLunchBreak': isIncludeLaunchBrake ? "$hourLaunch:$minuteLaunch" : "",
        'TSLBFrom':
            isIncludeLaunchBrake ? "$fromHourLaunch:$fromMinuteLaunch" : "",
        'TSLBTo': isIncludeLaunchBrake ? "$toHourLaunch:$toMinuteLaunch" : "",
        'TSHours': _controllerHours.text,
        'TSTravelDistance': _controllerTravelDistance.text,
        'TSComments': _controllerTimeSheetComments.text,
        'TSConfirm': widget.model.tSConfirm,
        'TSHoursDiff': _controllerHoursDifference.text,
        //---change
        'TSTravelDistanceDiff': "$fromHourService:$fromMinuteService",
        //---change
        'TSTravelTime': _controllerTravelTime.text,
        'tsHoursDifference': "$fromHourService:$fromMinuteService",
        //--change
        'empID': widget.model.empID,
        'RosterDate': "null",
        'RiskAlert': isRiskAlert.toString(),
        'clientID': widget.model.clientID,
        'TSClientTravelDistance': _controllerClientTravelDistance.text,
        'ssEmployeeID': widget.model.servicescheduleemployeeID,
        'servicetypeid': widget.model.tsservicetype,
        'fundingSourceName': widget.model.fundingsourcename,
      };

      print(params);
      isConnected().then((hasInternet) async {
        if (hasInternet) {
          var response;
          HttpRequestModel request = HttpRequestModel(
              url: getUrl(endSaveTimesheet, params: params).toString(),
              authMethod: '',
              body: '',
              headerType: '',
              params: "",
              method: 'GET');

          try {
            getOverlay(context);
            response = await HttpService().init(request, _keyScaffold);
            print("response $response");
            if (response != null && response != "") {
              var jResponse = json.decode(response.toString());
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, stringSomeThingWentWrong);
            }
            removeOverlay();
          } catch (e) {
            log("SignUp$e");
            removeOverlay();
            throw e;
          } finally {
            removeOverlay();
          }
        } else {
          showSnackBarWithText(
              _keyScaffold.currentState, stringErrorNoInterNet);
        }
      });
    }
  }
}
