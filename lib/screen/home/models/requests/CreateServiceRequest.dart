class CreateServiceRequest {
  String? authCode;
  int? userid;
  String? serviceDate;
  String? weekday;
  String? timeFrom;
  String? timeUntil;
  int? totalHours;
  int? comID;
  String? brokerageNo;
  String? comments;
  String? shiftComments;
  int? clientPayRate;
  int? clientPay;
  int? callOut;
  int? clientTotalPay;
  int? contrID;
  int? flag;

  CreateServiceRequest(
      {this.authCode,
        this.userid,
        this.serviceDate,
        this.weekday,
        this.timeFrom,
        this.timeUntil,
        this.totalHours,
        this.comID,
        this.brokerageNo,
        this.comments,
        this.shiftComments,
        this.clientPayRate,
        this.clientPay,
        this.callOut,
        this.clientTotalPay,
        this.contrID,
        this.flag});

  CreateServiceRequest.fromJson(Map<String, dynamic> json) {
    authCode = json['auth_code'];
    userid = json['userid'];
    serviceDate = json['ServiceDate'];
    weekday = json['Weekday'];
    timeFrom = json['TimeFrom'];
    timeUntil = json['TimeUntil'];
    totalHours = json['TotalHours'];
    comID = json['ComID'];
    brokerageNo = json['BrokerageNo'];
    comments = json['Comments'];
    shiftComments = json['ShiftComments'];
    clientPayRate = json['ClientPayRate'];
    clientPay = json['ClientPay'];
    callOut = json['CallOut'];
    clientTotalPay = json['ClientTotalPay'];
    contrID = json['ContrID'];
    flag = json['flag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auth_code'] = this.authCode;
    data['userid'] = this.userid;
    data['ServiceDate'] = this.serviceDate;
    data['Weekday'] = this.weekday;
    data['TimeFrom'] = this.timeFrom;
    data['TimeUntil'] = this.timeUntil;
    data['TotalHours'] = this.totalHours;
    data['ComID'] = this.comID;
    data['BrokerageNo'] = this.brokerageNo;
    data['Comments'] = this.comments;
    data['ShiftComments'] = this.shiftComments;
    data['ClientPayRate'] = this.clientPayRate;
    data['ClientPay'] = this.clientPay;
    data['CallOut'] = this.callOut;
    data['ClientTotalPay'] = this.clientTotalPay;
    data['ContrID'] = this.contrID;
    data['flag'] = this.flag;
    return data;
  }
}