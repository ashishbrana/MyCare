import '../../../utils/methods.dart';

class GroupServiceModel {
  int? servicescheduleCLientID;
  int? noteID;
  String? clientName;
  int? serviceScheduleID;
  String? startTime;
  String? endTime;
  String? serviceDate;
  double? totalhours;
  String? serviceType;
  String? notewriter;
  String? groupname;
  int? serviceScheduleEmpID;
  int? rESID;
  String? resHomePhone;
  String? resMobilePhone;
  String? resAddress;
  bool isCompleted = false;
  bool isSelected = false;
  String? description;
  String? assessmentcomments;
  int? serviceScheduleType;

  GroupServiceModel(
      {this.servicescheduleCLientID,
      this.noteID,
      this.clientName,
      this.serviceScheduleID,
      this.startTime,
      this.endTime,
      this.serviceDate,
      this.totalhours,
      this.serviceType,
      this.notewriter,
      this.groupname,
      this.serviceScheduleEmpID,
      this.rESID,
      this.resHomePhone,
      this.resMobilePhone,
      this.resAddress,
      this.description,
      this.assessmentcomments,
      this.serviceScheduleType
      });

  GroupServiceModel.fromJson(Map<String, dynamic> json) {
    servicescheduleCLientID = json['servicescheduleCLientID'];
    noteID = json['NoteID'];
    clientName = json['ClientName'];
    serviceScheduleID = json['ServiceScheduleID'];
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    serviceDate = json['ServiceDate'];
    totalhours =
        json['totalhours'] != null ? json['totalhours'].toDouble() : 0.0;
    serviceType = json['ServiceType'];
    notewriter = json['notewriter'];
    groupname = json['groupname'];
    serviceScheduleEmpID = json['ServiceScheduleEmpID'];
    rESID = json['RESID'];
    resHomePhone = json['ResHomePhone'];
    resMobilePhone = json['ResMobilePhone'];
    resAddress = json['ResAddress'];
    description = json['description'];
    assessmentcomments = json['assessmentcomments'];
    serviceScheduleType = json['serviceScheduleType'];
    isCompleted = (noteID != null && noteID != 0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['servicescheduleCLientID'] = this.servicescheduleCLientID;
    data['NoteID'] = this.noteID;
    data['ClientName'] = this.clientName;
    data['ServiceScheduleID'] = this.serviceScheduleID;
    data['StartTime'] = this.startTime;
    data['EndTime'] = this.endTime;
    data['ServiceDate'] = this.serviceDate;
    data['totalhours'] = this.totalhours;
    data['ServiceType'] = this.serviceType;
    data['notewriter'] = this.notewriter;
    data['groupname'] = this.groupname;
    data['ServiceScheduleEmpID'] = this.serviceScheduleEmpID;
    data['RESID'] = this.rESID;
    data['ResHomePhone'] = this.resHomePhone;
    data['ResMobilePhone'] = this.resMobilePhone;
    data['ResAddress'] = this.resAddress;
    data['description'] = this.description;
    data['assessmentcomments'] = this.assessmentcomments;
    data['serviceScheduleType'] = this.serviceScheduleType;
    return data;
  }
}
extension GroupServiceModelExtension on GroupServiceModel {
  bool allowAddNote() {
    return (getDateTimeFromEpochTime(serviceDate!) !=
        null &&
        getDateTimeFromEpochTime(serviceDate!)!
            .isFutureDate ==
            false);
  }
}