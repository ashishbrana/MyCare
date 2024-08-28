import '../../../utils/methods.dart';

class DSNListModel {
  int? id;
  int? sscid;
  bool? taskcompleted;
  Null? starttime;
  Null? endtime;
  String? taskname;
  String? taskcompletedcomments;
  String? taskdescription;
  Null? ssDetails;
  String? notewriter;
  String? timefrom;
  String? timeto;
  int? notewriterid;
  String? sscname;
  String? ssdate;

  DSNListModel(
      {this.id,
      this.sscid,
      this.taskcompleted,
      this.starttime,
      this.endtime,
      this.taskname,
      this.taskcompletedcomments,
      this.taskdescription,
      this.ssDetails,
      this.notewriter,
      this.timefrom,
      this.timeto,
      this.notewriterid,
      this.ssdate,
      this.sscname});

  DSNListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sscid = json['sscid'];
    taskcompleted = json['taskcompleted'];
    starttime = json['starttime'];
    endtime = json['endtime'];
    taskname = json['taskname'];
    ssdate = json['ssdate'];
    taskcompletedcomments = json['taskcompletedcomments'];
    taskdescription = json['taskdescription'];
    ssDetails = json['ssDetails'];
    notewriter = json['notewriter'];
    timefrom = json['timefrom'];
    timeto = json['timeto'];
    notewriterid = json['notewriterid'];
    sscname = json['sscname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sscid'] = this.sscid;
    data['taskcompleted'] = this.taskcompleted;
    data['starttime'] = this.starttime;
    data['endtime'] = this.endtime;
    data['taskname'] = this.taskname;
    data['taskcompletedcomments'] = this.taskcompletedcomments;
    data['taskdescription'] = this.taskdescription;
    data['ssDetails'] = this.ssDetails;
    data['notewriter'] = this.notewriter;
    data['timefrom'] = this.timefrom;
    data['ssdate'] = this.ssdate;
    data['timeto'] = this.timeto;
    data['notewriterid'] = this.notewriterid;
    data['sscname'] = this.sscname;
    return data;
  }

  bool get isFutureDate =>
     (getDateTimeFromEpochTime(ssdate!) !=
        null &&
        getDateTimeFromEpochTime(ssdate!)!
            .isFutureDate);

}
