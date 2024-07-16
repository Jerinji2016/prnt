class BaseModal {
  final Map<String, dynamic> json;

  BaseModal(this.json);

  String get id => json["_id"];
}