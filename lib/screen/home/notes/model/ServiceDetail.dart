class ServiceDetail {
  String? clientName;
  String? serviceName;
  String? noteDate;
  int? noteID;
  int? servicescheduleCLientID;
  int? clientID;
  int? createdBy;
  String? createdByName;
  String? createdOn;
  int? serviceScheduleEmpID;
  int? tSid;
  String? groupName;
  int? serviceScheduleType;

  ServiceDetail(
      {this.clientName,
      this.serviceName,
      this.noteDate,
      this.noteID,
      this.servicescheduleCLientID,
      this.clientID,
      this.createdBy,
      this.createdByName,
      this.createdOn,
      this.serviceScheduleEmpID,
      this.tSid,
      this.serviceScheduleType,
      this.groupName});

  ServiceDetail.fromJson(Map<String, dynamic> json) {
    clientName = json['ClientName'];
    serviceName = json['ServiceName'];
    noteDate = json['NoteDate'];
    noteID = json['NoteID'];
    servicescheduleCLientID = json['servicescheduleCLientID'];
    clientID = json['ClientID'];
    createdBy = json['CreatedBy'];
    createdByName = json['CreatedByName'];
    createdOn = json['CreatedOn'];
    serviceScheduleEmpID = json['ServiceScheduleEmpID'];
    tSid = json['TSid'];
    serviceScheduleType = json['serviceScheduleType'];
    groupName = json['groupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientName'] = this.clientName;
    data['ServiceName'] = this.serviceName;
    data['NoteDate'] = this.noteDate;
    data['NoteID'] = this.noteID;
    data['servicescheduleCLientID'] = this.servicescheduleCLientID;
    data['ClientID'] = this.clientID;
    data['CreatedBy'] = this.createdBy;
    data['CreatedByName'] = this.createdByName;
    data['CreatedOn'] = this.createdOn;
    data['ServiceScheduleEmpID'] = this.serviceScheduleEmpID;
    data['TSid'] = this.tSid;
    data['serviceScheduleType'] = this.serviceScheduleType;
    data['groupName'] = this.groupName;
    return data;
  }
}
