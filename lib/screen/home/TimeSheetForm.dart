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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: buildAppBar(context, title: "Time Sheet Detail"),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const SizedBox(height: spaceVertical * 5),
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
                Container(height: 20, width: 1, color: colorDivider),
                const SizedBox(width: 5),
                Container(height: 20, width: 1, color: colorDivider),
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
                Container(height: 20, width: 1, color: colorDivider),
                const SizedBox(width: 5),
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
              ],
            ),

            const SizedBox(height: spaceVertical / 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                const FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: colorGreen,
                  size: 14,
                ),
                const SizedBox(width: spaceHorizontal),
                ThemedText(
                  text: widget.model.resAddress ?? "",
                  color: colorBlack,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(width: 5),
                Container(height: 20, width: 1, color: colorDivider),
                const SizedBox(width: 5),
                Container(height: 20, width: 1, color: colorDivider),
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
    );
  }
}
