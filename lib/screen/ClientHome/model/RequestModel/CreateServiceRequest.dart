class CreateServiceRequest {
  String? authCode;
  int? userid;
  String? serviceDate;
  String? timeFrom;
  String? timeUntil;
  double? totalHours;
  int? servicetypeID;
  String? comments;
  String? shiftComments;
  int? isFunded;
  bool? isRecurring;
  int? interval;
  String? daysOfWeek;
  String? endOfServiceDate;
  num? rate;

  CreateServiceRequest(
      {this.authCode,
        this.userid,
        this.serviceDate,
        this.timeFrom,
        this.timeUntil,
        this.totalHours,
        this.servicetypeID,
        this.comments,
        this.shiftComments,
        this.isFunded,
        this.isRecurring,
        this.interval,
        this.daysOfWeek,
        this.endOfServiceDate,
        this.rate
      });

  CreateServiceRequest.fromJson(Map<String, dynamic> json) {
    authCode = json['auth_code'];
    userid = json['userid'];
    serviceDate = json['ServiceDate'];
    timeFrom = json['TimeFrom'];
    timeUntil = json['TimeUntil'];
    totalHours = json['TotalHours'];
    servicetypeID = json['ServicetypeID'];
    comments = json['Comments'];
    shiftComments = json['ShiftComments'];
    isFunded = json['isFunded'];
    isRecurring = json['IsRecurring'];
    interval = json['Interval'];
    daysOfWeek = json['DaysOfWeek'];
    endOfServiceDate = json['EndOfServiceDate'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auth_code'] = authCode;
    data['userid'] = userid;
    data['ServiceDate'] = serviceDate;
    data['TimeFrom'] = timeFrom;
    data['TimeUntil'] = timeUntil;
    data['TotalHours'] = totalHours;
    data['ServicetypeID'] = servicetypeID;
    data['Comments'] = comments;
    data['ShiftComments'] = shiftComments;
    data['isFunded'] = isFunded;
    data['IsRecurring'] = isRecurring;
    data['Interval'] = interval;
    data['DaysOfWeek'] = daysOfWeek;
    data['EndOfServiceDate'] = endOfServiceDate;
    data['rate'] = rate;
    return data;
  }
}
