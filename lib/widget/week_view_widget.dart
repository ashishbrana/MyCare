import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../appconstant/API.dart';
import '../appconstant/ApiUrls.dart';
import '../calendar/week_view/week_view.dart';
import '../screen/home/CareWorkerList.dart';
import '../screen/home/ClientDocument.dart';
import '../screen/home/ClientInfo.dart';
import '../screen/home/DNSList.dart';
import '../screen/home/GroupNoteList.dart';
import '../screen/home/ProgressNoteListByNoteId.dart';
import '../screen/home/TimeSheetDetail.dart';
import '../screen/home/TimeSheetForm.dart';
import '../screen/home/models/ConfirmedResponseModel.dart';
import '../screen/home/HomeScreen.dart';
import '../screen/home/notes/NotesDetails.dart';
import '../utils/ColorConstants.dart';
import '../utils/ConstantStrings.dart';
import '../utils/Constants.dart';
import '../utils/GlobalMethods.dart';
import '../utils/Preferences.dart';
import '../utils/ThemedWidgets.dart';
import '../utils/WidgetMethods.dart';
import '../utils/methods.dart';


class WeekViewWidget extends StatelessWidget {
  final GlobalKey<WeekViewState>? state;
  final double? width;
  final DateTime? minDay;
  final DateTime? maxDay;
  final int bottomCurrentIndex;
  final Function(TimeShiteModel) onPressed;
  final Function() onConfirmOrPickup;

  const WeekViewWidget({super.key, this.state, this.width, this.maxDay , this.minDay, required this.bottomCurrentIndex,required this.onPressed, required this.onConfirmOrPickup});

  @override
  Widget build(BuildContext context) {
    return WeekView(
      key: state,
      width: width,
      minDay: minDay,
      maxDay: maxDay,

      onEventTap: (events, date) {
        final model = events.first.event as TimeShiteModel;
        DateTime? serviceDate = getDateTimeFromEpochTime(model.serviceDate!);
        showModalBottomSheet<void>(
          enableDrag: false,
          isDismissible: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: keyScaffold.currentContext!,
            builder: (context) => buildSheet(model, context, serviceDate)
        );

     /*   Navigator.of(keyScaffold.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => TimeSheetDetail(
              model: events.first.event as TimeShiteModel,
              indexSelectedFrom: 1,
            ),
          ),
        );*/
      },
    );
  }

  Widget buildRowIconAndText(IconData icon, String text) {
    return Row(
      children: [
        SizedBox(
          width: 25,
          height: 25,
          child: Center(
            child: FaIcon(
              icon,
              color: colorGreen,
            ),
          ),
        ),
        const SizedBox(
          width: spaceHorizontal,
        ),
        Expanded(
          child: ThemedText(
            text: text,
          ),
        ),
      ],
    );
  }


