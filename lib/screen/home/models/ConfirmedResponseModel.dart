import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rcare_2/utils/ColorConstants.dart';

import '../../../utils/methods.dart';

class TimeShiteModel {
  int? rosterID;
  int? clientID;
  int? rESID;
  String? resName;
  int? empID;
  String? emplName;
  String? resHomePhone;
  String? resMobilePhone;
  String? resAddress;
  String? shift;
  String? serviceDate;
  String? weekday;
  String? timeFrom;
  String? timeUntil;
  bool? lunchBreakSetting;
  String? lunchBreak;
  var lunchBreakFrom;
  var lunchBreakTo;
  num? totalHours;
  int? comID;
  String? brokerageNo;
  String? comments;
  String? shiftTask;
  String? shiftComments;
  dynamic? clientPayRate;
  dynamic? clientPay;
  dynamic? callOut;
  num? clientTotalPay;
  String? tSFrom;
  String? tSUntil;
  bool? tSLunchBreakSetting;
  String? tSLunchBreak;
  String? tSLunchBreakFrom;
  String? tSLunchBreakTo;
  num? tSHours;
  String? tSTravelTime;
  num? tSTravelDistance;
  num? tSTravelH;
  String? tSComments;
  num? tSHoursDiff;
  int? tSTravelDistanceDiff;
  bool? confirmCW;
  bool? tSConfirm;
  bool? cancel;
  int? status1;
  bool? completeCW;
  bool? timesheetStatus;
  String? serviceName;
  String? careNotes;
  String? startTime;
  String? endTime;
  int? timesheetID;
  num? serviceTavelDistance;
  int? serviceShceduleClientID;
  int? noteID;
  int? type;
  int? servicescheduleemployeeID;
  String? locationName;
  String? logOffLocationName;
  num? maxTravelDistance;
  num? clienttraveldistance;
  String? fundingsourcename;
  int? tsservicetype;
  int? dsnId;
  String? calculatedDost;
  String? expenseTotal;
  String? totalAmountwithGST;
  int? serviceScheduleType;
  String? groupName;
  int? CWNumber;
  bool? isDNSComplete;

  TimeShiteModel(
      {this.rosterID,
      this.clientID,
      this.rESID,
      this.resName,
      this.empID,
      this.emplName,
      this.resHomePhone,
      this.resMobilePhone,
      this.resAddress,
      this.shift,
      this.serviceDate,
      this.weekday,
      this.timeFrom,
      this.timeUntil,
      this.lunchBreakSetting,
      this.lunchBreak,
      this.lunchBreakFrom,
      this.lunchBreakTo,
      this.totalHours,
      this.comID,
      this.brokerageNo,
      this.comments,
      this.shiftTask,
      this.shiftComments,
      this.clientPayRate,
      this.clientPay,
      this.callOut,
      this.clientTotalPay,
      this.tSFrom,
      this.tSUntil,
      this.tSLunchBreakSetting,
      this.tSLunchBreak,
      this.tSLunchBreakFrom,
      this.tSLunchBreakTo,
      this.tSHours,
      this.tSTravelTime,
      this.tSTravelDistance,
      this.tSTravelH,
      this.tSComments,
      this.tSHoursDiff,
      this.tSTravelDistanceDiff,
      this.confirmCW,
      this.tSConfirm,
      this.cancel,
      this.status1,
      this.completeCW,
      this.timesheetStatus,
      this.serviceName,
      this.careNotes,
      this.startTime,
      this.endTime,
      this.timesheetID,
      this.serviceTavelDistance,
      this.serviceShceduleClientID,
      this.noteID,
      this.type,
      this.servicescheduleemployeeID,
      this.locationName,
      this.logOffLocationName,
      this.maxTravelDistance,
      this.clienttraveldistance,
      this.fundingsourcename,
      this.tsservicetype,
      this.dsnId,
        this.calculatedDost,
        this.expenseTotal,
        this.totalAmountwithGST,
        this.serviceScheduleType,
        this.groupName,
        this.CWNumber,
        this.isDNSComplete
      });

