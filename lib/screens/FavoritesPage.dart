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
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: favoriteHouses.isEmpty
          ? const Center(child: Text('Aún no has añadido ninguna casa a favoritos.'))
          : ListView.builder(
        itemCount: favoriteHouses.length,
        itemBuilder: (context, index) {
          final house = favoriteHouses[index];
          return ListTile(
            leading: const Icon(Icons.house, size: 40),
            title: Text(house.title),
            subtitle: Text('\$${house.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => onFavoriteToggle(house.id),
            ),
          );
        },
      ),
    );
  }
}
