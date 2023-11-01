class UserProfile {
  final Map<String, dynamic> _json;

  UserProfile(this._json);

  List get _permissions => _json["permissions"];

  String get id => _json["_id"];

  String get companyId => _permissions.first["company"]["_id"];

  String get rvcId => (_permissions.first["revenueCenters"] as List).firstWhere(
        (element) => element["active"],
      )["_id"];

  String get fullName => "$firstName $lastName";

  String get firstName => _json["firstName"];

  String get lastName => _json["lastName"];

  String get email => _json["email"];

  String get phone => _json["phone"];
}
