import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://TON-PROJET.supabase.co',
    anonKey: 'TA_CLE_sb_publishable',
  );
  runApp(const MobiloMotorsInteractiveApp());
}

// ==========================================
// 1. APPLICATION & NAVIGATION PRINCIPALE
// ==========================================
class MobiloMotorsInteractiveApp extends StatelessWidget {
  const MobiloMotorsInteractiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return MaterialApp(
      title: 'Mobilo Motors — App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.indigoDeep,
        fontFamily: 'Roboto',
      ),
      home: StreamBuilder<AuthState>(
        stream: auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session ?? auth.currentSession;
          if (session != null) {
            return MainNavigationWrapper(
              onLogout: () => auth.signOut(),
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  final VoidCallback onLogout;
  const MainNavigationWrapper({super.key, required this.onLogout});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ScreenMapSearch(
        onSwitchToDrivers: () => _onTabTapped(1),
        onSwitchToRental: () => _onTabTapped(2),
      ),
      const ScreenDrivers(),
      const ScreenRental(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.indigoDeep,
        title: const Text(
          'Mobilo Motors.',
          style: TextStyle(color: AppColors.sun, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: widget.onLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.sun,
        unselectedItemColor: Colors.white54,
        backgroundColor: AppColors.indigoDeep,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Course'),
          BottomNavigationBarItem(icon: Icon(Icons.local_taxi), label: 'Chauffeurs'),
          BottomNavigationBarItem(icon: Icon(Icons.two_wheeler), label: 'Location'),
        ],
      ),
    );
  }
}

// ==========================================
// 2. CHARTE GRAPHIQUE MOBILO MOTORS
// ==========================================
class AppColors {
  static const Color indigoDeep = Color(0xFF1E2A4A);
  static const Color indigoMid  = Color(0xFF2F4470);
  static const Color sand       = Color(0xFFF0E4CC);
  static const Color sandLight  = Color(0xFFF8F1E1);
  static const Color sun        = Color(0xFFE8622C);
  static const Color sunDark    = Color(0xFFC74F1E);
  static const Color millet     = Color(0xFF3F7A52);
  static const Color charcoal   = Color(0xFF211A14);
  static const Color white      = Color(0xFFFFFDF8);
}

// ==========================================
// 3. SELECTION DU MOYEN DE PAIEMENT
// ==========================================
class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<PaymentMethod> kPaymentMethods = [
  PaymentMethod(id: 'cash', name: 'Espèces / Cash', icon: Icons.payments, color: AppColors.millet),
  PaymentMethod(id: 'airtel', name: 'Airtel Money', icon: Icons.phone_android, color: Colors.red),
  PaymentMethod(id: 'nita', name: 'Nita Transfert', icon: Icons.account_balance_wallet, color: Colors.amber),
  PaymentMethod(id: 'amana', name: 'Amana Express', icon: Icons.send_to_mobile, color: Colors.blue),
];

class PaymentSelectorTile extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final VoidCallback onTap;

  const PaymentSelectorTile({
    super.key,
    required this.selectedMethod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.indigoMid.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(selectedMethod.icon, color: selectedMethod.color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Paiement : ${selectedMethod.name}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.indigoDeep),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.indigoDeep),
          ],
        ),
      ),
    );
  }
}

void showPaymentModal(BuildContext context, PaymentMethod current, Function(PaymentMethod) onSelect) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir le mode de paiement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
            ),
            const SizedBox(height: 12),
            ...kPaymentMethods.map((method) => ListTile(
                  leading: Icon(method.icon, color: method.color),
                  title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: current.id == method.id ? const Icon(Icons.check_circle, color: AppColors.sun) : null,
                  onTap: () {
                    onSelect(method);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      );
    },
  );
}

// ==========================================
// 4. ÉCRANS ET COMPOSANTS INTERACTIFS
// ==========================================

// Écran Carte avec OpenStreetMap interactive
class ScreenMapSearch extends StatelessWidget {
  final VoidCallback onSwitchToDrivers;
  final VoidCallback onSwitchToRental;

  const ScreenMapSearch({
    super.key,
    required this.onSwitchToDrivers,
    required this.onSwitchToRental,
  });

