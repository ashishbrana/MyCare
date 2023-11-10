class ClientDocModel {
  String? name;
  String? createdon;

  ClientDocModel({this.name, this.createdon});

  ClientDocModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    createdon = json['createdon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['createdon'] = this.createdon;
    return data;
  }
}
