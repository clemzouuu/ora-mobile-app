import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Ora - Accueil"), centerTitle: true),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await authService.logout();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text("Déconnexion"),
        ),
      ),
    );
  }
}
