class ProgressNoteListByNoteIdModel {
  int? noteID;
  int? serviceScheduleClientID;
  int? asessmentScale;
  int? clientID;
  String? asessmentComment;
  String? subject;
  String? description;
  String? noteDate;
  String? ssdate;
  String? clientsignature;
  int? createdBy;
  int? serviceassessment;
  String? serviceassessmentformName;
  String? createdByName;
  String? clientRating;
  String? createdOn;

  ProgressNoteListByNoteIdModel(
      {this.noteID,
        this.serviceScheduleClientID,
        this.asessmentScale,
        this.clientID,
        this.asessmentComment,
        this.subject,
        this.description,
        this.noteDate,
        this.ssdate,
        this.clientsignature,
        this.createdBy,
        this.serviceassessment,
        this.serviceassessmentformName,
        this.createdByName,
        this.clientRating,
        this.createdOn});

  ProgressNoteListByNoteIdModel.fromJson(Map<String, dynamic> json) {
    noteID = json['NoteID'];
    serviceScheduleClientID = json['ServiceScheduleClientID'];
    asessmentScale = json['AsessmentScale'];
    clientID = json['ClientID'];
    asessmentComment = json['AsessmentComment'];
    subject = json['Subject'];
    description = json['Description'];
    noteDate = json['NoteDate'];
    ssdate = json['ssdate'];
    clientsignature = json['clientsignature'];
    createdBy = json['CreatedBy'];
    serviceassessment = json['serviceassessment'];
    serviceassessmentformName = json['serviceassessmentformName'];
    createdByName = json['CreatedByName'];
    clientRating = json['ClientRating'];
    createdOn = json['CreatedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NoteID'] = this.noteID;
    data['ServiceScheduleClientID'] = this.serviceScheduleClientID;
    data['AsessmentScale'] = this.asessmentScale;
    data['ClientID'] = this.clientID;
    data['AsessmentComment'] = this.asessmentComment;
    data['Subject'] = this.subject;
    data['Description'] = this.description;
    data['NoteDate'] = this.noteDate;
    data['ssdate'] = this.ssdate;
    data['clientsignature'] = this.clientsignature;
    data['CreatedBy'] = this.createdBy;
    data['serviceassessment'] = this.serviceassessment;
    data['serviceassessmentformName'] = this.serviceassessmentformName;
    data['CreatedByName'] = this.createdByName;
    data['ClientRating'] = this.clientRating;
    data['CreatedOn'] = this.createdOn;
    return data;
  }
}
