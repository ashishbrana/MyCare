import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/HomeScreen.dart';
import 'package:rcare_2/screen/home/TimeSheetForm.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../Network/API.dart';
import '../../network/ApiUrls.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Preferences.dart';
import '../../utils/methods.dart';
import 'models/ConfirmedResponseModel.dart';
import 'notes/NotesDetails.dart';

class TimeSheetDetail extends StatefulWidget {
  final TimeShiteResponseModel model;
  final int indexSelectedFrom;

  const TimeSheetDetail(
      {super.key, required this.model, required this.indexSelectedFrom});

  @override
  State<TimeSheetDetail> createState() => _TimeSheetDetailState();
}

class _TimeSheetDetailState extends State<TimeSheetDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "TimeSheet Detail"),
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
                if (getDateTimeFromEpochTime(widget.model.serviceDate!) != null)
                  Text(
                    // model.serviceDate!,
                    widget.model.serviceDate != null
                        ? DateFormat("EEE,dd-MM-yyyy").format(
                            getDateTimeFromEpochTime(
                                widget.model.serviceDate!)!)
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
              ],
            ),
            const SizedBox(height: spaceVertical / 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(width: 5),
                Container(height: 20, width: 1, color: colorDivider),
                const SizedBox(width: 5),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                const FaIcon(
                  FontAwesomeIcons.mobileAlt,
                  color: colorGreen,
                  size: 14,
                ),
                const SizedBox(width: spaceHorizontal),
                ThemedText(
                  text: widget.model.resHomePhone ?? "",
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                const FaIcon(
                  FontAwesomeIcons.phoneVolume,
                  color: colorGreen,
                  size: 14,
                ),
                const SizedBox(width: spaceHorizontal),
                ThemedText(
                  text: widget.model.resMobilePhone ?? "",
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
            const SizedBox(height: spaceVertical),
            Container(
                height: 1,
                width: MediaQuery.of(context).size.width * .9,
                color: colorDivider),
            const SizedBox(height: spaceVertical),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * .85,
              child: ThemedButton(
                title: (widget.indexSelectedFrom == 0 ||
                        widget.indexSelectedFrom == 2)
                    ? getDateTimeFromEpochTime(
                                    widget.model.serviceDate ?? "") !=
                                null &&
                            getDateTimeFromEpochTime(
                                    widget.model.serviceDate ?? "")!
                                .isAfter(DateTime.now())
                        ? "Time Sheet can not be completed for Future Dates"
                        : "Complete TimeSheet"
                    : widget.indexSelectedFrom == 3
                        ? "PickUp"
                        : "Confirm",
                padding: EdgeInsets.zero,
                fontSize: 16,
                onTap: () {
                  if (widget.indexSelectedFrom == 0 ||
                      widget.indexSelectedFrom == 2) {
                    if (getDateTimeFromEpochTime(
                                widget.model.serviceDate ?? "") !=
                            null &&
                        getDateTimeFromEpochTime(
                                widget.model.serviceDate ?? "")!
                            .isBefore(DateTime.now())) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TimeSheetForm(model: widget.model),
                        ),
                      ).then((value) => value != null && value ? Navigator.pop(context, true) : () {});
                    }
                  } else {
                    showConfirmationDialog(
                      onYesTap: () {
                        if (widget.indexSelectedFrom == 1) {
                          confirmApiCall();
                        } else if (widget.indexSelectedFrom == 3) {
                          pickUpApiCall();
                        }
                      },
                      onNoTap: () {
                        Navigator.pop(context);
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: spaceVertical / 1.5),
            if ((widget.indexSelectedFrom == 0 ||
                    widget.indexSelectedFrom == 2) &&
                getDateTimeFromEpochTime(widget.model.serviceDate ?? "") !=
                    null &&
                getDateTimeFromEpochTime(widget.model.serviceDate ?? "")!
                    .isBefore(DateTime.now()))
              if (widget.indexSelectedFrom != 3 &&
                  widget.indexSelectedFrom != 1)
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * .85,
                  child: ThemedButton(
                    title: "Notes",
                    padding: EdgeInsets.zero,
                    fontSize: 16,
                    onTap: () {
                      if (keyScaffold.currentContext != null) {
                        Navigator.push(
                            keyScaffold.currentContext!,
                            MaterialPageRoute(
                              builder: (context) => ProgressNoteDetails(
                                userId: widget.model.empID ?? 0,
                                noteId: widget.model.noteID ?? 0,
                                clientId: widget.model.rESID ?? 0,
                                servicescheduleemployeeID:
                                    widget.model.servicescheduleemployeeID ?? 0,
                                serviceShceduleClientID:
                                    widget.model.serviceShceduleClientID ?? 0,
                                serviceName: widget.model.serviceName ?? "",
                                clientName:
                                    "${widget.model.resName} - ${widget.model.rESID.toString().padLeft(5, "0")}",
                              ),
                            )).then((value) => value != null &&
                                value
                            ? Navigator.pop(context, true)
                            : () {});
                      }
                    },
                  ),
                ),
            if ((widget.indexSelectedFrom == 0 ||
                    widget.indexSelectedFrom == 2) &&
                getDateTimeFromEpochTime(widget.model.serviceDate ?? "") !=
                    null &&
                getDateTimeFromEpochTime(widget.model.serviceDate ?? "")!
                    .isBefore(DateTime.now()))
              if (widget.indexSelectedFrom != 3 &&
                  widget.indexSelectedFrom != 1)
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

  showConfirmationDialog(
      {required void Function() onYesTap, required void Function() onNoTap}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: boxBorderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: spaceVertical),
            ThemedText(text: "Are you sure ?"),
            const SizedBox(height: spaceVertical),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  const SizedBox(width: spaceHorizontal * 2),
                  Expanded(
                    child: ThemedButton(
                      title: "Yes",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      padding: EdgeInsets.zero,
                      onTap: onYesTap,
                    ),
                  ),
                  const SizedBox(width: spaceHorizontal),
                  Expanded(
                    child: ThemedButton(
                      title: "No",
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

  confirmApiCall() async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': (widget.model.empID ?? 0).toString(),
      'rosterid': (widget.model.rosterID ?? 0).toString(),
      'ssEmployeeID': (widget.model.servicescheduleemployeeID ?? 0).toString(),
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endConfirmShift, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            print(response);
            var jsonResponse = json.decode(response);
            if (jsonResponse["status"] == 1) {
              Navigator.pop(context);
              Navigator.pop(context, true);
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
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

  pickUpApiCall() async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid': (widget.model.empID ?? 0).toString(),
      'rosterid': (widget.model.rosterID ?? 0).toString(),
      'totalhours': (widget.model.totalHours ?? 0).toString(),
      'serviceDate': DateFormat("EEE MMM dd yyyy ").format(
          DateTime.fromMillisecondsSinceEpoch(
                  int.parse(widget.model.serviceDate!
                      .replaceAll("/Date(", "")
                      .replaceAll(")/", "")),
                  isUtc: false)
              .add(
        const Duration(hours: 5, minutes: 30),
      ))
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endPickupShift, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            print(response);

            var jsonResponse = json.decode(response);
            if (jsonResponse["status"] == 1) {
              showSnackBarWithText(keyScaffold.currentState, "Success",
                  color: colorGreen);
              Navigator.pop(context);
              Navigator.pop(context, true);
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
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
}
