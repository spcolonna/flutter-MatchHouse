import 'package:flutter/material.dart';
import 'package:matchhouse_flutter/models/House.dart';

import '../services/IProfileService.dart';
import '../services/KtorUserService.dart';

class HouseInfoBottomSheet extends StatelessWidget {
  final House house;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const HouseInfoBottomSheet({
    super.key,
    required this.house,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Imagen de la Casa ---
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  "house.imageUrl",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Placeholder mientras carga la imagen
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  // Placeholder si la imagen falla
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.house_siding, size: 60, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                house.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${house.price.toString()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final IUserService userService = KtorUserService();

                        if(isFavorite){
                          try {
                            await userService.addFavorite(house.id);

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${house.title} añadido a favoritos!')),
                            );

                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        } else {
                          try {
                            await userService.removeFavorite(house.id);

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${house.title} eliminado de favoritos!')),
                            );

                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }

                        onFavoriteToggle();
                      },
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      label: Text(isFavorite ? 'Quitar Favorito' : 'Favorito'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isFavorite ? Colors.red : Colors.deepPurple,
                        side: BorderSide(color: isFavorite ? Colors.red : Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('Viendo detalles de la casa: ${house.id}');
                        Navigator.pop(context);
                        // TODO: Navegar a la pantalla de detalle de la casa
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Ver Casa'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
