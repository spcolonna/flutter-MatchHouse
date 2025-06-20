import 'package:http/http.dart' as http;

import '../models/UserModel.dart';

abstract class IUserService {
  Future<UserModel> getUserProfile() {
    throw UnimplementedError();
  }
  Future<http.Response> createUserProfile(UserModel user);
  Future<void> addFavorite(String houseId);
}
