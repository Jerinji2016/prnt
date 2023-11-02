class UserProfile {
  final Map<String, dynamic> json;

  UserProfile(this.json);

  List get _permissions => json["permissions"];

  String get id => json["_id"];

  String get companyId => _permissions.first["company"]["_id"];

  String get revenueCenterId => (_permissions.first["revenueCenters"] as List).firstWhere(
        (element) => element["active"],
      )["_id"];

  String get fullName => "$firstName $lastName";

  String get firstName => json["firstName"];

  String get lastName => json["lastName"];

  String get email => json["email"];

  String get phone => json["phone"];
}
