import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../services/auth_services.dart';
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

  // --- Logique de l'Avatar ---
  int avatarIndex = 0;
  final List<String> avatars = [
    'assets/avatar/avatar.glb',
    'assets/avatar/avatar.glb',
    'assets/avatar/avatar.glb',
  ];

  final List<String> modes = ["Mode normal", "Mode sport", "Mode nuit"];

  bool isEditing = false; // État édition
  int value = 0; // Valeur à modifier

  void nextAvatar() {
    setState(() {
      avatarIndex = (avatarIndex + 1) % avatars.length;
    });
  }

  void previousAvatar() {
    setState(() {
      avatarIndex = (avatarIndex - 1 + avatars.length) % avatars.length;
    });
  }

  void _navigate(BuildContext context, Widget page) {
    // On utilise push pour pouvoir revenir ou pushReplacement selon ton besoin
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ora"),
        centerTitle: true,
        // Burger menu à droite
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      // Drawer conservé de home_screen
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
                if (mounted) _navigate(context, const LoginScreen());
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          /// Titre et contrôles d'édition (Importé de AvatarPage)
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
                    onPressed: () => setState(() => isEditing = false),
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

          /// Visionneuse 3D (Importé de AvatarPage)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: ModelViewer(
                    key: ValueKey(avatars[avatarIndex]),
                    src: avatars[avatarIndex],
                    autoRotate: true,
                    cameraControls: true,
                    backgroundColor: Colors.white,
                  ),
                ),
                // Flèche gauche
                Positioned(
                  left: 20,
                  child: GestureDetector(
                    onTap: previousAvatar,
                    child: Opacity(
                      opacity: 0.25,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        child: const Icon(
                          Icons.arrow_left,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                // Flèche droite
                Positioned(
                  right: 20,
                  child: GestureDetector(
                    onTap: nextAvatar,
                    child: Opacity(
                      opacity: 0.25,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        child: const Icon(
                          Icons.arrow_right,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Actions du bas (Importé de AvatarPage)
          Padding(
            padding: const EdgeInsets.all(20),
            child: isEditing
                ? Row(
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => value++),
                        child: const Text("+"),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Action pour Activer
                      },
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
}
