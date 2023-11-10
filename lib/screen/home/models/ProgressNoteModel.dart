class ProgressNoteModel {
  String? clientName;
  String? serviceName;
  String? noteDate;
  String? subject;
  String? timeFrom;
  int? noteID;
  int? servicescheduleCLientID;
  String? totalHours;
  String? timeTo;
  String? assessmentScale;
  String? assessmentComment;
  String? description;
  int? clientID;
  String? clientsignature;
  Null? noteImagebase64;
  int? createdBy;
  String? createdByName;
  String? clientRating;
  String? createdOn;
  int? serviceScheduleEmpID;
  int? tSid;

  ProgressNoteModel(
      {this.clientName,
        this.serviceName,
        this.noteDate,
        this.subject,
        this.timeFrom,
        this.noteID,
        this.servicescheduleCLientID,
        this.totalHours,
        this.timeTo,
        this.assessmentScale,
        this.assessmentComment,
        this.description,
        this.clientID,
        this.clientsignature,
        this.noteImagebase64,
        this.createdBy,
        this.createdByName,
        this.clientRating,
        this.createdOn,
        this.serviceScheduleEmpID,
        this.tSid});

  ProgressNoteModel.fromJson(Map<String, dynamic> json) {
    clientName = json['ClientName'];
    serviceName = json['ServiceName'];
    noteDate = json['NoteDate'];
    subject = json['Subject'];
    timeFrom = json['TimeFrom'];
    noteID = json['NoteID'];
    servicescheduleCLientID = json['servicescheduleCLientID'];
    totalHours = json['TotalHours'];
    timeTo = json['TimeTo'];
    assessmentScale = json['AssessmentScale'];
    assessmentComment = json['AssessmentComment'];
    description = json['Description'];
    clientID = json['ClientID'];
    clientsignature = json['clientsignature'];
    noteImagebase64 = json['noteImagebase64'];
    createdBy = json['CreatedBy'];
    createdByName = json['CreatedByName'];
    clientRating = json['ClientRating'];
    createdOn = json['CreatedOn'];
    serviceScheduleEmpID = json['ServiceScheduleEmpID'];
    tSid = json['TSid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientName'] = this.clientName;
    data['ServiceName'] = this.serviceName;
    data['NoteDate'] = this.noteDate;
    data['Subject'] = this.subject;
    data['TimeFrom'] = this.timeFrom;
    data['NoteID'] = this.noteID;
    data['servicescheduleCLientID'] = this.servicescheduleCLientID;
    data['TotalHours'] = this.totalHours;
    data['TimeTo'] = this.timeTo;
    data['AssessmentScale'] = this.assessmentScale;
    data['AssessmentComment'] = this.assessmentComment;
    data['Description'] = this.description;
    data['ClientID'] = this.clientID;
    data['clientsignature'] = this.clientsignature;
    data['noteImagebase64'] = this.noteImagebase64;
    data['CreatedBy'] = this.createdBy;
    data['CreatedByName'] = this.createdByName;
    data['ClientRating'] = this.clientRating;
    data['CreatedOn'] = this.createdOn;
    data['ServiceScheduleEmpID'] = this.serviceScheduleEmpID;
    data['TSid'] = this.tSid;
    return data;
  }
}