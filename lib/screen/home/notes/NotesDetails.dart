import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

import '../../../utils/ColorConstants.dart';
import '../../../utils/Constants.dart';
import '../../../utils/ThemedWidgets.dart';
import '../../../utils/WidgetMethods.dart';
import '../models/ProgressNoteModel.dart';

class ProgressNoteDetails extends StatefulWidget {
  final ProgressNoteModel model;

  const ProgressNoteDetails({super.key, required this.model});

  @override
  State<ProgressNoteDetails> createState() => _ProgressNoteDetailsState();
}

class _ProgressNoteDetailsState extends State<ProgressNoteDetails> {
  final TextEditingController _serviceType = TextEditingController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _disscription = TextEditingController();
  final TextEditingController _assesment_scale = TextEditingController();
  final TextEditingController _assesment_comment = TextEditingController();

  final SignatureController _sign = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.grey,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _serviceType.text = DateFormat("dd-MM-yyyy").format(
          DateTime.fromMillisecondsSinceEpoch(
                  int.parse(widget.model.noteDate!
                      .replaceAll("/Date(", "")
                      .replaceAll(")/", "")),
                  isUtc: false)
              .add(
            Duration(hours: 5, minutes: 30),
          ),
        ) ??
        "";

    _subject.text = widget.model.subject ?? "";

    _disscription.text = widget.model.description ?? "";
    _assesment_scale.text = widget.model.assessmentScale ?? "";
    _assesment_comment.text = widget.model.assessmentComment ?? "";


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Progress Notes Detail"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: spaceVertical * 1.5, horizontal: spaceHorizontal * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThemedText(
                text:
                    "Service Schedule Client ${widget.model.serviceName ?? ""}",
                color: colorFontColor,
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Note Writer : ${widget.model.createdByName ?? ""}",
                color: colorFontColor,
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Note Date(dd-mm-yyyy)*",
                color: colorFontColor,
                fontSize: 18,
              ),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: false,
                  labelTextColor: colorBlack,
                  controller: _serviceType,
                ),
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Subject*",
                color: colorFontColor,
                fontSize: 18,
              ),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: false,
                  labelTextColor: colorBlack,
                  controller: _subject,
                ),
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Description*",
                color: colorFontColor,
                fontSize: 18,
              ),
              ThemedTextField(
                padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                minLine: 4,
                maxLine: 4,
                borderColor: colorGreyBorderD3,
                labelTextColor: colorBlack,
                backgroundColor: colorWhite,
                isReadOnly: false,
                controller: _disscription,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Assessment Scale*",
                color: colorFontColor,
                fontSize: 18,
              ),
              SizedBox(
                height: textFiledHeight,
                child: ThemedTextField(
                  padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                  borderColor: colorGreyBorderD3,
                  backgroundColor: colorWhite,
                  isReadOnly: false,
                  controller: _assesment_scale,
                ),
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Assessment Comments*",
                color: colorFontColor,
                fontSize: 18,
              ),
              ThemedTextField(
                padding: EdgeInsets.symmetric(horizontal: spaceHorizontal),
                borderColor: colorGreyBorderD3,
                backgroundColor: colorWhite,
                isReadOnly: false,
                minLine: 3,
                maxLine: 3,
                controller: _assesment_comment,
              ),
              const SizedBox(height: 10),
              ThemedText(
                text: "Client Signature",
                color: colorFontColor,
                fontSize: 18,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color:colorGreyBorderD3),

                ),
                child: Signature(
                  backgroundColor: Colors.white,
                  controller: _sign,
                  width: 300,
                  height: 180,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
