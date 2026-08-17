import 'package:flutter/material.dart';

// ==========================================
// CHARTE GRAPHIQUE & COULEURS GARI
// ==========================================
class AppColors {
  static const Color indigoDeep = Color(0xFF1E2A4A);
  static const Color indigoMid  = Color(0xFF2F4470);
  static const Color sand       = Color(0xFFF0E4CC);
  static const Color sandLight  = Color(0xFFF8F1E1);
  static const Color sun        = Color(0xFFE8622C);
  static const Color sunDark   = Color(0xFFC74F1E);
  static const Color millet    = Color(0xFF3F7A52);
  static const Color charcoal  = Color(0xFF211A14);
  static const Color white     = Color(0xFFFFFDF8);
}

// ==========================================
// ÉCRAN DE SÉLECTION DU SERVICE
// ==========================================
class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo / Titre
              const Text(
                'GARI',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900, // Corrigé de FontWeight.black
                  color: AppColors.indigoDeep,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Plateforme de transport & logistique',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.indigoMid.withAlpha(204),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              const Text(
                'Que souhaitez-vous faire aujourd\'hui ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Option 1 : Transport de Marchandises
              _buildServiceCard(
                context,
                title: 'Transport de Marchandises',
                subtitle: 'Envoyer des colis, du fret ou du matériel',
                icon: Icons.local_shipping_rounded,
                color: AppColors.indigoDeep,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Option Transport de Marchandises sélectionnée'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Option 2 : Covoiturage
              _buildServiceCard(
                context,
                title: 'Covoiturage Interurbain',
                subtitle: 'Réserver un trajet ou proposer des places',
                icon: Icons.directions_car_filled_rounded,
                color: AppColors.sun,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Option Covoiturage sélectionnée'),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}