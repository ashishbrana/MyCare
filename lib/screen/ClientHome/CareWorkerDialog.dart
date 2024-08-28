import 'package:flutter/material.dart';

import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/ThemedWidgets.dart';
import '../home/TimeSheetForm.dart';
import 'model/CareWorker.dart';

class CareWorkerDialog extends StatelessWidget {
  final List<CareWorker> careWorkerList;

  const CareWorkerDialog({Key? key, required this.careWorkerList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      title: const Text('Care Workers'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: buildWorkerList(),
      ),
    );
  }

  buildWorkerList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: careWorkerList.length,
            itemBuilder: (context, index) {
              CareWorker model = careWorkerList[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                margin: const EdgeInsets.only(top: 8, right: 1, left: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedText(
                      text: "${model.careWorkerName}",
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    Row(
                      children: [
                        buildTWrokrerListItem(
                            "Start Time", model.timeFrom ?? ""),
                        const SizedBox(width: spaceHorizontal / 3),
                        buildTWrokrerListItem("End Time", model.timeTo ?? ""),
                        const SizedBox(width: spaceHorizontal / 3),
                        buildTWrokrerListItem(
                            "Hours(hh:mm)",
                            getTimeStringFromDouble(
                                model.totalhours?.toDouble() ?? 0.0)),
                      ],
                    ),
                    const SizedBox(height: spaceVertical),
                    buildDividerContainer(
                        MediaQuery.of(context).size.width * .9)
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Container buildDividerContainer(double width) {
    return Container(
      height: 1,
      width: width,
      color: colorDivider,
    );
  }

  Expanded buildTWrokrerListItem(String label, String time) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemedText(
            text: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          ThemedText(
            text: time,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
