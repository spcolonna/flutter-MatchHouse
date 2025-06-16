import 'package:flutter/material.dart';

import '../widgets/NearbyHouseCard.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MatchHouse', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black, // Color del texto y los iconos del AppBar
      ),
      body: ListView( // ListView permite hacer scroll si el contenido vertical es muy largo.
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Cerca de Ti',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220, // Altura fija para la lista horizontal
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: 10, // Mostrará 10 casas de ejemplo
              itemBuilder: (context, index) {
                return const NearbyHouseCard();
              },
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Descubre tu Próximo Hogar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Aquí iría el widget de tarjetas deslizables
          // Puedes usar un paquete como 'flutter_card_swiper' para esto
          Container(
            height: 400,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16)
            ),
            child: const Text(
              'Aquí va el carrusel de tarjetas\npara hacer match',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
