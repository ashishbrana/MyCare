import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';

import 'ColorConstants.dart';
import 'Constants.dart';
import 'Strings.dart';

Widget buildHeaderWithBlueBack(BuildContext context, String title) {
  return Container(
    color: colorBlue,
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    child: Text(
      title,
      style: const TextStyle(
        color: colorWhite,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: stringFontFamily,
      ),
    ),
  );
}

Widget buildTabBar(
    {TabController? controllerTab,
    required List<String> tabList,
    Function(int)? onTap}) {
  return TabBar(
    controller: controllerTab,
    // labelStyle: const TextStyle(
    //   fontWeight: FontWeight.w800,
    //   fontSize: 18,
    // ),
    labelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: stringFontFamily,
    ),
    unselectedLabelColor: colorBlue,
    labelColor: colorBlue,
    indicatorColor: colorBlue,
    indicatorWeight: 5,
    onTap: onTap,
    tabs: tabList
        .map(
          (e) => Tab(
            text: e,
          ),
        )
        .toList(),
  );
}

Widget buildNoDataAvailable(String msg) {
  return Center(
    child: Text(
      msg,
      style: const TextStyle(color: colorBlack, fontSize: 14),
    ),
  );
}

Widget buildHorizontalDivider(double height) {
  return Container(
    width: 1,
    height: height,
    margin: const EdgeInsets.all(spaceVertical),
    color: colorGreyDarkText,
  );
}

PreferredSizeWidget buildAppBar(BuildContext context,
    {required String title,
    bool isComeWithBackButton = true,
    bool isBackButtonEnable = true}) {
  return AppBar(
    toolbarHeight: 80,
    backgroundColor: colorGreen,
    foregroundColor: colorWhite,
    elevation: 0,
    centerTitle: false,
    titleSpacing: isComeWithBackButton ? 0 : null,
    leading: isComeWithBackButton
        ? IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorWhite,
            ),
            onPressed: () {
              if (isBackButtonEnable) {
                Navigator.pop(context);
              }
            },
          )
        : null,
    title: ThemedText(
      text: title,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: colorWhite,
    ),
    iconTheme: const IconThemeData(
      size: 30,
      color: colorBlue,
    ),
    automaticallyImplyLeading: true,
    actions: const [
      // if (isTimerVisible) timerWidget ?? Container(),
    ],
  );
}

Widget buildVerticalDivider(
    {Color color = colorDivider,
    double height = 1,
    double leftSpace = 10,
    double rightSpace = 10}) {
  return Divider(
    color: color,
    indent: leftSpace,
    endIndent: rightSpace,
    thickness: height,
    height: height,
  );
}

/*Widget buildDrawer() {
  return Drawer();
}*/
