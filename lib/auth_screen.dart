import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  // CORRECTION ICI : utilisation directe de required this.onLoginSuccess
  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A4A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gari.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8622C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin ? 'Connexion à votre compte' : 'Créer un compte Gari',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 32),

              if (!isLogin) ...[
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone (+227)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8622C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Déclenche le callback de connexion vers le main
                    widget.onLoginSuccess();
                  },
                  child: Text(
                    isLogin ? 'Se connecter' : 'S\'inscrire',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Pas encore de compte ? S\'inscrire'
                        : 'Déjà un compte ? Se connecter',
                    style: const TextStyle(color: Color(0xFFF0E4CC)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}