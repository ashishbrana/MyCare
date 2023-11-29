import 'package:flutter/services.dart';

class NoteDocModel {
  String? name;
  String? createdon;
  String? path;
  Uint8List? image;

  NoteDocModel({this.name, this.createdon, this.path});

  NoteDocModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    createdon = json['createdon'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['createdon'] = this.createdon;
    data['path'] = this.path;
    return data;
  }
}
