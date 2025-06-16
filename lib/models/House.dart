class House {
  final String id;
  final String title;
  final String address;
  final double price;
  final String imageUrl;
  final double distanceKm;

  House({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.imageUrl,
    required this.distanceKm,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      distanceKm: json['distanceKm'],
    );
  }
}
