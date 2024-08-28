class ClientServiceType {
  int? serviceTypeid;
  String? serviceTypeName;
  String? fundingSourceId;
  String? baseRate;
  num? priceListId;

  ClientServiceType(
      {this.serviceTypeid,
        this.serviceTypeName,
        this.fundingSourceId,
        this.baseRate,
        this.priceListId});

  ClientServiceType.fromJson(Map<String, dynamic> json) {
    serviceTypeid = json['ServiceTypeid'];
    serviceTypeName = json['ServiceTypeName'];
    fundingSourceId = json['FundingSourceId'];
    baseRate = json['BaseRate'];
    priceListId = json['PriceListId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ServiceTypeid'] = this.serviceTypeid;
    data['ServiceTypeName'] = this.serviceTypeName;
    data['FundingSourceId'] = this.fundingSourceId;
    data['BaseRate'] = this.baseRate;
    data['PriceListId'] = this.priceListId;
    return data;
  }
}
