import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
  url: 'https://izcdejcmewhvldxcdvuf.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6Y2RlamNtZXdodmxkeGNkdnVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ2NTk0NDMsImV4cCI6MjExMDIzNTQ0M30.ia5MNZrux7BknNzSjfS2s_-0C0D0iAMZC-4Gn2DwdJI',
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

// ==========================================
// OUTILS D'AFFICHAGE
// ==========================================
String formatFcfa(num v) {
  final s = v.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '$buf F';
}

const List<Color> kAvatarColors = [
  AppColors.indigoMid,
  AppColors.sun,
  AppColors.millet,
];

// ==========================================
// ÉCRAN CHAUFFEURS : lit "drivers", écrit dans "rides"
// ==========================================
class ScreenDrivers extends StatefulWidget {
  const ScreenDrivers({super.key});

  @override
  State<ScreenDrivers> createState() => _ScreenDriversState();
}

class _ScreenDriversState extends State<ScreenDrivers> {
  List<Map<String, dynamic>> _drivers = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _selectedDriverIndex = 0;
  bool _isRideConfirmed = false;
  PaymentMethod _selectedPayment = kPaymentMethods[0];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await Supabase.instance.client
          .from('drivers')
          .select()
          .order('price_fcfa');
      if (!mounted) return;
      setState(() {
        _drivers = List<Map<String, dynamic>>.from(data);
        _selectedDriverIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les chauffeurs.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmRide() async {
    final driver = _drivers[_selectedDriverIndex];
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('rides').insert({
        'driver_id': driver['id'],
        'price_fcfa': driver['price_fcfa'],
        'payment_method': _selectedPayment.id,
      });
      if (!mounted) return;
      setState(() => _isRideConfirmed = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La course n'a pas pu être enregistrée.")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _meta(Map<String, dynamic> d) {
    final rating = (d['rating'] as num).toStringAsFixed(1);
    return '$rating ★ · ${d['eta_min']} min · ${d['vehicle_type']}';
  }

  String _label(Map<String, dynamic> d) =>
      d['verified'] == true ? '${d['name']} ✅' : '${d['name']}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: AppColors.sandLight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _drivers.isEmpty) {
      return Container(
        color: AppColors.sandLight,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'Aucun chauffeur disponible pour le moment.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.charcoal),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.sun),
                onPressed: _loadDrivers,
                child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final selectedDriver = _drivers[_selectedDriverIndex];
    final selectedColor = kAvatarColors[_selectedDriverIndex % kAvatarColors.length];

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
              'Course enregistrée !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
            ),
            const SizedBox(height: 8),
            Text(
              '${_label(selectedDriver)} arrive dans environ ${selectedDriver['eta_min']} minutes.',
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
                      CircleAvatar(radius: 20, backgroundColor: selectedColor),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_label(selectedDriver), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(_meta(selectedDriver), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        formatFcfa(selectedDriver['price_fcfa'] as num),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.millet, fontSize: 16),
                      ),
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
                        const SnackBar(content: Text('Retour à la liste des chauffeurs.')),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Retour', style: TextStyle(color: Colors.white)),
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
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: kAvatarColors[index % kAvatarColors.length],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_label(driver), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                            Text(_meta(driver), style: TextStyle(fontSize: 11, color: AppColors.charcoal.withAlpha(140))),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          formatFcfa(driver['price_fcfa'] as num),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
                        ),
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
              onPressed: _saving ? null : _confirmRide,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Confirmer la course (${formatFcfa(selectedDriver['price_fcfa'] as num)})',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ÉCRAN LOCATION : lit "vehicles", écrit dans "rentals"
// ==========================================
class ScreenRental extends StatefulWidget {
  const ScreenRental({super.key});

  @override
  State<ScreenRental> createState() => _ScreenRentalState();
}

class _ScreenRentalState extends State<ScreenRental> {
  List<Map<String, dynamic>> _vehicles = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _selectedIndex = 0;
  Map<String, dynamic>? _activeRental;
  PaymentMethod _selectedPayment = kPaymentMethods[1];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await Supabase.instance.client
          .from('vehicles')
          .select()
          .eq('available', true)
          .order('daily_price_fcfa');
      if (!mounted) return;
      setState(() {
        _vehicles = List<Map<String, dynamic>>.from(data);
        _selectedIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les véhicules.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _rent() async {
    final vehicle = _vehicles[_selectedIndex];
    setState(() => _saving = true);
    try {
      final res = await Supabase.instance.client
          .from('rentals')
          .insert({
            'vehicle_id': vehicle['id'],
            'amount_fcfa': vehicle['daily_price_fcfa'],
            'payment_method': _selectedPayment.id,
          })
          .select()
          .single();
      if (!mounted) return;
      setState(() => _activeRental = res);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La location n'a pas pu être enregistrée.")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: AppColors.sandLight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _vehicles.isEmpty) {
      return Container(
        color: AppColors.sandLight,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'Aucun véhicule disponible pour le moment.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.charcoal),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.sun),
                onPressed: _loadVehicles,
                child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final vehicle = _vehicles[_selectedIndex];

    if (_activeRental != null) {
      return Container(
        color: AppColors.sandLight,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 70, color: AppColors.millet),
            const SizedBox(height: 16),
            const Text(
              'Location enregistrée !',
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
              child: Text(
                '${_activeRental!['unlock_code']}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.sun, letterSpacing: 2),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Véhicule :'),
                      Text('${vehicle['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant :'),
                      Text(
                        formatFcfa(_activeRental!['amount_fcfa'] as num),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.millet),
                      ),
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
                onPressed: () => setState(() => _activeRental = null),
                child: const Text('Retour à la recherche', style: TextStyle(color: AppColors.indigoDeep)),
              ),
            ),
          ],
        ),
      );
    }

    final isMoto = vehicle['vehicle_type'] == 'Moto';

    return Container(
      color: AppColors.sandLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.indigoMid, AppColors.indigoDeep]),
            ),
            child: Center(
              child: Icon(
                isMoto ? Icons.two_wheeler : Icons.directions_car,
                size: 60,
                color: Colors.white54,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: List.generate(_vehicles.length, (i) {
                      return ChoiceChip(
                        label: Text('${_vehicles[i]['name']}'),
                        selected: i == _selectedIndex,
                        onSelected: (_) => setState(() => _selectedIndex = i),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${vehicle['name']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.indigoDeep),
                  ),
                  Text(
                    'Disponible · ${vehicle['location'] ?? ''}',
                    style: TextStyle(fontSize: 12, color: AppColors.charcoal.withAlpha(140)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.millet.withAlpha(23),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vehicle['gps_tracker'] == true ? '📍 Traceur GPS actif' : 'Sans traceur GPS',
                          style: const TextStyle(fontSize: 12, color: AppColors.charcoal),
                        ),
                        Text(
                          'Caution ${formatFcfa(vehicle['deposit_fcfa'] as num)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.millet),
                        ),
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
          ),
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
                onPressed: _saving ? null : _rent,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Louer pour 1 jour — ${formatFcfa(vehicle['daily_price_fcfa'] as num)}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

