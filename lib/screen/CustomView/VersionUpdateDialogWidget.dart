import 'package:flutter/material.dart';

import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/ThemedWidgets.dart';

class VersionUpdateDialogWidget extends StatefulWidget {
  final void Function() onYesTap;
  final String? extendedText;

  const VersionUpdateDialogWidget({
    Key? key,
    required this.onYesTap,
    this.extendedText,
  }) : super(key: key);

  @override
  _VersionUpdateDialogWidgetState createState() =>
      _VersionUpdateDialogWidgetState();
}

class _VersionUpdateDialogWidgetState extends State<VersionUpdateDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: boxBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 20),
              ThemedText(
                text: "Update available",
                color: colorBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(child:

              ThemedText(
                text: "Please download latest version",
                color: colorBlack,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),

              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 30,
            child: Row(
              children: [
                const SizedBox(width: spaceHorizontal * 2),
                Expanded(
                  child: ThemedButton(
                    title: "Ok",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    padding: EdgeInsets.zero,
                    onTap: widget.onYesTap,
                  ),
                ),
                const SizedBox(width: spaceHorizontal * 2),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}