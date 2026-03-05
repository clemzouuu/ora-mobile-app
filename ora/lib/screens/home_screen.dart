import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../services/auth_services.dart';
import '../services/statistics_services.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  final liveService = LiveHealthService();
  final String idOfEmbedded = "abcd"; // ID utilisé pour les topics MQTT

  int avatarIndex = 0;
  final List<String> avatars = [
    'assets/avatar/avatar.glb',
    'assets/avatar/avatar.glb',
    'assets/avatar/avatar.glb',
  ];

  final List<String> modes = ["Mode normal", "Mode sport", "Mode nuit"];
  bool isEditing = false;
  int value = 0;

  @override
  void initState() {
    super.initState();
    liveService.connectMqtt(); // Connexion au broker helpother.fr
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // --- Logique MQTT : Activation des Modes ---
  void _handleActivation() {
    String topic = "";
    switch (avatarIndex) {
      case 0: // Mode Normal
        topic = "servo/normal/$idOfEmbedded";
        break;
      case 1: // Mode Sport (Pushup)
        topic = "servo/pushup/$idOfEmbedded";
        break;
      case 2: // Mode Nuit
        topic = "servo/night/$idOfEmbedded";
        break;
    }

    if (topic.isNotEmpty) {
      liveService.publishMessage(topic, "1"); // On publie la commande
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Activation : ${modes[avatarIndex]}")),
      );
    }
  }

  // --- Logique MQTT : Validation du Serrage (+/-) ---
  void _handleValidation() {
    String topic = "";
    if (value > 0) {
      topic = "servo/tighten/$idOfEmbedded";
    } else if (value < 0) {
      topic = "servo/loosen/$idOfEmbedded";
    }

    if (topic.isNotEmpty) {
      liveService.publishMessage(topic, value.abs().toString());
    }

    setState(() {
      isEditing = false;
      value = 0;
    });
  }

  void nextAvatar() =>
      setState(() => avatarIndex = (avatarIndex + 1) % avatars.length);
  void previousAvatar() => setState(
    () => avatarIndex = (avatarIndex - 1 + avatars.length) % avatars.length,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ora"),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

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
              leading: const Icon(Icons.home),
              title: const Text("Accueil"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Statistiques"),
              onTap: () {
                Navigator.pop(context);
                _navigate(context, const StatisticsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Paramètres"),
              onTap: () {
                Navigator.pop(context);
                _navigate(context, const SettingsScreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Déconnexion",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await authService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isEditing)
                  ElevatedButton(
                    onPressed: () => setState(() => isEditing = false),
                    child: const Text("Annuler"),
                  ),
                const SizedBox(width: 10),
                Text(
                  modes[avatarIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                if (isEditing)
                  ElevatedButton(
                    onPressed: _handleValidation,
                    child: const Text("Valider"),
                  ),
                if (!isEditing)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => setState(() => isEditing = true),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ModelViewer(
                  key: ValueKey(avatars[avatarIndex]),
                  src: avatars[avatarIndex],
                  autoRotate: true,
                  cameraControls: true,
                  backgroundColor: Colors.white,
                ),
                Positioned(
                  left: 20,
                  child: _arrowButton(Icons.arrow_left, previousAvatar),
                ),
                Positioned(
                  right: 20,
                  child: _arrowButton(Icons.arrow_right, nextAvatar),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: isEditing
                ? _buildEditingControls()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleActivation,
                      child: const Text(
                        "Activer",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 0.25,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black,
          child: Icon(icon, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildEditingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => value--),
          child: const Text("-"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "$value",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() => value++),
          child: const Text("+"),
        ),
      ],
    );
  }
}
