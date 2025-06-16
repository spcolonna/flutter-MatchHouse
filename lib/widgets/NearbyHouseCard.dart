import 'package:flutter/material.dart';

class NearbyHouseCard extends StatelessWidget {
  const NearbyHouseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              color: Colors.deepPurple[100],
              child: const Center(child: Icon(Icons.house, color: Colors.white, size: 50)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$ 250,000', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Barrio Ejemplo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('a 1.2 km', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
