import '../base_modal.dart';

class EazypmsProfile extends BaseModal {
  EazypmsProfile(super.json);

  EazypmsCompany get company => EazypmsCompany(json["company"]);
}

class EazypmsCompany extends BaseModal {
  EazypmsCompany(super.json);

  Iterable<EazypmsRevenueCenter> get revenueCenters => List.from(json["revenueCenters"] ?? []).map(
        (e) => EazypmsRevenueCenter(e),
      );
}

class EazypmsRevenueCenter extends BaseModal {
  EazypmsRevenueCenter(super.json);
}
