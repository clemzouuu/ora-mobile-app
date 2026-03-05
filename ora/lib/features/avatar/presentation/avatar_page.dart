import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  int avatarIndex = 0;
  final List<String> avatars = [
    'assets/avatar/avatar.glb',
    'assets/avatar/avatar.glb',
    'assets/avatar/avatar.glb',
  ];

  final List<String> modes = ["Mode normal", "Mode sport", "Mode nuit"];

  bool isEditing = false; // État édition
  int value = 0; // Valeur à modifier avec + et -

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Avatar 3D")),
      body: Column(
        children: [
          /// Titre entouré des boutons Valider / Annuler
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isEditing)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false; // Annuler
                      });
                    },
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
                    onPressed: () {
                      setState(() {
                        isEditing = false; // Valider
                      });
                    },
                    child: const Text("Valider"),
                  ),

                // bouton paramètres en mode normal
                if (!isEditing)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      setState(() {
                        isEditing = true; // passer en édition
                      });
                    },
                  ),
              ],
            ),
          ),

          /// Avatar avec flèches
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: ModelViewer(
                    key: ValueKey(avatars[avatarIndex]),
                    src: avatars[avatarIndex],
                    autoRotate: true,
                    cameraControls: true,
                    backgroundColor: Colors.white,
                  ),
                ),

                // flèche gauche
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

                // flèche droite
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

          /// Boutons + et - ou Activer selon l’état
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton "-"
              GestureDetector(
                onTap: () {
                  setState(() {
                    value--;
                  });
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 100,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "-",
                        style: TextStyle(
                          fontSize: 72, // beaucoup plus grand
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "$value",
                  style: const TextStyle(
                    fontSize: 56, // valeur aussi plus grande
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Bouton "+"
              GestureDetector(
                onTap: () {
                  setState(() {
                    value++;
                  });
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 100,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "+",
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
