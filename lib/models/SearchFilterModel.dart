class SearchFilterModel {
  String? country;
  String? department;
  String? neighborhood;
  double minPrice;
  double maxPrice;
  int minBedrooms;
  int minBathrooms;
  int minArea;

  SearchFilterModel({
    this.country = 'Uruguay',
    this.department,
    this.neighborhood,
    this.minPrice = 0,
    this.maxPrice = 500000,
    this.minBedrooms = 0,
    this.minBathrooms = 0,
    this.minArea = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'department': department,
      'neighborhood': neighborhood,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minBedrooms': minBedrooms,
      'minBathrooms': minBathrooms,
      'minArea': minArea,
    };
  }

  factory SearchFilterModel.fromMap(Map<String, dynamic> map) {
    return SearchFilterModel(
      country: map['country'],
      department: map['department'],
      neighborhood: map['neighborhood'],
      minPrice: (map['minPrice'] as num?)?.toDouble() ?? 0,
      maxPrice: (map['maxPrice'] as num?)?.toDouble() ?? 500000,
      minBedrooms: map['minBedrooms'] as int? ?? 0,
      minBathrooms: map['minBathrooms'] as int? ?? 0,
      minArea: map['minArea'] as int? ?? 0,
    );
  }
}
