
import '../../models/Country.dart';
import '../../models/Department.dart';
import '../../models/Neighborhood.dart';

abstract class ILocationService {
  Future<List<Country>> getAvailableCountries();
  Future<List<Department>> getDepartments(String countryName);
  Future<List<Neighborhood>> getNeighborhoods(String departmentName);
}
