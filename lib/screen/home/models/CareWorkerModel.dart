class CareWorkerModel {
  int? noteID;
  String? serviceDate;
  int? userid;
  String? careWorkerName;
  String? serviceType;
  String? timeFrom;
  String? timeTo;
  int? totalhours;
  String? clientName;
  int? servicescheduleCLientID;
  int? serviceScheduleID;
  String? groupname;
  int? serviceScheduleEmployeeID;

  CareWorkerModel(
      {this.noteID,
        this.serviceDate,
        this.userid,
        this.careWorkerName,
        this.serviceType,
        this.timeFrom,
        this.timeTo,
        this.totalhours,
        this.clientName,
        this.servicescheduleCLientID,
        this.serviceScheduleID,
        this.groupname,
        this.serviceScheduleEmployeeID});

  CareWorkerModel.fromJson(Map<String, dynamic> json) {
    noteID = json['NoteID'];
    serviceDate = json['ServiceDate'];
    userid = json['userid'];
    careWorkerName = json['CareWorkerName'];
    serviceType = json['ServiceType'];
    timeFrom = json['TimeFrom'];
    timeTo = json['TimeTo'];
    totalhours = json['totalhours'];
    clientName = json['ClientName'];
    servicescheduleCLientID = json['servicescheduleCLientID'];
    serviceScheduleID = json['ServiceScheduleID'];
    groupname = json['groupname'];
    serviceScheduleEmployeeID = json['serviceScheduleEmployeeID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NoteID'] = this.noteID;
    data['ServiceDate'] = this.serviceDate;
    data['userid'] = this.userid;
    data['CareWorkerName'] = this.careWorkerName;
    data['ServiceType'] = this.serviceType;
    data['TimeFrom'] = this.timeFrom;
    data['TimeTo'] = this.timeTo;
    data['totalhours'] = this.totalhours;
    data['ClientName'] = this.clientName;
    data['servicescheduleCLientID'] = this.servicescheduleCLientID;
    data['ServiceScheduleID'] = this.serviceScheduleID;
    data['groupname'] = this.groupname;
    data['serviceScheduleEmployeeID'] = this.serviceScheduleEmployeeID;
    return data;
  }
}
