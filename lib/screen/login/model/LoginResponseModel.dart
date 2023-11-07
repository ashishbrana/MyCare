class LoginResponseModel {
  int? status;
  int? accountType;
  int? userid;
  String? authcode;
  String? fullName;
  String? message;

  LoginResponseModel(
      {this.status,
      this.accountType,
      this.userid,
      this.authcode,
      this.fullName,
      this.message});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    accountType = json['accountType'];
    userid = json['userid'];
    authcode = json['authcode'];
    fullName = json['fullName'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['accountType'] = this.accountType;
    data['userid'] = this.userid;
    data['authcode'] = this.authcode;
    data['fullName'] = this.fullName;
    data['message'] = this.message;
    return data;
  }
}
