import 'package:flutter/material.dart';
import '../models/House.dart';

class FavoritesPage extends StatelessWidget {
  final List<House> favoriteHouses;
  final Function(String houseId) onFavoriteToggle;

  const FavoritesPage({
    super.key,
    required this.favoriteHouses,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: favoriteHouses.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Usa el corazón ♥️ en el mapa o en la sección de Descubrir para guardar tus casas preferidas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: favoriteHouses.length,
        itemBuilder: (context, index) {
          final house = favoriteHouses[index];

          // --- NUEVO: WIDGET DINÁMICO PARA LA IMAGEN DE PORTADA ---
          Widget leadingImage;
          // Comprobamos si la lista de URLs de la casa tiene al menos una imagen.
          if (house.imageUrls.isNotEmpty) {
            // Si hay imágenes, mostramos la primera.
            leadingImage = SizedBox(
              width: 80, // Le damos un tamaño generoso
              height: 80,
              child: ClipRRect( // Para redondear las esquinas
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  house.imageUrls.first, // Usamos la primera imagen de la lista
                  fit: BoxFit.cover, // Para que la imagen cubra todo el espacio
                  // Muestra un spinner mientras la imagen carga
                  loadingBuilder: (context, child, progress) {
                    return progress == null ? child : const Center(child: CircularProgressIndicator());
                  },
                  // Muestra un ícono de error si la imagen falla al cargar
                  errorBuilder: (context, error, stack) {
                    return const Icon(Icons.broken_image_outlined, color: Colors.grey);
                  },
                ),
              ),
            );
          } else {
            // Si no hay imágenes, mostramos un placeholder.
            leadingImage = Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(Icons.house_siding, size: 40, color: Colors.grey),
            );
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              // --- Usamos nuestro widget de imagen dinámico aquí ---
              leading: leadingImage,
              title: Text(house.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('\$${house.price}'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                tooltip: 'Quitar de favoritos',
                onPressed: () => onFavoriteToggle(house.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
