import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PieChartContent extends StatelessWidget {

  final List<PieChartSectionData> pieChartSectionData;

  PieChartContent({required this.pieChartSectionData});

  @override
  Widget build(BuildContext context) {
    return PieChart(PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        sections: pieChartSectionData
    ));
  }
}

