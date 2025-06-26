import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:matchhouse_flutter/models/House.dart';
import 'package:matchhouse_flutter/screens/tabs/myHousesSubScreens/MapPickerPage.dart';
import 'package:matchhouse_flutter/services/IProfileService.dart'; // Importamos la interfaz
import 'package:matchhouse_flutter/services/KtorUserService.dart'; // y la implementación

class AddEditHousePage extends StatefulWidget {
  final House? house;

  const AddEditHousePage({super.key, this.house});

  @override
  State<AddEditHousePage> createState() => _AddEditHousePageState();
}

class _AddEditHousePageState extends State<AddEditHousePage> {
  final _formKey = GlobalKey<FormState>();
  final IUserService _userService = KtorUserService();
  bool _isSaving = false;

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _areaController;

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.house?.title ?? '');
    _priceController = TextEditingController(text: widget.house?.price.toString() ?? '');
    _bedroomsController = TextEditingController(text: widget.house?.bedrooms.toString() ?? '');
    _bathroomsController = TextEditingController(text: widget.house?.bathrooms.toString() ?? '');
    _areaController = TextEditingController(text: widget.house?.area.toString() ?? '');
    _selectedLocation = widget.house?.point;
  }

  void _pickLocationOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapPickerPage(initialLocation: _selectedLocation),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una ubicación en el mapa.')),
        );
        return;
      }

      setState(() { _isSaving = true; });

      try {
        final houseData = House(
          id: widget.house?.id ?? '',
          title: _titleController.text.trim(),
          price: int.tryParse(_priceController.text) ?? 0,
          bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
          bathrooms: int.tryParse(_bathroomsController.text) ?? 0,
          area: double.tryParse(_areaController.text) ?? 0.0,
          point: _selectedLocation!,
          imageUrls: widget.house?.imageUrls ?? [],
        );

        if (widget.house == null) {
          await _userService.createHouse(houseData);
        } else {
          await _userService.updateHouse(houseData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Propiedad guardada con éxito!')),
          );
          Navigator.of(context).pop(true);
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isSaving = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.house == null ? 'Agregar Casa' : 'Editar Casa'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(onPressed: _submitForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título *'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            TextFormField(controller: _bedroomsController, decoration: const InputDecoration(labelText: 'Dormitorios *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            TextFormField(controller: _bathroomsController, decoration: const InputDecoration(labelText: 'Baños *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            TextFormField(controller: _areaController, decoration: const InputDecoration(labelText: 'Área (m²) *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 20),
            const Text('Ubicación *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedLocation == null
                          ? 'Ninguna ubicación seleccionada'
                          : 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(color: _selectedLocation == null ? Colors.grey : Colors.black),
                    ),
                  ),
                  ElevatedButton(onPressed: _pickLocationOnMap, child: const Text('Elegir en Mapa'))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
