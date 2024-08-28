
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ClientFundingCode {
  num? fundingCodeID;
  String? name;
  String? serviceType;
  String? clientFundingName;
  String? fundingSourceName;
  String? code;
  num? utilizeTotal;
  num? balanceAmount;
  num? budgetAmount;
  num? openBalance;

  ClientFundingCode(
      {this.fundingCodeID,
      this.name,
      this.serviceType,
      this.clientFundingName,
      this.code,
      this.utilizeTotal,
      this.balanceAmount,
      this.budgetAmount,
      this.openBalance,
      this.fundingSourceName});

  ClientFundingCode.fromJson(Map<String, dynamic> json) {
    fundingCodeID = json['FundingCodeID'];
    name = json['Name'];
    serviceType = json['ServiceType'];
    clientFundingName = json['ClientFundingName'];
    code = json['Code'];
    utilizeTotal = json['UtilizeTotal'];
    balanceAmount = json['BalanceAmount'];
    budgetAmount = json['BudgetAmount'];
    openBalance = json['OpenBalance'];
    fundingSourceName = json['FundingSourceName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FundingCodeID'] = fundingCodeID;
    data['Name'] = name;
    data['ServiceType'] = serviceType;
    data['ClientFundingName'] = clientFundingName;
    data['Code'] = code;
    data['UtilizeTotal'] = utilizeTotal;
    data['BalanceAmount'] = balanceAmount;
    data['BudgetAmount'] = budgetAmount;
    data['OpenBalance'] = openBalance;
    data['FundingSourceName'] = fundingSourceName;
    return data;
  }

  double getPercentFor(num? amount) {
    if (openBalance != null && amount != null) {
      double budget = openBalance?.toDouble() ?? 0.0;
      double utilize = amount.toDouble();

      if (budget > 0 && utilize > 0) {
        double budgetPercent = utilize / budget;
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
        value: getPercentFor(balanceAmount),
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
