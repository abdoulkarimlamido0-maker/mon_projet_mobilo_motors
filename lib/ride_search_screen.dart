import 'package:flutter/material.dart';

// ==========================================
// 1. CHARTE GRAPHIQUE GARI
// ==========================================
class AppColors {
  static const Color indigoDeep = Color(0xFF1E2A4A);
  static const Color indigoMid  = Color(0xFF2F4470);
  static const Color sand       = Color(0xFFF0E4CC);
  static const Color sandLight  = Color(0xFFF8F1E1);
  static const Color sun        = Color(0xFFE8622C);
  static const Color charcoal   = Color(0xFF211A14);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.sandLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.indigoDeep,
        primary: AppColors.indigoDeep,
        secondary: AppColors.sun,
        surface: AppColors.sandLight,
      ),
      fontFamily: 'Roboto',
    );
  }
}

// ==========================================
// 2. MODÈLE DE DONNÉES (TRAJET)
// ==========================================
class Ride {
  final String driverName;
  final String driverRating;
  final String departureCity;
  final String arrivalCity;
  final String departureTime;
  final String estimatedDuration;
  final int availableSeats;
  final int price;

  Ride({
    required this.driverName,
    required this.driverRating,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.estimatedDuration,
    required this.availableSeats,
    required this.price,
  });
}

// ==========================================
// 3. POINT D'ENTRÉE DE L'APPLICATION
// ==========================================
void main() {
  runApp(const GariApp());
}

class GariApp extends StatelessWidget {
  const GariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gari Covoiturage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const RideSearchScreen(),
    );
  }
}

// ==========================================
// 4. ÉCRAN RECHERCHE DE COVOITURAGE
// ==========================================
class RideSearchScreen extends StatefulWidget {
  const RideSearchScreen({super.key});

  @override
  State<RideSearchScreen> createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  final TextEditingController _departureController = TextEditingController(text: 'Niamey');
  final TextEditingController _arrivalController = TextEditingController(text: 'Dosso');
  DateTime _selectedDate = DateTime.now();

  final List<Ride> _mockRides = [
    Ride(
      driverName: 'Ibrahim K.',
      driverRating: '4.8',
      departureCity: 'Niamey (Grand Marché)',
      arrivalCity: 'Dosso (Gare)',
      departureTime: '07:30',
      estimatedDuration: '2h 15m',
      availableSeats: 3,
      price: 3500,
    ),
    Ride(
      driverName: 'Aïchatou M.',
      driverRating: '4.9',
      departureCity: 'Niamey (Echangeur)',
      arrivalCity: 'Dosso (Centre)',
      departureTime: '10:00',
      estimatedDuration: '2h 00m',
      availableSeats: 1,
      price: 4000,
    ),
    Ride(
      driverName: 'Moussa S.',
      driverRating: '4.6',
      departureCity: 'Niamey (Rond-point 6e)',
      arrivalCity: 'Dosso (Entrée)',
      departureTime: '14:30',
      estimatedDuration: '2h 20m',
      availableSeats: 4,
      price: 3000,
    ),
  ];

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Covoiturage Interurbain', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.indigoDeep,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRE DE RECHERCHE
            Container(
              color: AppColors.indigoDeep,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildSearchField(
                    controller: _departureController,
                    hint: 'Ville de départ',
                    icon: Icons.my_location_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildSearchField(
                    controller: _arrivalController,
                    hint: 'Ville d\'arrivée',
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, color: AppColors.indigoMid, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.charcoal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recherche mise à jour')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sun,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Icon(Icons.search_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LISTE DES RÉSULTATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_mockRides.length} trajets disponibles',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                  ),
                  const Icon(Icons.tune_rounded, color: AppColors.indigoMid),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _mockRides.length,
              itemBuilder: (context, index) {
                final ride = _mockRides[index];
                return _buildRideCard(ride);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.indigoMid),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CHAUFFEUR & PRIX
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.indigoMid.withAlpha(30),
                  child: Text(
                    ride.driverName[0],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.driverName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        Text(' ${ride.driverRating}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${ride.price} FCFA',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.sun),
                ),
              ],
            ),
            const Divider(height: 24),

            // ITINÉRAIRE
            Row(
              children: [
                Column(
                  children: [
                    Text(ride.departureTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(ride.estimatedDuration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                const Column(
                  children: [
                    Icon(Icons.circle, size: 10, color: AppColors.indigoMid),
                    SizedBox(height: 18, child: VerticalDivider(thickness: 1.5, color: Colors.grey)),
                    Icon(Icons.location_on, size: 14, color: AppColors.sun),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.departureCity, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 12),
                      Text(ride.arrivalCity, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // PLACES REMAINING & BOUTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ride.availableSeats} place(s) disponible(s)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Réservation demandée auprès de ${ride.driverName}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigoDeep,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Réserver', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}