  TimeShiteModel.fromJson(Map<String, dynamic> json) {
    rosterID = json['RosterID'];
    clientID = json['ClientID'];
    rESID = json['RESID'];
    resName = json['ResName'];
    empID = json['EmpID'];
    emplName = json['EmplName'];
    resHomePhone = json['ResHomePhone'];
    resMobilePhone = json['ResMobilePhone'];
    resAddress = json['ResAddress'];
    shift = json['Shift'];
    serviceDate = json['ServiceDate'];
    weekday = json['Weekday'];
    timeFrom = json['TimeFrom'];
    timeUntil = json['TimeUntil'];
    lunchBreakSetting = json['LunchBreakSetting'];
    lunchBreak = json['LunchBreak'];
    lunchBreakFrom = json['LunchBreakFrom'];
    lunchBreakTo = json['LunchBreakTo'];
    totalHours = json['TotalHours'];
    comID = json['ComID'];
    brokerageNo = json['BrokerageNo'];
    comments = json['Comments'];
    shiftTask = json['ShiftTask'];
    shiftComments = json['ShiftComments'];
    clientPayRate = json['ClientPayRate'];
    clientPay = json['ClientPay'];
    callOut = json['CallOut'];
    clientTotalPay = json['ClientTotalPay'];
    tSFrom = json['TSFrom'];
    tSUntil = json['TSUntil'];
    tSLunchBreakSetting = json['TSLunchBreakSetting'];
    tSLunchBreak = json['TSLunchBreak'];
    tSLunchBreakFrom = json['TSLunchBreakFrom'];
    tSLunchBreakTo = json['TSLunchBreakTo'];
    tSHours = json['TSHours'];
    tSTravelTime = json['TSTravelTime'];
    tSTravelDistance = json['TSTravelDistance'];
    tSTravelH = json['TSTravelH'];
    tSComments = json['TSComments'];
    tSHoursDiff = json['TSHoursDiff'];
    tSTravelDistanceDiff = json['TSTravelDistanceDiff'];
    confirmCW = json['ConfirmCW'];
    tSConfirm = json['TSConfirm'];
    cancel = json['Cancel'];
    status1 = json['status1'];
    completeCW = json['CompleteCW'];
    timesheetStatus = json['TimesheetStatus'];
    serviceName = json['serviceName'];
    careNotes = json['careNotes'];
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    timesheetID = json['TimesheetID'];
    serviceTavelDistance = json['ServiceTavelDistance'];
    serviceShceduleClientID = json['serviceShceduleClientID'];
    noteID = json['NoteID'];
    type = json['type'];
    servicescheduleemployeeID = json['servicescheduleemployeeID'];
    locationName = json['LocationName'];
    logOffLocationName = json['LogOffLocationName'];
    maxTravelDistance = json['MaxTravelDistance'];
    clienttraveldistance = json['clienttraveldistance'];
    fundingsourcename = json['fundingsourcename'];
    tsservicetype = json['tsservicetype'];
    dsnId = json['dsnId'];
    calculatedDost = json['Calculatedcost'];
    expenseTotal = json['Expensetotal'];
    totalAmountwithGST = json['TotalamountwithGST'];
    serviceScheduleType = json['serviceScheduleType'];
    groupName = json['groupName'];
    isDNSComplete = json['isDNSComplete'];
    CWNumber = json['CWNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RosterID'] = this.rosterID;
    data['ClientID'] = this.clientID;
    data['RESID'] = this.rESID;
    data['ResName'] = this.resName;
    data['EmpID'] = this.empID;
    data['EmplName'] = this.emplName;
    data['ResHomePhone'] = this.resHomePhone;
    data['ResMobilePhone'] = this.resMobilePhone;
    data['ResAddress'] = this.resAddress;
    data['Shift'] = this.shift;
    data['ServiceDate'] = this.serviceDate;
    data['Weekday'] = this.weekday;
    data['TimeFrom'] = this.timeFrom;
    data['TimeUntil'] = this.timeUntil;
    data['LunchBreakSetting'] = this.lunchBreakSetting;
    data['LunchBreak'] = this.lunchBreak;
    data['LunchBreakFrom'] = this.lunchBreakFrom;
    data['LunchBreakTo'] = this.lunchBreakTo;
    data['TotalHours'] = this.totalHours;
    data['ComID'] = this.comID;
    data['BrokerageNo'] = this.brokerageNo;
    data['Comments'] = this.comments;
    data['ShiftTask'] = this.shiftTask;
    data['ShiftComments'] = this.shiftComments;
    data['ClientPayRate'] = this.clientPayRate;
    data['ClientPay'] = this.clientPay;
    data['CallOut'] = this.callOut;
    data['ClientTotalPay'] = this.clientTotalPay;
    data['TSFrom'] = this.tSFrom;
    data['TSUntil'] = this.tSUntil;
    data['TSLunchBreakSetting'] = this.tSLunchBreakSetting;
    data['TSLunchBreak'] = this.tSLunchBreak;
    data['TSLunchBreakFrom'] = this.tSLunchBreakFrom;
    data['TSLunchBreakTo'] = this.tSLunchBreakTo;
    data['TSHours'] = this.tSHours;
    data['TSTravelTime'] = this.tSTravelTime;
    data['TSTravelDistance'] = this.tSTravelDistance;
    data['TSTravelH'] = this.tSTravelH;
    data['TSComments'] = this.tSComments;
    data['TSHoursDiff'] = this.tSHoursDiff;
    data['TSTravelDistanceDiff'] = this.tSTravelDistanceDiff;
    data['ConfirmCW'] = this.confirmCW;
    data['TSConfirm'] = this.tSConfirm;
    data['Cancel'] = this.cancel;
    data['status1'] = this.status1;
    data['CompleteCW'] = this.completeCW;
    data['TimesheetStatus'] = this.timesheetStatus;
    data['serviceName'] = this.serviceName;
    data['careNotes'] = this.careNotes;
    data['StartTime'] = this.startTime;
    data['EndTime'] = this.endTime;
    data['TimesheetID'] = this.timesheetID;
    data['ServiceTavelDistance'] = this.serviceTavelDistance;
    data['serviceShceduleClientID'] = this.serviceShceduleClientID;
    data['NoteID'] = this.noteID;
    data['type'] = this.type;
    data['servicescheduleemployeeID'] = this.servicescheduleemployeeID;
    data['LocationName'] = this.locationName;
    data['LogOffLocationName'] = this.logOffLocationName;
    data['MaxTravelDistance'] = this.maxTravelDistance;
    data['clienttraveldistance'] = this.clienttraveldistance;
    data['fundingsourcename'] = this.fundingsourcename;
    data['tsservicetype'] = this.tsservicetype;
    data['dsnId'] = this.dsnId;
    data['Calculatedcost'] = this.calculatedDost;
    data['Expensetotal'] = this.expenseTotal;
    data['TotalamountwithGST'] = this.totalAmountwithGST;
    data['serviceScheduleType'] = this.serviceScheduleType;
    data['groupName'] = this.groupName;
    data['isDNSComplete'] = this.isDNSComplete;
    data['CWNumber'] = this.CWNumber;

    return data;
  }

  Color getStatusColor(){

    if (this.confirmCW == true &&
        this.empID != 0 &&
        this.tSConfirm == false) {
      DateTime? serviceDate =
      getDateTimeFromEpochTime(this.serviceDate!);
      if (serviceDate!.isToday) {
        return Colors.red;
      }
      return colorGreen;
    } else if (this.empID != 0 && this.timesheetStatus == true) {
      return Color(0xb64d9950);;
    }
    else if ((this.status1 == 5 || this.confirmCW == false) && this.empID != 0) {
      return Colors.orange;
    }
    else if (this.empID == 0 && comID ==0) {
      return Colors.blue;
    }
    else{
      return Colors.green;
    }
  }

}

extension GroppServiceModel on TimeShiteModel{
  bool get isGroupService => serviceScheduleType == 2;
  bool allowAddGroupNote(){
    return (getDateTimeFromEpochTime(serviceDate!) !=
        null &&
        getDateTimeFromEpochTime(serviceDate!)!
            .isFutureDate ==
            false);
  }
}
