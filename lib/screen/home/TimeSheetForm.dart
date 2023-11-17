import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import 'models/ConfirmedResponseModel.dart';

class TimeSheetForm extends StatefulWidget {
  final TimeShiteResponseModel model;

  const TimeSheetForm({super.key, required this.model});

  @override
  State<TimeSheetForm> createState() => _TimeSheetFormState();
}

class _TimeSheetFormState extends State<TimeSheetForm> {
  final TextEditingController _serviceType = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _serviceType.text = widget.model.serviceName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Timesheet Form"),
      body: SingleChildScrollView(
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
                                  Duration(hours: 5, minutes: 30),
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
                          height: 20, width: dividerWidth, color: colorDivider),
                      const SizedBox(width: 5),
                      Container(
                          height: 20, width: dividerWidth, color: colorDivider),
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
                          height: 20, width: dividerWidth, color: colorDivider),
                      const SizedBox(width: 5),
                      const SizedBox(width: spaceHorizontal),
                      ThemedText(
                        text: "Lunch Break : ${widget.model.lunchBreak ?? ""}",
                        color: colorBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(width: 5),
                      Container(
                          height: 20, width: dividerWidth, color: colorDivider),
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
                  const SizedBox(height: spaceVertical / 2),
                  const SizedBox(height: spaceVertical / 1.5),
                  SizedBox(
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
                ],
              ),
            ),
            Container(
              color: colorBlueLite,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedText(
                      text: "Service Type",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: textFiledHeight,
                      child: ThemedTextField(
                        padding:
                            EdgeInsets.symmetric(horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: colorWhite,
                        isReadOnly: true,
                        controller: _serviceType,
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
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
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
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
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
                                text: "TS Lunch Break*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
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
                                text: "TS Lunch From*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
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
                                text: "TS Lunch To*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
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
                                text: "Hours(hh:mm)*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "Hours Diff.*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
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
                                text: "Hours(hh:mm)*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "Hours Diff.*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  controller: _serviceType,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
