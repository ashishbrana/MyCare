import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  DateTime serviceTypeDateTime = DateTime.now();
  String _assesmentScale = "1";
  File? imageFile;
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
    serviceTypeDateTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(widget.model.noteDate!
                .replaceAll("/Date(", "")
                .replaceAll(")/", "")),
            isUtc: false)
        .add(
      const Duration(hours: 5, minutes: 30),
    );
    _serviceType.text = DateFormat("dd-MM-yyyy").format(
      serviceTypeDateTime,
    );

    _subject.text = widget.model.subject ?? "";

    _disscription.text = widget.model.description ?? "";
    _assesmentScale = widget.model.assessmentScale ?? "";
    _assesment_comment.text = widget.model.assessmentComment ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorLiteBlue,
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
                  isReadOnly: true,
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: serviceTypeDateTime,
                            firstDate: DateTime(serviceTypeDateTime.year - 23),
                            lastDate: DateTime(serviceTypeDateTime.year + 23))
                        .then((value) {
                      if (value != null) {
                        setState(() {
                          serviceTypeDateTime = value;
                          _serviceType.text = DateFormat("dd-MM-yyyy").format(
                            serviceTypeDateTime,
                          );
                        });
                      }
                    });
                  },
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
              ThemedDropDown(
                defaultValue: _assesmentScale,
                dataString: const [
                  "0",
                  "1",
                  "2",
                  "3",
                  "4",
                  "5",
                  "6",
                  "7",
                  "8",
                  "9",
                  "10",
                ],
                onChanged: (s) {
                  setState(() {
                    _assesmentScale = s;
                  });
                },
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
                  border: Border.all(color: colorGreyBorderD3),
                ),
                child: Signature(
                  backgroundColor: Colors.white,
                  controller: _sign,
                  width: 300,
                  height: 180,
                ),
              ),
              const SizedBox(height: spaceVertical),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    height: textFiledHeight,
                    child: ThemedButton(
                      padding: EdgeInsets.zero,
                      title: "Clear",
                      fontSize: 12,
                      onTap: () {
                        _sign.clear();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spaceVertical),
              SizedBox(
                height: textFiledHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Capture Image From Camera",
                        fontSize: 12,
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              print(image.path);
                              imageFile = File(image.path);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: spaceHorizontal),
                    SizedBox(
                      width: 100,
                      child: ThemedButton(
                        padding: EdgeInsets.zero,
                        title: "Refresh",
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: spaceVertical),
              if (imageFile != null)
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Image.file(imageFile!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
