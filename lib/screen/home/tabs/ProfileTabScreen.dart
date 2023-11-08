import 'package:flutter/material.dart';
import 'package:rcare_2/screen/login/ChangePassword.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Profile"),
      body: SafeArea(
        child: Column(
          children: [
            /*Material(
              elevation: 3,
              color: colorWhite,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: spaceHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: spaceVertical),
                    ThemedText(text: "Care Worker Profile Page"),
                    const SizedBox(height: spaceVertical),

                    const SizedBox(height: spaceVertical),
                  ],
                ),
              ),
            ),*/
            Expanded(
              child: Container(
                color: colorLiteBlueBackGround,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: spaceHorizontal, vertical: spaceVertical),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: Image.network(
                                      "https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1699430153~exp=1699430753~hmac=a141c1497a8aa23749636014e4fea408c3db11ac12fef8513708e0995fa26bcc",
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(color: colorGrey33);
                                      },
                                    ),
                                  ),
                                  ThemedText(
                                    text: "Upload",
                                    color: colorBlue,
                                  ),
                                  ThemedText(
                                    text: "Picture",
                                    color: colorBlue,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: spaceHorizontal),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: space),
                                  ThemedRichText(
                                    spanList: [
                                      getTextSpan(
                                        text: "First Name",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontColor: colorRed,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: spaceBetween),
                                  SizedBox(
                                    height: textFiledHeight,
                                    child: ThemedTextField(
                                      borderColor: colorGreyBorderD3,
                                      backgroundColor: colorWhite,
                                    ),
                                  ),
                                  const SizedBox(height: space),
                                  ThemedRichText(
                                    spanList: [
                                      getTextSpan(
                                        text: "Last Name",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontColor: colorRed,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: spaceBetween),
                                  SizedBox(
                                    height: 45,
                                    child: ThemedTextField(
                                      borderColor: colorGreyBorderD3,
                                      backgroundColor: colorWhite,
                                    ),
                                  ),
                                  const SizedBox(height: space),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: space),
                        ThemedText(
                          text: "Email Address",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: spaceBetween),
                        SizedBox(
                          height: textFiledHeight,
                          child: ThemedTextField(
                            borderColor: colorGreyBorderD3,
                            backgroundColor: colorWhite,
                          ),
                        ),
                        const SizedBox(height: space),
                        ThemedRichText(
                          spanList: [
                            getTextSpan(
                              text: "Address",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            getTextSpan(
                              text: "*",
                              fontSize: 14,
                              fontColor: colorRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        const SizedBox(height: spaceBetween),
                        SizedBox(
                          height: textFiledHeight,
                          child: ThemedTextField(
                            borderColor: colorGreyBorderD3,
                            backgroundColor: colorWhite,
                          ),
                        ),
                        const SizedBox(height: space),
                        ThemedRichText(
                          spanList: [
                            getTextSpan(
                              text: "Suburb",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            getTextSpan(
                              text: "*",
                              fontSize: 14,
                              fontColor: colorRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        const SizedBox(height: spaceBetween),
                        SizedBox(
                          height: textFiledHeight,
                          child: ThemedTextField(
                            borderColor: colorGreyBorderD3,
                            backgroundColor: colorWhite,
                          ),
                        ),
                        const SizedBox(height: space),
                        ThemedText(
                          text: "Home Phone",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: spaceBetween),
                        SizedBox(
                          height: textFiledHeight,
                          child: ThemedTextField(
                            borderColor: colorGreyBorderD3,
                            backgroundColor: colorWhite,
                          ),
                        ),
                        const SizedBox(height: space),
                        ThemedText(
                          text: "Mobile No",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: spaceBetween),
                        SizedBox(
                          height: textFiledHeight,
                          child: ThemedTextField(
                            borderColor: colorGreyBorderD3,
                            backgroundColor: colorWhite,
                          ),
                        ),
                        const SizedBox(height: space),
                        ThemedText(
                          text: "Work Phone No",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: spaceBetween),
                        SizedBox(
                          height: textFiledHeight,
                          child: ThemedTextField(
                            borderColor: colorGreyBorderD3,
                            backgroundColor: colorWhite,
                          ),
                        ),
                        const SizedBox(height: space),
                        ThemedText(
                          text: "UserName",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: spaceBetween),
                        SizedBox(
                          height: textFiledHeight,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: ThemedTextField(
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                ),
                              ),
                              const SizedBox(width: spaceHorizontal / 2),
                              Expanded(
                                flex: 4,
                                child: ThemedButton(
                                  title: "Change Password",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  padding: EdgeInsets.zero,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ChangePassword(),
                                        ));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: spaceVertical),
                        SizedBox(
                          height: 40,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
