import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/ThemedWidgets.dart';

class CustomDateDialog extends StatefulWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final Function(DateTime fromDate, DateTime toDate) onApply;

  CustomDateDialog({
    required this.fromDate,
    required this.toDate,
    required this.onApply,
  });

  @override
  _CustomDateDialogState createState() => _CustomDateDialogState();
}

class _CustomDateDialogState extends State<CustomDateDialog> {
  late TextEditingController controllerFromDate;
  late TextEditingController controllerToDate;
  late DateTime tempFromDate;
  late DateTime tempToDate;

  @override
  void initState() {
    super.initState();
    controllerFromDate = TextEditingController();
    controllerToDate = TextEditingController();
    tempFromDate = widget.fromDate;
    tempToDate = widget.toDate;
    updateDates();
  }

  void updateDates() {
    controllerFromDate.text = DateFormat("dd-MM-yyyy").format(tempFromDate);
    controllerToDate.text = DateFormat("dd-MM-yyyy").format(tempToDate);
  }

  Widget buildIconContainer(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorLiteGreen,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: FaIcon(
        icon,
        color: colorGreyText,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius * 2)),
      insetPadding: const EdgeInsets.symmetric(
          horizontal: spaceHorizontal, vertical: spaceVertical * 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: spaceHorizontal, vertical: spaceVertical * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            ThemedTextField(
              controller: controllerFromDate,
              borderColor: colorGreyBorderD3,
              isReadOnly: true,
              labelText: "From Date",
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: tempFromDate,
                  firstDate: DateTime(tempFromDate.year - 3),
                  lastDate: DateTime(tempFromDate.year + 3),
                ).then((value) {
                  if (value != null) {
                    tempFromDate = value;
                    updateDates();
                    setState(() {});
                  }
                });
              },
              hintFontWeight: FontWeight.bold,
              fontWeight: FontWeight.bold,
              preFix: const Icon(
                Icons.calendar_month_outlined,
                color: colorGreen,
                size: 20,
              ),
              sufFix: InkWell(
                onTap: () {
                  tempFromDate = tempFromDate.add(const Duration(days: 15));
                  tempToDate = tempFromDate.add(const Duration(days: 14));
                  updateDates();
                  setState(() {});
                },
                child: buildIconContainer(FontAwesomeIcons.plus),
              ),
            ),
            const SizedBox(height: 20),
            ThemedTextField(
              controller: controllerToDate,
              borderColor: colorGreyBorderD3,
              isReadOnly: true,
              labelText: "To Date",
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: tempToDate,
                  firstDate: tempFromDate,
                  lastDate: DateTime(tempToDate.year + 3),
                ).then((value) {
                  if (value != null) {
                    tempToDate = value;
                    updateDates();
                    setState(() {});
                  }
                });
              },
              hintFontWeight: FontWeight.bold,
              fontWeight: FontWeight.bold,
              preFix: const Icon(
                Icons.calendar_month_outlined,
                color: colorGreen,
                size: 20,
              ),
              sufFix: InkWell(
                onTap: () {
                  tempFromDate = tempFromDate.subtract(const Duration(days: 15));
                  tempToDate = tempFromDate.add(const Duration(days: 14));
                  updateDates();
                  setState(() {});
                },
                child: buildIconContainer(FontAwesomeIcons.minus),
              ),
            ),
            const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: Row(
              children: [
                Expanded(
                  child: ThemedButton(
                    title: "Apply",
                    fontSize: 20,
                    padding: EdgeInsets.zero,
                    onTap: () {
                      widget.onApply(tempFromDate, tempToDate);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ThemedButton(
                    fontSize: 20,
                    padding: EdgeInsets.zero,
                    title: "Cancel",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

              ],
            ),
        ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
