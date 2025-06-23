import 'package:http/http.dart' as http;

import '../models/House.dart';
import '../models/UserModel.dart';

abstract class IUserService {
  Future<UserModel> getUserProfile() {
    throw UnimplementedError();
  }
  Future<http.Response> createUserProfile(UserModel user);
  Future<void> addFavorite(String houseId);
  Future<List<House>> getFavoriteHouses();
  Future<void> removeFavorite(String houseId);

  Future<List<House>> getMyHouses();
  Future<void> createHouse(House house);
  Future<void> updateHouse(House house);
  Future<void> deleteHouse(String houseId);
}
