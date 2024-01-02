class ClientFundingDetail {
  int? clientfundingid;
  String? name;
  int? fundingSourceID;
  String? fundingServiceName;
  String? sourceType;
  String? fundingPlan;
  double? utilizeTotal;
  double? balanceAmount;
  double? budget;
  String? startDate;
  String? endDate;

  ClientFundingDetail(
      {this.clientfundingid,
        this.name,
        this.fundingSourceID,
        this.fundingServiceName,
        this.sourceType,
        this.fundingPlan,
        this.utilizeTotal,
        this.balanceAmount,
        this.budget,
        this.startDate,
        this.endDate});

  ClientFundingDetail.fromJson(Map<String, dynamic> json) {
    clientfundingid = json['clientfundingid'];
    name = json['Name'];
    fundingSourceID = json['FundingSourceID'];
    fundingServiceName = json['FundingServiceName'];
    sourceType = json['SourceType'];
    fundingPlan = json['FundingPlan'];
    utilizeTotal = json['UtilizeTotal'];
    balanceAmount = json['BalanceAmount'];
    budget = json['Budget'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientfundingid'] = this.clientfundingid;
    data['Name'] = this.name;
    data['FundingSourceID'] = this.fundingSourceID;
    data['FundingServiceName'] = this.fundingServiceName;
    data['SourceType'] = this.sourceType;
    data['FundingPlan'] = this.fundingPlan;
    data['UtilizeTotal'] = this.utilizeTotal;
    data['BalanceAmount'] = this.balanceAmount;
    data['Budget'] = this.budget;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    return data;
  }
}
