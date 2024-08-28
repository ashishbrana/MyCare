class LoginResponseModel {
  int? status;
  int? accountType;
  int? userid;
  String? authcode;
  String? fullName;
  String? message;
  String? endofServiceDate;
  String? latestVersion;
  bool? is2FA;


  LoginResponseModel(
      {this.status,
      this.accountType,
      this.userid,
      this.authcode,
      this.fullName,
      this.message,
      this.endofServiceDate,
      this.latestVersion,
        this.is2FA
      });

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    accountType = json['accountType'];
    userid = json['userid'];
    authcode = json['authcode'];
    fullName = json['fullName'];
    message = json['message'];
    endofServiceDate = json['endofServiceDate'];
    latestVersion = json['latestVersion'];
    is2FA = json['is2FA'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['accountType'] = this.accountType;
    data['userid'] = this.userid;
    data['authcode'] = this.authcode;
    data['fullName'] = this.fullName;
    data['message'] = this.message;
    data['endofServiceDate'] = this.endofServiceDate;
    data['latestVersion'] = this.latestVersion;
    data['is2FA'] = this.is2FA;
    return data;
  }
}
