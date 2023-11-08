import 'package:flutter/material.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../utils/ColorConstants.dart';
import '../../utils/ThemedWidgets.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Change Password"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: spaceHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: spaceVertical*2),
              ThemedText(
                text: "Current Password",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: spaceBetween),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  hintText: "Current Password",
                ),
              ),
              const SizedBox(height: space),
              ThemedText(
                text: "New Password",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: spaceBetween),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  hintText: "New Password",
                ),
              ),
              const SizedBox(height: space),
              ThemedText(
                text: "Confirm New Password",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: spaceBetween),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  hintText: "Confirm New Password",
                ),
              ),
              const SizedBox(height: spaceVertical*3),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ThemedButton(
                        title: "Cancel",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: spaceHorizontal / 2),
                    Expanded(
                      child: ThemedButton(
                        title: "Save",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: space),
            ],
          ),
        ),
      ),
    );
  }
}
