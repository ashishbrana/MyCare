import 'package:flutter/cupertino.dart';

closeKeyboard() {
  if (FocusManager.instance.primaryFocus != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
