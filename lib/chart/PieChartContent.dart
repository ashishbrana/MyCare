import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PieChartContent extends StatelessWidget {
  final List<PieChartSectionData> pieChartSectionData;

  const PieChartContent({super.key, required this.pieChartSectionData});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 0,
        sectionsSpace: 0,
        sections: pieChartSectionData,
      ),
    );
  }
}