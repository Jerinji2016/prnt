class Restaurant {
  final Map<String, dynamic> json;

  /// Create new restaurant object from API data
  Restaurant(this.json);

  String get companyId => json["_id"];

  String get revenueCenterId => json["revenueCenterId"];

  String get name => json["name"];

  String get description => json["description"];

  Map<String, dynamic> get map => json;

  @override
  String toString() => "\n__________RESTAURANT________\n"
      "companyId : $companyId\n"
      "name: $name\n"
      "revenueCenterId : $revenueCenterId\n"
      "______________________";
}
