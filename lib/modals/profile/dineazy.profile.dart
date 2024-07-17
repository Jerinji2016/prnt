import '../base_modal.dart';

class DineazyProfile extends BaseModal {
  DineazyProfile(super.json);

  List get _permissions => json["permissions"];

  DineazyRevenueCenter get revenueCenter {
    final json = (_permissions.first["revenueCenters"] as List).firstWhere(
          (element) => element["active"],
    );
    return DineazyRevenueCenter(json);
  }

  String get fullName => "$firstName $lastName";

  String get firstName => json["firstName"];

  String get lastName => json["lastName"];

  String get email => json["email"];

  String get phone => json["phone"];

  String get redisTopic => "prod_dineazy_${revenueCenter.id}_kot";
}

class DineazyRevenueCenter extends BaseModal {
  DineazyRevenueCenter(super.json);

  String get companyId => json["_id"];

  String get name => json["name"];

  String get description => json["description"];

  Map<String, dynamic> get map => json;

  @override
  String toString() => "\n__________RESTAURANT________\n"
      "companyId : $companyId\n"
      "name: $name\n"
      "revenueCenterId : $id\n"
      "______________________";
}
