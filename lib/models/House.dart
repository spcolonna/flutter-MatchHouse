
import 'package:latlong2/latlong.dart';

class House {
  final String id, title;
  final int price, bedrooms, bathrooms;
  final double area;
  final LatLng point;


  House({
    required this.id, required this.title, required this.price,
    required this.bedrooms, required this.bathrooms, required this.area,
    required this.point
  });

  factory House.fromJson(Map<String, dynamic> json) {
    final pointData = json['point'];
    return House(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      area: json['area'],
      point: LatLng(pointData['lat'], pointData['lon'])
    );
  }
}
