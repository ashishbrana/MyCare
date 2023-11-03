import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/ColorConstants.dart';
import 'Constants.dart';
import 'GlobalMethods.dart';
import 'Strings.dart';

//ignore: must_be_immutable
class ThemedTextField extends StatefulWidget {
  String? hintText;
  String? labelText;
  TextEditingController? controller;
  void Function()? onTap;
  bool isReadOnly = false;
  bool isAcceptNumbersOnly = false;
  bool isPasswordTextField = false;
  Widget? preFix;
  void Function(String)? onChanged;
  void Function(String)? onFieldSubmitted;
  FocusNode? currentFocusNode;
  FocusNode? nextFocusNode;
  FocusNode? previousFocusNode;
  Color? backgroundColor;
  Color? borderColor;
  TextInputType keyBoardType;
  Color textColor;
  Color hintTextColor;
  double fontSized;
  double hintFontSized;
  FontWeight fontWeight;
  FontWeight hintFontWeight;
  TextCapitalization? textCapitalization;
  String? Function(String?)? validator;

  ThemedTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.isReadOnly = false,
    this.isPasswordTextField = false,
    this.isAcceptNumbersOnly = false,
    this.preFix,
    this.currentFocusNode,
    this.nextFocusNode,
    this.previousFocusNode,
    this.textCapitalization,
    this.backgroundColor,
    this.borderColor,
    this.keyBoardType = TextInputType.text,
    this.textColor = colorGreyDarkText,
    this.hintTextColor = colorGreyDarkText,
    this.fontSized = 16,
    this.hintFontSized = 16,
    this.fontWeight = FontWeight.normal,
    this.hintFontWeight = FontWeight.normal,
    this.validator,
  });

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {
  bool isShowPassWord = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: widget.isReadOnly,
      onTap: widget.onTap,
      focusNode: widget.currentFocusNode,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      inputFormatters: [
        if (widget.isAcceptNumbersOnly)
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ],
      style: TextStyle(
        fontWeight: widget.fontWeight,
        fontSize: widget.fontSized,
        color: widget.textColor,
        // fontFamily: stringFontFamilyGibson
      ),
      validator: widget.validator,
      keyboardType: widget.isAcceptNumbersOnly
          ? TextInputType.number
          : widget.keyBoardType,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        if (value.isEmpty && widget.previousFocusNode != null) {
          widget.previousFocusNode!.requestFocus();
        }
        setState(() {});
      },
      onFieldSubmitted: (value) {
        if (widget.onFieldSubmitted != null) {
          widget.onFieldSubmitted!(value);
        }
        if (widget.nextFocusNode != null) {
          widget.nextFocusNode!.requestFocus();
        }
        setState(() {});
      },
      obscureText: isShowPassWord,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontWeight: widget.hintFontWeight,
          fontSize: widget.hintFontSized,
          color: widget.hintTextColor,
          // fontFamily: stringFontFamilyGibson,
        ),
        labelText: widget.labelText,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: spaceHorizontal * 1.2, vertical: spaceVertical),
        filled: widget.backgroundColor != null ? true : false,
        fillColor: widget.backgroundColor ?? Colors.white,
        prefixIcon: widget.preFix != null
            ? SizedBox(
                height: 30, width: 30, child: Center(child: widget.preFix))
            : null,
        prefixIconColor: colorGreyDarkText,
        suffixIcon: widget.isPasswordTextField
            ? InkWell(
                onTap: () {
                  setState(() {
                    isShowPassWord = !isShowPassWord;
                  });
                },
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: Center(
                    child: Icon(
                      isShowPassWord
                          ? CupertinoIcons.eye_solid
                          : CupertinoIcons.eye_slash_fill,
                    ),
                  ),
                ),
              )
            : null,
        suffixIconColor: colorGreyDarkText,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
          ),
          borderRadius: boxBorderRadius,
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
          ),
          borderRadius: boxBorderRadius,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
          ),
          borderRadius: boxBorderRadius,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: boxBorderRadius,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
          ),
          borderRadius: boxBorderRadius,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: boxBorderRadius,
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class ThemedDropDown extends StatelessWidget {
  String? defaultValue;
  String? hintText;
  Widget? preFix;
  List<String> dataString = [];
  bool isDisabled = false;
  void Function(String) onChanged;
  bool isFromRepeating;
  void Function()? onTap;

  ThemedDropDown({
    super.key,
    required this.dataString,
    required this.onChanged,
    this.defaultValue,
    this.onTap,
    this.hintText,
    this.preFix,
    this.isDisabled = false,
    this.isFromRepeating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colorGreyExtraLightBackGround,
        borderRadius: boxBorderRadius,
      ),
      padding: const EdgeInsets.only(right: spaceHorizontal),
      child: Row(
        children: [
          if (preFix != null)
            Container(
              width: 47,
              height: 47,
              alignment: Alignment.center,
              child: Center(
                child: preFix,
              ),
            ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: DropdownButton(
                value: defaultValue,
                menuMaxHeight: 300,
                isExpanded: true,
                iconEnabledColor: colorGreyExtraLightBackGround,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: colorGreyDarkText,
                  fontFamily: stringFontFamilyGibson,
                  overflow: TextOverflow.ellipsis,
                ),
                borderRadius: boxBorderRadius,
                icon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: colorGreyDarkText,
                ),
                underline: Container(),
                hint: Text(
                  hintText ?? "Select",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: stringFontFamilyGibson,
                    color: colorGreyDarkText,
                  ),
                ),
                items: dataString
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.toString(),
                        child: Text(
                          e.toString(),
                          style: const TextStyle(
                            color: colorGreyDarkText,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: stringFontFamilyGibson,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: true),
                onChanged: !isFromRepeating && !isDisabled
                    ? (String? value) {
                        if (value != null) {
                          onChanged(value);
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemedButton extends StatelessWidget {
  void Function()? onTap;
  String title;
  double fontSize = 20;
  bool isBordered = false;
  Color backGround = colorOrange;
  Color textColor = colorGreyDarkText;
  FontWeight fontWeight = FontWeight.w600;
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 12);

  ThemedButton({
    super.key,
    this.onTap,
    required this.title,
    this.isBordered = false,
    this.backGround = colorOrange,
    this.textColor = colorWhite,
    this.fontSize = 22,
    this.fontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: boxBorderRadius,
      color: isBordered ? colorWhite : backGround,
      elevation: isBordered ? 0 : 3,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: boxBorderRadius,
            border: isBordered
                ? Border.all(color: colorOrange, width: 2)
                : Border.all(color: backGround, width: 2),
            // boxShadow: boxShadow,
          ),
          child: Text(
            title,
            style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: fontSize,
                fontFamily: stringFontFamilyGibson),
          ),
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class ThemedSearchBar extends StatefulWidget {
  final TextEditingController controllerText;
  final String textHint;
  void Function(String)? onChanged;

  ThemedSearchBar(
      {super.key,
      required this.textHint,
      required this.controllerText,
      this.onChanged});

  @override
  State<ThemedSearchBar> createState() => _ThemedSearchBarState();
}

class _ThemedSearchBarState extends State<ThemedSearchBar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controllerText,
      style: const TextStyle(
          color: colorGreyDarkText,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: stringFontFamilyGibson),
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      decoration: InputDecoration(
        hintText: widget.textHint,
        hintStyle: const TextStyle(
          color: colorGreyExtraLightBackGround,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: stringFontFamilyGibson,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: colorGreyExtraLightBackGround,
        ),
        filled: true,
        fillColor: colorWhite,
        suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              widget.controllerText.text = "";
              closeKeyboard();
              setState(() {});
            }),
        border: OutlineInputBorder(
          borderRadius: boxBorderRadius,
          borderSide: const BorderSide(
            color: colorGreyExtraLightBackGround,
            width: 1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: boxBorderRadius,
          borderSide: const BorderSide(
            color: colorGreyExtraLightBackGround,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: boxBorderRadius,
          borderSide: const BorderSide(
            color: colorGreyExtraLightBackGround,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: boxBorderRadius,
          borderSide: const BorderSide(
            color: colorGreyExtraLightBackGround,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: boxBorderRadius,
          borderSide: const BorderSide(
            color: colorGreyExtraLightBackGround,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: boxBorderRadius,
          borderSide: const BorderSide(
            color: colorGreyExtraLightBackGround,
            width: 1,
          ),
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class ThemedText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  TextStyle? textStyle;
  int? maxLine;
  bool makeUnderline = false;

  ThemedText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color = colorGreyDarkText,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.textStyle,
    this.maxLine,
    this.makeUnderline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: maxLine != null ? TextOverflow.ellipsis : null,
      style: textStyle ??
          TextStyle(
            color: color,
            fontWeight: fontWeight,
            fontSize: fontSize,
            fontFamily: stringFontFamilyGibson,
            decoration: makeUnderline ? TextDecoration.underline : null,
          ),
    );
  }
}
