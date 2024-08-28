import 'package:rcare_2/screen/ClientHome/model/ClientProfile.dart';

class ClientProfileRequest {
  String? authCode;
  int? clientID;
  String? title;
  String? lastName;
  String? firstName;
  String? prefName;
  String? address1;
  String? address2;
  String? pCode;
  String? state;
  String? homePhone;
  String? mobilePhone;
  String? email;
  String? careComments;
  String? endofServiceDate;
  String? riskNotification;
  String? suburb;


  ClientProfileRequest(
      {this.authCode,
        this.clientID,
        this.title,
        this.lastName,
        this.firstName,
        this.prefName,
        this.address1,
        this.address2,
        this.pCode,
        this.state,
        this.homePhone,
        this.mobilePhone,
        this.email,
        this.careComments,
        this.endofServiceDate,
        this.riskNotification,
        this.suburb
      });

  ClientProfileRequest.createProfileRequest(ClientProfile profile){

    pCode = profile.pCode;
    address1 = profile.address1;
    address2 = profile.address2;

   endofServiceDate = profile.endofServiceDate;
   lastName = profile.lastName;
   homePhone = profile.homePhone;
   state = profile.state;
   mobilePhone = profile.mobilePhone;
   firstName = profile.firstName;
   clientID = profile.clientID?.toInt() ?? 0;
   careComments = profile.careComments;
   riskNotification = profile.riskNotification;
   title = profile.title;
   email = profile.email;
   authCode = "";
   suburb = "${profile.city} ${profile.state} ${profile.pCode}";
  }

  ClientProfileRequest.fromJson(Map<String, dynamic> json) {
    authCode = json['auth_code'];
    clientID = json['ClientID'];
    title = json['Title'];
    lastName = json['LastName'];
    firstName = json['FirstName'];
    address1 = json['Address1'];
    address2 = json['Address2'];
    pCode = json['PCode'];
    state = json['State'];
    homePhone = json['HomePhone'];
    mobilePhone = json['MobilePhone'];
    email = json['Email'];
    careComments = json['CareComments'];
    endofServiceDate = json['EndofServiceDate'];
    riskNotification = json['RiskNotification'];
    suburb = json['Suburb'];
    prefName = json['PrefName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auth_code'] = authCode;
    data['ClientID'] = clientID;
    data['LastName'] = lastName;
    data['FirstName'] = firstName;
    data['Address1'] = address1;
    data['Address2'] = address2;
    data['PCode'] = pCode;
    data['State'] = state;
    data['HomePhone'] = homePhone;
    data['MobilePhone'] = mobilePhone;
    data['Email'] = email;
    data['CareComments'] = careComments;
    data['EndofServiceDate'] = endofServiceDate;
    data['RiskNotification'] = riskNotification;
    data['Suburb'] = suburb;
    data['PrefName'] = prefName;
    return data;
  }
}