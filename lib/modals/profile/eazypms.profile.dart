import '../../helpers/environment.dart';
import '../base_modal.dart';

class EazypmsProfile extends BaseModal {
  EazypmsProfile(super.json);

  EazypmsCompany get company => EazypmsCompany(json["company"]);
}

class EazypmsCompany extends BaseModal {
  EazypmsCompany(super.json);

  String get name => json["name"];

  String? get description => json['description'];

  Iterable<EazypmsRevenueCenter> get revenueCenters => List.from(json["revenueCenters"] ?? []).map(
        (e) => EazypmsRevenueCenter(e),
      );

  Iterable<EazypmsRevenueCenter> get nonPropertyRevenueCenters => revenueCenters.where(
        (rvc) => !["Company", "Property"].contains(rvc.objectType),
      );
}

class EazypmsRevenueCenter extends BaseModal {
  EazypmsRevenueCenter(super.json);

  String get name => json["name"];

  String get description => json["description"];

  String get objectType => json["objectType"];

  String get redisTopic => "${Environment.value}_eazypms_${id}_kot";
}
