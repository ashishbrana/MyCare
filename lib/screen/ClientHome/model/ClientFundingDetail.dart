import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ClientFundingDetail {
  int? clientfundingid;
  String? name;
  int? fundingSourceID;
  String? fundingServiceName;
  String? sourceType;
  String? fundingPlan;
  num? utilizeTotal;
  num? balanceAmount;
  num? budget;
  String? startDate;
  String? endDate;
  num? openBalance;

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
        this.endDate,
        this.openBalance
      });

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
    openBalance = json['OpenBalance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clientfundingid'] = this.clientfundingid;
    data['Name'] = name;
    data['FundingSourceID'] = fundingSourceID;
    data['FundingServiceName'] = this.fundingServiceName;
    data['SourceType'] = sourceType;
    data['FundingPlan'] = fundingPlan;
    data['UtilizeTotal'] = utilizeTotal;
    data['BalanceAmount'] = balanceAmount;
    data['Budget'] = budget;
    data['StartDate'] = startDate;
    data['EndDate'] = endDate;
    data['OpenBalance'] = openBalance;
    return data;
  }
  double getPercentFor(num? amount) {
    if (this.openBalance != null && amount != null) {
      double openBalance = this.openBalance?.toDouble() ?? 0.0;
      double utilize = amount.toDouble() ?? 0.0;

      if (openBalance > 0 && utilize > 0) {
        double budgetPercent = utilize / openBalance;
        return budgetPercent*100; // Return the calculated value
      } else {
        // Handle division by zero case, if needed
        return 0;
      }
    } else {
      return 0; // Return a default value when either budgetAmount or utilizeTotal is null
    }
  }

  List<PieChartSectionData> getSectionData(double screenWidth) {
    double radius = screenWidth / 4.44;

    return [
      PieChartSectionData(
        value: getPercentFor(utilizeTotal),
        showTitle: false,
        // title: "\$${this.utilizeTotal.toString()}\n50%",
        radius: radius,
        color: Colors.red,
        badgeWidget: Text(
          "\$${utilizeTotal.toString()}\n${getPercentFor(utilizeTotal).toStringAsFixed(2)}%",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
        ),
      ),
      PieChartSectionData(
        value: getPercentFor(this.balanceAmount),
        showTitle: false,
        //  title: "\$${this.balanceAmount.toString()}30%",
        radius: radius,
        color: Colors.green,
        badgeWidget: Text(
          "\$${balanceAmount.toString()}\n${getPercentFor(balanceAmount).toStringAsFixed(2)}%",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
        ),
      ),
    ];
  }
}

