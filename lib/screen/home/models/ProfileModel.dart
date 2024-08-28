class ProfileModel {
  int? employeeID;
  String? title;
  String? firstName;
  String? lastName;
  String? fullname;
  String? taxFileNumber;
  String? unitNo;
  String? address;
  String? city;
  String? state;
  String? postalCode;
  String? homePhone;
  String? workPhone;
  String? mobileNo;
  String? email;
  String? languages;
  String? emrgcyContactName;
  String? emrgcyContactPhone;
  String? privateEmail;
  String? userName;
  String? prefName;
  String? password;
  String? contractorName;
  String? empProfilePic;

  ProfileModel(
      {this.employeeID,
        this.title,
        this.firstName,
        this.lastName,
        this.fullname,
        this.taxFileNumber,
        this.unitNo,
        this.address,
        this.city,
        this.state,
        this.postalCode,
        this.homePhone,
        this.workPhone,
        this.mobileNo,
        this.email,
        this.languages,
        this.emrgcyContactName,
        this.emrgcyContactPhone,
        this.privateEmail,
        this.userName,
        this.prefName,
        this.password,
        this.contractorName,
        this.empProfilePic});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    employeeID = json['EmployeeID'];
    title = json['Title'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    fullname = json['Fullname'];
    taxFileNumber = json['TaxFileNumber'];
    unitNo = json['UnitNo'];
    address = json['Address'];
    city = json['City'];
    state = json['State'];
    postalCode = json['PostalCode'];
    homePhone = json['HomePhone'];
    workPhone = json['WorkPhone'];
    mobileNo = json['MobileNo'];
    email = json['email'];
    languages = json['Languages'];
    emrgcyContactName = json['EmrgcyContactName'];
    emrgcyContactPhone = json['EmrgcyContactPhone'];
    privateEmail = json['PrivateEmail'];
    userName = json['UserName'];
    password = json['Password'];
    contractorName = json['ContractorName'];
    empProfilePic = json['EmpProfilePic'];
    prefName = json['PrefName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['EmployeeID'] = this.employeeID;
    data['Title'] = this.title;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['Fullname'] = this.fullname;
    data['TaxFileNumber'] = this.taxFileNumber;
    data['UnitNo'] = this.unitNo;
    data['Address'] = this.address;
    data['City'] = this.city;
    data['State'] = this.state;
    data['PostalCode'] = this.postalCode;
    data['HomePhone'] = this.homePhone;
    data['WorkPhone'] = this.workPhone;
    data['MobileNo'] = this.mobileNo;
    data['email'] = this.email;
    data['Languages'] = this.languages;
    data['EmrgcyContactName'] = this.emrgcyContactName;
    data['EmrgcyContactPhone'] = this.emrgcyContactPhone;
    data['PrivateEmail'] = this.privateEmail;
    data['UserName'] = this.userName;
    data['Password'] = this.password;
    data['ContractorName'] = this.contractorName;
    data['EmpProfilePic'] = this.empProfilePic;
    data['PrefName'] = this.prefName;
    return data;
  }
}