  Widget makeDismissible({required Widget child}) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => Navigator.of(keyScaffold.currentContext!).pop(),
    child: GestureDetector(onTap: () {},child: child)
  );

  Widget buildSheet(TimeShiteModel model, BuildContext context, DateTime? serviceDate) => makeDismissible(child:
      DraggableScrollableSheet(
    initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.7,
      builder: (_, conroller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 20),
        child: ListView(
          controller: conroller,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: model
                                        .isGroupService
                                        ? "${model.groupName} - "
                                        : "${model.resName} - ",
                                    style:
                                    const TextStyle(
                                      fontSize: 15,
                                      color: Colors
                                          .blueAccent,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: model
                                        .serviceName,
                                    style:
                                    const TextStyle(
                                      fontSize: 14,
                                      color: Colors
                                          .blueAccent,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (bottomCurrentIndex != 3 &&
                              model.noteID != 0)
                            InkWell(
                              onTap: () {
                                showProgressNotes(model);
                              },
                              child: const FaIcon(
                                FontAwesomeIcons
                                    .calendarDays,
                                size: 22,
                              ),
                            ),
                          const SizedBox(
                              width:
                              spaceHorizontal / 2),
                          if (bottomCurrentIndex != 3)
                            InkWell(
                              onTap: () {
                                showCareWrokerList(
                                    model);
                                /*    lastSelectedRow = index;
                                      setState(() {});
                                     */
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.person_crop_circle,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: colorGreen,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 10,
                                        minHeight: 10,
                                      ),
                                      child: Center(
                                        child: Text(
                                          model.CWNumber.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context)
                            .size
                            .width,
                        height: 1,
                        color: colorGreyBorderD3,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              /*setState(() {
                                      updateSelection(index);
                                    });*/
                            },
                            child: const SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons
                                    .arrow_downward_rounded,
                                color: colorGreen,
                              ),
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Row(
                                      mainAxisSize:
                                      MainAxisSize
                                          .min,
                                      children: [
                                        const SizedBox(
                                            width: 5),
                                        const FaIcon(
                                          FontAwesomeIcons
                                              .calendarDays,
                                          color:
                                          colorGreen,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                            width: 5),
                                        if (getDateTimeFromEpochTime(
                                            model
                                                .serviceDate!) !=
                                            null)
                                          Text(
                                            formatServiceDate(
                                                model
                                                    .serviceDate),
                                            style:
                                            const TextStyle(
                                              color:
                                              colorGreyText,
                                              fontSize:
                                              14,
                                            ),
                                          ),
                                        const SizedBox(
                                            width: 5),
                                        Container(
                                          width: 1,
                                          height: 25,
                                          color:
                                          colorGreyBorderD3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Row(
                                      mainAxisSize:
                                      MainAxisSize
                                          .min,
                                      children: [
                                        const SizedBox(
                                            width: 5),
                                        const Icon(
                                          Icons
                                              .timelapse,
                                          color:
                                          colorGreen,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                            width: 5),
                                        Text(
                                          "${model.totalHours}hrs",
                                          style:
                                          const TextStyle(
                                            color:
                                            colorGreyText,
                                            fontSize:
                                            14,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 5),
                                        Container(
                                          width: 1,
                                          height: 25,
                                          color:
                                          colorGreyBorderD3,
                                        ),
                                        const SizedBox(
                                            width: 5),
                                      ],
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                            width: 5),
                                        const Icon(
                                          Icons
                                              .access_time_outlined,
                                          color:
                                          colorGreen,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                            width: 5),
                                        Text(
                                          model.shift ??
                                              "",
                                          style:
                                          const TextStyle(
                                            color:
                                            colorGreyText,
                                            fontSize:
                                            14,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 5),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          if ((bottomCurrentIndex == 0 ||
                              bottomCurrentIndex ==
                                  2) &&
                              model.tSConfirm ==
                                  false &&
                              serviceDate != null &&
                              serviceDate.isToday)
                            InkWell(
                              onTap: model.locationName !=
                                  null &&
                                  model
                                      .locationName!
                                      .isNotEmpty
                                  ? null
                                  : () {
                                showDialog(
                                  context:
                                  context,
                                  builder:
                                      (context) =>
                                      Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            boxBorderRadius),
                                        child:
                                        Padding(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal:
                                              spaceHorizontal,
                                              vertical:
                                              spaceVertical),
                                          child:
                                          Column(
                                            mainAxisSize:
                                            MainAxisSize
                                                .min,
                                            children: [
                                              Row(
                                                children: [
                                                  ThemedText(
                                                    text: "Shift Logon",
                                                    color: colorBlack,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height:
                                                  spaceVertical),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ThemedText(
                                                      text: "Logon to shift?",
                                                      color: colorBlack,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height:
                                                  spaceVertical),
                                              const SizedBox(
                                                  height:
                                                  spaceVertical),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ThemedButton(
                                                      onTap: () {
                                                        Navigator.pop(context);

                                                      },
                                                      title: "Cancel",
                                                      fontSize: 18,
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: spaceHorizontal / 2,
                                                  ),
                                                  Expanded(
                                                    child: ThemedButton(
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        onPressed(model);
                                                      /*  String? address = await getAddress();
                                                              if (address != null) {
                                                                print("ADDRESS : $address");
                                                                saveLocationTime(address, (model.servicescheduleemployeeID ?? 0).toString());
                                                              }*/


                                                      },
                                                      title: "Ok",
                                                      fontSize: 18,
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                );
                              },
                              child: FaIcon(
                                Icons.history,
                                color: model.locationName !=
                                    null &&
                                    model
                                        .locationName!
                                        .isNotEmpty
                                    ? colorGreen
                                    : colorRed,
                                size: 22,
                              ),
                            ),
                          if ((bottomCurrentIndex ==
                              0 ||
                              bottomCurrentIndex ==
                                  2) &&
                              serviceDate != null &&
                              serviceDate.isToday)
                            const SizedBox(
                                width: spaceHorizontal /
                                    2),
                          if ((bottomCurrentIndex ==
                              0 ||
                              bottomCurrentIndex ==
                                  2) &&
                              (model.isGroupService ||
                                  model.noteID != 0))
                            model.isGroupService
                                ? InkWell(
                              onTap: () {
                                showGroupList(
                                    model);
                              },
                              child: model.noteID ==
                                  0
                                  ? const FaIcon(
                                FontAwesomeIcons
                                    .userGroup,
                                size: 18,
                              )
                                  : const FaIcon(
                                // FontAwesomeIcons.notesMedical,
                                Icons
                                    .note_alt_outlined,
                                color: Colors.green,
                                size: 22,
                              ),
                            )
                                : InkWell(
                              onTap: () {
                                print(
                                    "progressnote 1");

                                if (!model
                                    .isGroupService) {
                                  Navigator.push(
                                    keyScaffold
                                        .currentContext!,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                          ProgressNoteDetails(
                                            userId:
                                            model.empID ??
                                                0,
                                            noteId:
                                            model.noteID ??
                                                0,
                                            clientId:
                                            model.rESID ??
                                                0,
                                            servicescheduleemployeeID:
                                            model.servicescheduleemployeeID ??
                                                0,
                                            serviceShceduleClientID:
                                            model.serviceShceduleClientID ??
                                                0,
                                            serviceName:
                                            model.serviceName ??
                                                "",
                                            clientName:
                                            "${model.resName} - ${model.rESID.toString().padLeft(5, "0")}",
                                            noteWriter:
                                            "",
                                            serviceDate: getDateTimeFromEpochTime(model.serviceDate ??
                                                "") ??
                                                DateTime
                                                    .now(),
                                          ),
                                    ),
                                  );
                                } else {
                                  /* selectedModel =
                                            model;

                                        showGroupList(
                                            model);*/
                                }
                              },
                              child: const FaIcon(
                                // FontAwesomeIcons.notesMedical,
                                Icons
                                    .note_alt_outlined,
                                color:
                                Colors.green,
                                size: 22,
                              ),
                            ),
                          const SizedBox(
                              width:
                              spaceHorizontal / 2),
                          if (model.dsnId != 0 &&
                              bottomCurrentIndex != 3)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DNSList(
                                        userId: model.empID ?? 0,
                                        rosterID: model.serviceShceduleClientID ?? 0),
                                  ),
                                );
                              },
                              child: FaIcon(
                                FontAwesomeIcons
                                    .lifeRing,
                                size: 22,
                                color: (model.isDNSComplete == true ) ? Colors.green : Colors.red,
                              ),
                            ),
                          if (model.dsnId != 0)
                            const SizedBox(
                                width: spaceHorizontal /
                                    2),
                          if (bottomCurrentIndex == 2 &&
                              model.tSConfirm == true)
                            Icon(
                              Icons
                                  .check_circle_rounded,
                              color: model.locationName ==
                                  "" ||
                                  model.logOffLocationName ==
                                      ""
                                  ? colorRed
                                  : colorGreen,
                              size: 22,
                            ),
                          if (bottomCurrentIndex == 2)
                            const SizedBox(
                                width: spaceHorizontal /
                                    2),
                          Container(
                            width: 1,
                            height: 30,
                            color: colorGreyBorderD3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    /* setState(() {
                            lastSelectedRow = index;
                          });
                          selectedModel = model;*/
                    Navigator.push(
                      keyScaffold.currentContext!,
                      MaterialPageRoute(
                        builder: (context) => model
                            .tSConfirm ==
                            false
                            ? TimeSheetDetail(
                          model: model,
                          indexSelectedFrom:
                          bottomCurrentIndex,
                        )
                            : TimeSheetForm(
                            model: model,
                            indexSelectedFrom:
                            bottomCurrentIndex),
                      ),
                    ).then((value) {
                      if (value != null) {
                        if (value == 0) {
                          /*  getData();
                                getAvailableShiftsData();
                                getDataProgressNotes();*/
                          onConfirmOrPickup();
                          Navigator.pop(context, 0);
                        } else if (value == 1) {
                          showGroupList(model);
                        }
                      }
                    });
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
            Row(
              children: [
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 7),
                      buildTextRowWithAlphaIcon(
                          "S",
                          model.shiftComments !=
                              null &&
                              model.shiftComments!
                                  .isNotEmpty
                              ? model.shiftComments!
                              : "No shift comments provided."),
                      const SizedBox(height: 7),
                      buildTextRowWithAlphaIcon(
                          "C",
                          model.comments != null &&
                              model.comments!
                                  .isNotEmpty
                              ? model.comments!
                              : "No client comments provided."),
                      const SizedBox(height: 7),
                      InkWell(
                          onTap: () {
                            launchUrlMethod(
                                "http://maps.google.com/?q=${model.resAddress}");
                          },
                          child: buildRowIconAndText(
                              FontAwesomeIcons
                                  .locationDot,
                              model.resAddress ??
                                  "")),
                      const SizedBox(height: 7),
                      InkWell(
                          onTap: () {
                            launchUrlMethod(
                                "tel:${model.resHomePhone}");
                          },
                          child: buildRowIconAndText(
                              FontAwesomeIcons
                                  .phoneVolume,
                              model.resHomePhone ??
                                  "")),
                      const SizedBox(height: 7),
                      InkWell(
                          onTap: () {
                            launchUrlMethod(
                                "tel:${model.resMobilePhone}");
                          },
                          child: buildRowIconAndText(
                              FontAwesomeIcons
                                  .mobileAlt,
                              model.resMobilePhone ??
                                  "")),
                      const SizedBox(height: 7),
                      InkWell(
                          onTap: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientDocument(
                                    id: (model.clientID ?? 0).toString(),
                                    resId: (model.rESID ?? 0).toString(),
                                    clientName: model.resName ?? "",
                                  ),
                                ),
                              );
                          },
                          child: buildRowIconAndText(
                              FontAwesomeIcons
                                  .fileLines,
                              "View Client Documents")),
                      const SizedBox(height: 7),
                      InkWell(
                          onTap: () {
                            print(
                                "model.clientID : ${model.rESID}");
                            Navigator.of(keyScaffold
                                .currentContext!)
                                .push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClientInfo(
                                        clientId:
                                        (model.rESID ?? 0)
                                            .toString(),
                                      ),
                                ));
                          },
                          child: buildRowIconAndText(
                              FontAwesomeIcons
                                  .circleInfo,
                              "View Client Info")),
                      const SizedBox(height: 7),


                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      )));

  showGroupList(TimeShiteModel model) {
    Navigator.push(
      keyScaffold
          .currentContext!,
      MaterialPageRoute(
          builder: (context) => GroupNoteList(selectedModel: model)),
    );
  }

  showDNSList(TimeShiteModel model) {
    Navigator.push(
      keyScaffold
          .currentContext!,
      MaterialPageRoute(
        builder: (context) => DNSList(
            userId: model.empID ?? 0,
            rosterID: model.serviceShceduleClientID ?? 0),
      ),
    );
  }

  showProgressNotes(TimeShiteModel model) {
    Navigator.push(
      keyScaffold
          .currentContext!,
      MaterialPageRoute(
        builder: (context) => ProgressNoteListByNoteId(
          userId: model.empID ?? 0,
          noteID: model.noteID ?? 0,
          rosterID: model.rosterID ?? 0,
        ),
      ),
    );
  }

  showClientDocument(TimeShiteModel model) {
    Navigator.push(
      keyScaffold
          .currentContext!,
      MaterialPageRoute(
        builder: (context) => ClientDocument(
          id: (model.clientID ?? 0).toString(),
          resId: (model.rESID ?? 0).toString(),
          clientName: model.resName ?? "",
        ),
      ),
    );
  }

  showCareWrokerList(TimeShiteModel model) {
    Navigator.push(
      keyScaffold
          .currentContext!,
      MaterialPageRoute(
        builder: (context) => CareWorkerList(
          userId: model.empID ?? 0,
          rosterID: model.rosterID ?? 0,
          model: model,
        ),
      ),
    );
  }

  /*Future<String?> getAddress() async {
    try {
      getOverlay(context);
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnackBarWithText(
            keyScaffold.currentState, "Please Enable the Location!");
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnackBarWithText(
              keyScaffold.currentState, "We need Location Permission!");
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnackBarWithText(
            keyScaffold.currentState, "We need Location Permission!");
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> addressList =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark placeMark = addressList[0];
      String address = "";
      void appendIfNotEmpty(String value) {
        if (value.trim().isNotEmpty) {
          address += "$value, ";
        }
      }

      appendIfNotEmpty(placeMark.name ?? "");
      appendIfNotEmpty(placeMark.subLocality ?? "");
      appendIfNotEmpty(placeMark.locality ?? "");
      appendIfNotEmpty(placeMark.administrativeArea ?? "");
      appendIfNotEmpty(placeMark.postalCode ?? "");
      appendIfNotEmpty(placeMark.country ?? "");

      address = address.trim();
      if (address.isNotEmpty) {
        address = address.substring(0, address.length - 1);
      }
      return address;
    } catch (e) {
      showSnackBarWithText(keyScaffold.currentState, stringSomeThingWentWrong);
      print(e);
    } finally {
      removeOverlay();
      // setState(() {});
    }
    // return null;
  }

  saveLocationTime(String address, String sSEID) async {
    var userName = await Preferences().getPrefString(Preferences.prefUserFullName);
    Map<String, dynamic> params = {
      'auth_code':
      (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
      (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'servicescheduleemployeeID': sSEID,
      'Location': address,
      'SaveTimesheet': "false",
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endSaveLocationTime, params: params).toString(),
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
            if (json.decode(response)["status"] == 1) {
              showSnackBarWithText(keyScaffold.currentState, "Success",
                  color: colorGreen);
              getData();
              getAvailableShiftsData();
              getDataProgressNotes();
              // Navigator.pop(context);
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("saveLocationTime ERROR : $e");
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
        }
      } else {
        showSnackBarWithText(keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }*/

}

