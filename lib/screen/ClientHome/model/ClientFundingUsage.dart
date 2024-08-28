class ClientFundingUsage {
  String? name;
  String? ndisPlan;
  String? startTime;
  String? endTime;
  num? totalHours;
  num? totalAmount;
  String? fundinSource;
  int? rosterID;
  String? quantity;
  String? processClaim;
  int? serviceScheduleType;
  String? groupName;

  ClientFundingUsage(
      {this.name,
        this.ndisPlan,
        this.startTime,
        this.endTime,
        this.totalHours,
        this.totalAmount,
        this.fundinSource,
        this.rosterID,
        this.quantity,
        this.processClaim,
        this.serviceScheduleType,
        this.groupName});

  ClientFundingUsage.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    ndisPlan = json['ndisPlan'];
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    totalHours = json['TotalHours'];
    totalAmount = json['TotalAmount'];
    fundinSource = json['FundinSource'];
    rosterID = json['RosterID'];
    quantity = json['Quantity'];
    processClaim = json['ProcessClaim'];
    serviceScheduleType = json['serviceScheduleType'];
    groupName = json['groupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['ndisPlan'] = this.ndisPlan;
    data['StartTime'] = this.startTime;
    data['EndTime'] = this.endTime;
    data['TotalHours'] = this.totalHours;
    data['TotalAmount'] = this.totalAmount;
    data['FundinSource'] = this.fundinSource;
    data['RosterID'] = this.rosterID;
    data['Quantity'] = this.quantity;
    data['ProcessClaim'] = this.processClaim;
    data['serviceScheduleType'] = this.serviceScheduleType;
    data['groupName'] = this.groupName;
    return data;
  }

  bool get isGroupService => serviceScheduleType == 2;
}
