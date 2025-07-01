import 'package:flutter/material.dart';

import '../../models/Country.dart';
import '../../models/Department.dart';
import '../../models/Neighborhood.dart';
import '../../models/SearchFilterModel.dart';
import '../../services/KtorLocationService.dart';
import '../../services/interfaces/ILocationService.dart';

class SearchFiltersTab extends StatefulWidget {
  const SearchFiltersTab({super.key});

  @override
  State<SearchFiltersTab> createState() => _SearchFiltersTabState();
}

class _SearchFiltersTabState extends State<SearchFiltersTab> {
  final ILocationService _locationService = KtorLocationService();
  late SearchFilterModel _filters;

  List<Country> _availableCountries = [];
  List<Department> _availableDepartments = [];
  List<Neighborhood> _availableNeighborhoods = [];

  Country? _selectedCountry;
  Department? _selectedDepartment;
  Neighborhood? _selectedNeighborhood;

  bool _isLoadingCountries = true;
  bool _isLoadingDepartments = false;
  bool _isLoadingNeighborhoods = false;


  @override
  void initState() {
    super.initState();
    _filters = SearchFilterModel();
    _loadInitialCountries();
  }

  Future<void> _loadInitialCountries() async {
    try {
      final countries = await _locationService.getAvailableCountries();
      if (mounted) {
        setState(() {
          _availableCountries = countries;
          // Seleccionamos Uruguay por defecto para disparar la carga de departamentos
          if (_availableCountries.isNotEmpty) {
            final uruguay = _availableCountries.firstWhere(
                    (c) => c.name == 'Uruguay', orElse: () => _availableCountries.first);
            _onCountrySelected(uruguay);
          }
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCountries = false);
      print("Error cargando países: $e");
    }
  }

  Future<void> _onCountrySelected(Country? country) async {
    if (country == null) return;

    setState(() {
      _selectedCountry = country;
      _filters.country = country.name;
      _isLoadingDepartments = true; // Mostramos spinner de carga

      _selectedDepartment = null;
      _filters.department = null;
      _availableDepartments = [];
      _selectedNeighborhood = null;
      _filters.neighborhood = null;
      _availableNeighborhoods = [];
    });

    try {
      final departments = await _locationService.getDepartments(country.name);
      if (mounted) {
        setState(() {
          _availableDepartments = departments;
          _isLoadingDepartments = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDepartments = false);
      print("Error cargando departamentos: $e");
    }
  }

  // --- NUEVO: Lógica para cuando se selecciona un departamento ---
  Future<void> _onDepartmentSelected(Department? department) async {
    if (department == null) return;

    setState(() {
      _selectedDepartment = department;
      _filters.department = department.name;
      _isLoadingNeighborhoods = true; // Mostramos spinner de carga

      _availableNeighborhoods = [];
      _selectedNeighborhood = null;
      _filters.neighborhood = null;
    });

    try {
      final neighborhoods = await _locationService.getNeighborhoods(department.name);
      if (mounted) {
        setState(() {
          _availableNeighborhoods = neighborhoods;
          _isLoadingNeighborhoods = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingNeighborhoods = false);
      print("Error cargando barrios: $e");
    }
  }

  void _activateFilters() {
    // Aquí es donde, en el futuro, guardarías los filtros y le avisarías al resto de la app
    print('--- FILTROS ACTIVADOS ---');
    print('País: ${_filters.country}');
    print('Departamento: ${_filters.department}');
    print('Barrio: ${_filters.neighborhood}');
    print('Precio: \$${_filters.minPrice.toInt()} - \$${_filters.maxPrice.toInt()}');
    print('Dormitorios: ${_filters.minBedrooms}+');
    print('Baños: ${_filters.minBathrooms}+');
    print('Área: ${_filters.minArea}+ m²');
    print('-------------------------');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros aplicados con éxito')),
    );
  }

  void _clearFilters() {
    setState(() {
      _filters = SearchFilterModel();
      _selectedCountry = _availableCountries.firstWhere((c) => c.name == 'Uruguay', orElse: () => _availableCountries.first);
      _availableDepartments = _selectedCountry?.departments ?? [];
      _selectedDepartment = null;
      _availableNeighborhoods = [];
      _selectedNeighborhood = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCountries) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Ubicación'),
          _buildDropdown<Country>(_selectedCountry, _availableCountries, _onCountrySelected, 'País', (c) => c.name),
          const Divider(),
          _isLoadingDepartments
              ? const Center(child: CircularProgressIndicator())
              : _buildDropdown<Department>(_selectedDepartment, _availableDepartments, _onDepartmentSelected, 'Departamento', (d) => d.name, enabled: _selectedCountry != null),
          const Divider(),
          _isLoadingNeighborhoods
              ? const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()))
              : _buildDropdown<Neighborhood>(_selectedNeighborhood, _availableNeighborhoods, (n) {
            setState(() {
              _selectedNeighborhood = n;
              _filters.neighborhood = n?.name;
            });
          }, 'Barrio', (n) => n.name, enabled: _selectedDepartment != null),
          const SizedBox(height: 24),

          _buildSectionTitle('Rango de Precio'),
          const SizedBox(height: 24),
          _buildSectionTitle('Características'),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Limpiar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _activateFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Activar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- WIDGETS DE AYUDA PARA CONSTRUIR LA UI ---

  Widget _buildDropdown<T>(T? currentValue, List<T> items, ValueChanged<T?> onChanged, String hint, String Function(T) itemText, {bool enabled = true}) {
    return DropdownButtonFormField<T>(
      value: currentValue,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(
          hint == 'País' ? Icons.public : (hint == 'Departamento' ? Icons.location_city : Icons.location_on_outlined),
          color: enabled ? Colors.black54 : Colors.grey.shade400,
        ),
      ),
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(itemText(value)),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCounter(String label, IconData icon, int currentValue, ValueChanged<int> onChanged) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: currentValue > 0 ? () => onChanged(currentValue - 1) : null,
          ),
          Text(currentValue.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(currentValue + 1),
          ),
        ],
      ),
    );
  }
}
