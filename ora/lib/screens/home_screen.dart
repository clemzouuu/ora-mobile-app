import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ora"),
        centerTitle: true,

        // ✅ Burger menu à droite
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      // ✅ Drawer à droite
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Center(
                child: Text("Ora Menu", style: TextStyle(fontSize: 24)),
              ),
            ),

            ListTile(
              title: const Text("Accueil"),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              title: const Text("Statistiques"),
              onTap: () => _navigate(context, const StatisticsScreen()),
            ),

            ListTile(
              title: const Text("Paramètres"),
              onTap: () => _navigate(context, const SettingsScreen()),
            ),

            const Divider(),

            ListTile(
              title: const Text("Déconnexion"),
              onTap: () async {
                await authService.logout();
                _navigate(context, const LoginScreen());
              },
            ),
          ],
        ),
      ),

      body: const SizedBox(),
    );
  }
}
