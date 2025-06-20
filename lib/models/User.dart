
import '../enums/UserRole.dart';

class User {
  final String uid;
  final String email;
  final UserRole role;

  String? displayName;
  String? phoneNumber;

  String? agencyName;
  String? licenseNumber;

  User({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.phoneNumber,
    this.agencyName,
    this.licenseNumber,
  });

  // Constructor factory para crear un User desde un mapa (ej: datos de Firestore)
  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      uid: documentId,
      email: data['email'] ?? '',
      role: (data['role'] == 'agency') ? UserRole.agency : UserRole.person,
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      agencyName: data['agencyName'],
      licenseNumber: data['licenseNumber'],
    );
  }

  // Método para convertir el objeto User a un mapa para guardarlo
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role == UserRole.agency ? 'agency' : 'person',
      if (displayName != null) 'displayName': displayName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (agencyName != null) 'agencyName': agencyName,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
    };
  }
}
