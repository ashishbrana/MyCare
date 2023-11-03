import 'package:flutter/material.dart';

class ConfirmedTabScreen extends StatefulWidget {
  const ConfirmedTabScreen({super.key});

  @override
  State<ConfirmedTabScreen> createState() => _ConfirmedTabScreenState();
}

class _ConfirmedTabScreenState extends State<ConfirmedTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile();
        },
      ),
    );
  }
}
