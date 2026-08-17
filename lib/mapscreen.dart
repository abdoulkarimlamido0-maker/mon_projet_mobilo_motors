import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../app_colors.dart';

class ScreenMapSearch extends StatefulWidget {
  const ScreenMapSearch({super.key});

  @override
  State<ScreenMapSearch> createState() => _ScreenMapSearchState();
}

class _ScreenMapSearchState extends State<ScreenMapSearch> {
  // Coordonnées de Niamey (Place de la Concertation / Centre)
  final LatLng niameyCenter = const LatLng(13.5127, 2.1132);
  String? selectedLandmark;

  final List<Map<String, dynamic>> landmarks = [
    {"name": "Grand Marché", "point": const LatLng(13.5150, 2.1160)},
    {"name": "Pharmacie Centrale", "point": const LatLng(13.5100, 2.1090)},
    {"name": "Aéroport Diori Hamani", "point": const LatLng(13.4815, 2.1836)},
    {"name": "Université Abdou Moumouni", "point": const LatLng(13.5011, 2.0880)},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. VRAIE CARTE INTERACTIVE (OpenStreetMap)
        FlutterMap(
          options: MapOptions(
            initialCenter: niameyCenter,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.gari.app',
            ),
            // Marqueurs des chauffeurs / repères
            MarkerLayer(
              markers: [
                // Repère de l'utilisateur
                Marker(
                  point: niameyCenter,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.my_location, color: AppColors.sun, size: 30),
                ),
                // Chauffeurs fictifs autour
                Marker(
                  point: const LatLng(13.5160, 2.1150),
                  width: 35,
                  height: 35,
                  child: const Icon(Icons.two_wheeler, color: AppColors.indigoDeep, size: 28),
                ),
                Marker(
                  point: const LatLng(13.5090, 2.1100),
                  width: 35,
                  height: 35,
                  child: const Icon(Icons.directions_car, color: AppColors.millet, size: 28),
                ),
              ],
            ),
          ],
        ),

        // 2. BARRE DE RECHERCHE DE REPÈRES (En haut)
        Positioned(
          top: 16, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.sun),
                    SizedBox(width: 10),
                    Text('Choisissez un repère (ex: Grand Marché)...'),
                  ],
                ),
                value: selectedLandmark,
                items: landmarks.map((lm) {
                  return DropdownMenuItem<String>(
                    value: lm["name"] as String,
                    child: Text(lm["name"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLandmark = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Destination choisie : $value'),
                      backgroundColor: AppColors.millet,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // 3. CARTE DE CONFIRMATION RAPIDE (En bas)
        if (selectedLandmark != null)
          Positioned(
            bottom: 20, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.indigoDeep,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.sun, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('REPÈRE SELECTIONNÉ', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        Text(
                          selectedLandmark!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.sun),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recherche d\'un chauffeur vers ce repère...')),
                      );
                    },
                    child: const Text('Commander', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}