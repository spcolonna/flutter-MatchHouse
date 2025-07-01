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
}
