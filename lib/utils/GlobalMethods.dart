import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

closeKeyboard() {
  if (FocusManager.instance.primaryFocus != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

launchUrlMethod(String url) async {
  try {
    if (!await launchUrl(Uri.parse(url))) {
      print('Could not launch $url');
    }
  } catch (e) {
    print('Could not launch error :  $e');
  }
}
