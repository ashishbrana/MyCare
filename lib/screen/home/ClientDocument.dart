import 'package:flutter/material.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

class ClientDocument extends StatefulWidget {
  const ClientDocument({super.key});

  @override
  State<ClientDocument> createState() => _ClientDocumentState();
}

class _ClientDocumentState extends State<ClientDocument> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Client Document"),
      body: Container(),
    );
  }
}
