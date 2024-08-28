class ServiceFormUpdateRequest {
  String? authCode;
  int? userid;
  int? rosterId;
  String? serviceDate;
  String? timeFrom;
  String? timeUntil;
  double? totalHours;
  int? servicetypeID;
  String? comments;
  int? isFunded;

  ServiceFormUpdateRequest(
      {this.authCode,
        this.userid,
       this.rosterId,
        this.serviceDate,
        this.timeFrom,
        this.timeUntil,
        this.totalHours,
        this.servicetypeID,
        this.comments,
        this.isFunded}
  );

  ServiceFormUpdateRequest.fromJson(Map<String, dynamic> json) {
    authCode = json['auth_code'];
    userid = json['userid'];
    rosterId =  json['RosterId'];
    serviceDate = json['ServiceDate'];
    timeFrom = json['TimeFrom'];
    timeUntil = json['TimeUntil'];
    totalHours = json['TotalHours'];
    servicetypeID = json['ServicetypeID'];
    comments = json['Comments'];
    isFunded = json['isFunded'];
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
    data['isFunded'] = isFunded;
    data['RosterId'] = rosterId;
    return data;
  }
}
