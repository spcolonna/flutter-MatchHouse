
import 'package:latlong2/latlong.dart';

class House {
  final String id, title;
  final int price, bedrooms, bathrooms;
  final double area;
  final LatLng point;
  final List<String> imageUrls;


  House({
    required this.id, required this.title, required this.price,
    required this.bedrooms, required this.bathrooms, required this.area,
    required this.point,
    this.imageUrls = const []
  });

  factory House.fromJson(Map<String, dynamic> json) {
    final pointData = json['point'];
    final imagesFromJson = json['imageUrls'] as List<dynamic>? ?? [];

    return House(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      area: json['area'],
      point: LatLng(pointData['lat'], pointData['lon']),
      imageUrls: List<String>.from(imagesFromJson)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'point': {
        'lat': point.latitude,
        'lon': point.longitude,
      },
      'imageUrls': imageUrls,
    };
  }
}
