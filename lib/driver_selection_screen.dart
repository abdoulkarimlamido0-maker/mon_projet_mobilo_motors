import 'package:flutter/material.dart';
import 'app_colors.dart';

class DriverSelectionScreen extends StatefulWidget {
  const DriverSelectionScreen({super.key});

  @override
  State<DriverSelectionScreen> createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen> {
  int? selectedDriverIndex;

  List<Map<String, dynamic>> get drivers => [
        {
          "name": "Boubacar S. ✅",
          "meta": "4.9 ★ · 3 min · Moto Tricycle",
          "price": "800 F",
          "color": AppColors.indigoMid,
        },
        {
          "name": "Halima I. ✅",
          "meta": "4.8 ★ · 6 min · Voiture Taxi",
          "price": "1 500 F",
          "color": AppColors.sun,
        },
        {
          "name": "Idi K. ✅",
          "meta": "5.0 ★ · 8 min · Moto",
          "price": "700 F",
          "color": AppColors.millet,
        },
      ];

  void _confirmBooking() {
    if (selectedDriverIndex == null) return;
    final driver = drivers[selectedDriverIndex!];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.indigoDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirmation de la course',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Chauffeur: ${driver["name"]}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                'Tarif estimé: ${driver["price"]}',
                style: const TextStyle(
                    color: AppColors.sun,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('Moyen de paiement :',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: const [
                  Chip(
                      label: Text('Airtel Money'),
                      backgroundColor: AppColors.sand),
                  Chip(
                      label: Text('Zamani Cash'),
                      backgroundColor: AppColors.sand),
                  Chip(
                      label: Text('Espèces'),
                      backgroundColor: AppColors.sand),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.sun),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Course avec ${driver["name"]} confirmée ! Le chauffeur arrive.'),
                        backgroundColor: AppColors.millet,
                      ),
                    );
                  },
                  child: const Text('Payer et Demander',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sandLight,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chauffeurs à proximité',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.indigoDeep)),
          const SizedBox(height: 8),
          const Text('Cliquez sur un chauffeur pour le choisir :',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: drivers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final isSelected = selectedDriverIndex == index;
                final driver = drivers[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDriverIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.sun : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppColors.sun.withValues(alpha: 0.3),
                                  blurRadius: 8)
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 20, backgroundColor: driver["color"]),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver["name"],
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal)),
                            Text(driver["meta"],
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.charcoal
                                        .withValues(alpha: 0.6))),
                          ],
                        ),
                        const Spacer(),
                        Text(driver["price"],
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.indigoDeep)),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.check_circle,
                                color: AppColors.sun, size: 20),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedDriverIndex != null ? AppColors.sun : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: selectedDriverIndex != null ? _confirmBooking : null,
              child: const Text('Confirmer la course',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}