  @override
  Widget build(BuildContext context) {
    const LatLng userPosition = LatLng(13.5115, 2.1254);

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: userPosition,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mobilomotors.app',
            ),
            MarkerLayer(
              markers: [
                const Marker(
                  point: userPosition,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.my_location, color: AppColors.sun, size: 30),
                ),
                Marker(
                  point: LatLng(userPosition.latitude + 0.005, userPosition.longitude + 0.003),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: AppColors.indigoDeep, size: 35),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 12, left: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: AppColors.white.withAlpha(230), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onSwitchToDrivers,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: AppColors.indigoDeep, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Course', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onSwitchToRental,
                    child: const Text('Location', textAlign: TextAlign.center, style: TextStyle(color: AppColors.indigoDeep, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12, left: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('DESTINATION (REPÈRE)', style: TextStyle(fontSize: 10, color: AppColors.sunDark, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Derrière la Pharmacie Centrale…', style: TextStyle(fontSize: 12, color: AppColors.charcoal, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.sun),
                    onPressed: onSwitchToDrivers,
                    child: const Text('Rechercher un chauffeur', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Écran Chauffeurs avec sélection de paiement et suivi
class ScreenDrivers extends StatefulWidget {
  const ScreenDrivers({super.key});

  @override
  State<ScreenDrivers> createState() => _ScreenDriversState();
}

class _ScreenDriversState extends State<ScreenDrivers> {
  int _selectedDriverIndex = 0;
  bool _isRideConfirmed = false;
  PaymentMethod _selectedPayment = kPaymentMethods[0];

  final List<Map<String, dynamic>> _drivers = [
    {'name': 'Boubacar S. ✅', 'meta': '4.9 ★ · 3 min · Moto', 'price': '800 F', 'color': AppColors.indigoMid, 'phone': '+227 90 00 11 22'},
    {'name': 'Halima I. ✅', 'meta': '4.8 ★ · 6 min · Voiture', 'price': '1500 F', 'color': AppColors.sun, 'phone': '+227 96 33 44 55'},
    {'name': 'Idi K. ✅', 'meta': '5.0 ★ · 8 min · Moto', 'price': '700 F', 'color': AppColors.millet, 'phone': '+227 92 66 77 88'},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDriver = _drivers[_selectedDriverIndex];

    if (_isRideConfirmed) {
      return Container(
        color: AppColors.sandLight,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_run, size: 60, color: AppColors.sun),
            const SizedBox(height: 16),
            const Text(
              'Chauffeur en route !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
            ),
            const SizedBox(height: 8),
            Text(
              '${selectedDriver['name']} arrive dans environ 3 minutes.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sand),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 20, backgroundColor: selectedDriver['color']),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedDriver['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(selectedDriver['meta'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      Text(selectedDriver['price'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.millet, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Paiement :', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Row(
                        children: [
                          Icon(_selectedPayment.icon, color: _selectedPayment.color, size: 16),
                          const SizedBox(width: 6),
                          Text(_selectedPayment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Appel vers ${selectedDriver['phone']}...')),
                      );
                    },
                    icon: const Icon(Icons.phone, color: AppColors.millet),
                    label: const Text('Appeler', style: TextStyle(color: AppColors.millet)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () {
                      setState(() => _isRideConfirmed = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course annulée.')),
                      );
                    },
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('Annuler', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.sandLight,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chauffeurs à proximité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.indigoDeep)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _drivers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final driver = _drivers[index];
                final isSelected = _selectedDriverIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDriverIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.sun : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 18, backgroundColor: driver['color']),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                            Text(driver['meta'], style: TextStyle(fontSize: 11, color: AppColors.charcoal.withAlpha(140))),
                          ],
                        ),
                        const Spacer(),
                        Text(driver['price'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.indigoDeep)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          PaymentSelectorTile(
            selectedMethod: _selectedPayment,
            onTap: () => showPaymentModal(context, _selectedPayment, (method) {
              setState(() => _selectedPayment = method);
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sun,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() => _isRideConfirmed = true);
              },
              child: Text('Confirmer la course (${selectedDriver['price']})', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// Écran Location interactif avec paiement Mobile Money
class ScreenRental extends StatefulWidget {
  const ScreenRental({super.key});

  @override
  State<ScreenRental> createState() => _ScreenRentalState();
}

class _ScreenRentalState extends State<ScreenRental> {
  bool _isRentalActive = false;
  PaymentMethod _selectedPayment = kPaymentMethods[1];

  @override
  Widget build(BuildContext context) {
    if (_isRentalActive) {
      return Container(
        color: AppColors.sandLight,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 70, color: AppColors.millet),
            const SizedBox(height: 16),
            const Text(
              'Location Activée !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
            ),
            const SizedBox(height: 8),
            const Text(
              'Présentez ce code de déverrouillage au point de retrait :',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.indigoDeep,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'MBL-8842',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.sun, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Véhicule :'),
                      Text('Moto Sanili 125', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Montant :'),
                      Text('5 000 F CFA', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.millet)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Paiement :'),
                      Row(
                        children: [
                          Icon(_selectedPayment.icon, color: _selectedPayment.color, size: 16),
                          const SizedBox(width: 4),
                          Text(_selectedPayment.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _isRentalActive = false);
                },
                child: const Text('Terminer / Retour à la recherche', style: TextStyle(color: AppColors.indigoDeep)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.sandLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.indigoMid, AppColors.indigoDeep]),
            ),
            child: const Center(
              child: Icon(Icons.two_wheeler, size: 60, color: Colors.white54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Moto Sanili 125', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.indigoDeep)),
                Text('Disponible · Quartier Plateau', style: TextStyle(fontSize: 12, color: AppColors.charcoal.withAlpha(140))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.millet.withAlpha(23), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📍 Traceur GPS actif', style: TextStyle(fontSize: 12, color: AppColors.charcoal)),
                      Text('Caution 50 000 F', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.millet)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PaymentSelectorTile(
                  selectedMethod: _selectedPayment,
                  onTap: () => showPaymentModal(context, _selectedPayment, (method) {
                    setState(() => _selectedPayment = method);
                  }),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sun,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() => _isRentalActive = true);
                },
                child: const Text('Louer pour 1 jour — 5 000 F', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
