import 'package:flutter/material.dart';
import '../services/auth_services.dart';  
import './home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _authService = AuthService();

  String? _message;
  bool _isSuccess = false;

  Future<void> _changePassword() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty) {
      setState(() {
        _message = "Veuillez remplir tous les champs";
        _isSuccess = false;
      });
      return;
    }

    final success = await _authService.updatePassword(oldPass, newPass);

    setState(() {
      if (success) {
        _message = "Mot de passe mis à jour avec succès !";
        _isSuccess = true;
        _oldPasswordController.clear();
        _newPasswordController.clear();
      } else {
        _message = "L'ancien mot de passe est incorrect";
        _isSuccess = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Cette méthode retire toutes les routes précédentes et affiche HomeScreen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Changer le mot de passe",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Ancien mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                style: TextStyle(color: _isSuccess ? Colors.green : Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                child: const Text("Valider le changement"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
