class ClientInformationModel {
  int? iD;
  int? clientID;
  int? externalProviderId;
  String? gender;
  String? title;
  String? lastName;
  String? firstName;
  String? fullname;
  String? unitNo;
  String? address;
  String? city;
  String? pCode;
  String? state;
  String? entryDate;
  String? birthdate;
  String? homePhone;
  String? mobilePhone;
  String? email;
  String? userName;
  String? password;
  String? careComments;
  String? languagesSpoken;
  String? countryofBirth;
  String? prefName;
  bool? careNeedAssmt;
  int? exServiceID;
  bool? selectC;
  int? relativeID;
  String? rtitle;
  String? rFirstName;
  String? rLastName;
  String? raddress;
  String? rCity;
  String? rhomephone;
  String? rmobilephone;
  String? relationShip;
  bool? mailRecipient;
  String? remail;
  int? callOut;
  double? travelChargekm;
  String? endofServiceDate;
  String? endofServiceDateValue;
  String? riskNotification;
  String? birthDateValue;
  String? empProfilePic;
  String? clientGoals;

  ClientInformationModel(
      {this.iD,
        this.clientID,
        this.externalProviderId,
        this.gender,
        this.title,
        this.lastName,
        this.firstName,
        this.fullname,
        this.unitNo,
        this.address,
        this.city,
        this.pCode,
        this.state,
        this.entryDate,
        this.birthdate,
        this.homePhone,
        this.mobilePhone,
        this.email,
        this.userName,
        this.password,
        this.careComments,
        this.languagesSpoken,
        this.countryofBirth,
        this.prefName,
        this.careNeedAssmt,
        this.exServiceID,
        this.selectC,
        this.relativeID,
        this.rtitle,
        this.rFirstName,
        this.rLastName,
        this.raddress,
        this.rCity,
        this.rhomephone,
        this.rmobilephone,
        this.relationShip,
        this.mailRecipient,
        this.remail,
        this.callOut,
        this.travelChargekm,
        this.endofServiceDate,
        this.endofServiceDateValue,
        this.riskNotification,
        this.birthDateValue,
        this.empProfilePic,
        this.clientGoals});

  ClientInformationModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    clientID = json['ClientID'];
    externalProviderId = json['ExternalProviderId'];
    gender = json['Gender'];
    title = json['Title'];
    lastName = json['LastName'];
    firstName = json['FirstName'];
    fullname = json['Fullname'];
    unitNo = json['UnitNo'];
    address = json['Address'];
    city = json['City'];
    pCode = json['PCode'];
    state = json['State'];
    entryDate = json['EntryDate'];
    birthdate = json['Birthdate'];
    homePhone = json['HomePhone'];
    mobilePhone = json['MobilePhone'];
    email = json['Email'];
    userName = json['UserName'];
    password = json['Password'];
    careComments = json['CareComments'];
    languagesSpoken = json['LanguagesSpoken'];
    countryofBirth = json['CountryofBirth'];
    prefName = json['PrefName'];
    careNeedAssmt = json['CareNeedAssmt'];
    exServiceID = json['ExServiceID'];
    selectC = json['SelectC'];
    relativeID = json['RelativeID'];
    rtitle = json['Rtitle'];
    rFirstName = json['RFirstName'];
    rLastName = json['RLastName'];
    raddress = json['Raddress'];
    rCity = json['RCity'];
    rhomephone = json['Rhomephone'];
    rmobilephone = json['Rmobilephone'];
    relationShip = json['RelationShip'];
    mailRecipient = json['MailRecipient'];
    remail = json['Remail'];
    callOut = json['CallOut'];
    travelChargekm = json['TravelChargekm'];
    endofServiceDate = json['EndofServiceDate'];
    endofServiceDateValue = json['EndofServiceDateValue'];
    riskNotification = json['RiskNotification'];
    birthDateValue = json['BirthDateValue'];
    // empProfilePic = json['EmpProfilePic'];
    clientGoals = json['ClientGoals'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['ClientID'] = this.clientID;
    data['ExternalProviderId'] = this.externalProviderId;
    data['Gender'] = this.gender;
    data['Title'] = this.title;
    data['LastName'] = this.lastName;
    data['FirstName'] = this.firstName;
    data['Fullname'] = this.fullname;
    data['UnitNo'] = this.unitNo;
    data['Address'] = this.address;
    data['City'] = this.city;
    data['PCode'] = this.pCode;
    data['State'] = this.state;
    data['EntryDate'] = this.entryDate;
    data['Birthdate'] = this.birthdate;
    data['HomePhone'] = this.homePhone;
    data['MobilePhone'] = this.mobilePhone;
    data['Email'] = this.email;
    data['UserName'] = this.userName;
    data['Password'] = this.password;
    data['CareComments'] = this.careComments;
    data['LanguagesSpoken'] = this.languagesSpoken;
    data['CountryofBirth'] = this.countryofBirth;
    data['PrefName'] = this.prefName;
    data['CareNeedAssmt'] = this.careNeedAssmt;
    data['ExServiceID'] = this.exServiceID;
    data['SelectC'] = this.selectC;
    data['RelativeID'] = this.relativeID;
    data['Rtitle'] = this.rtitle;
    data['RFirstName'] = this.rFirstName;
    data['RLastName'] = this.rLastName;
    data['Raddress'] = this.raddress;
    data['RCity'] = this.rCity;
    data['Rhomephone'] = this.rhomephone;
    data['Rmobilephone'] = this.rmobilephone;
    data['RelationShip'] = this.relationShip;
    data['MailRecipient'] = this.mailRecipient;
    data['Remail'] = this.remail;
    data['CallOut'] = this.callOut;
    data['TravelChargekm'] = this.travelChargekm;
    data['EndofServiceDate'] = this.endofServiceDate;
    data['EndofServiceDateValue'] = this.endofServiceDateValue;
    data['RiskNotification'] = this.riskNotification;
    data['BirthDateValue'] = this.birthDateValue;
    data['EmpProfilePic'] = this.empProfilePic;
    data['ClientGoals'] = this.clientGoals;
    return data;
  }
}
