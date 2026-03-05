import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Avatar 3D")),
      body: Center(
        child: ModelViewer(
          src: 'assets/avatar/avatar.glb',   // ton avatar
          autoRotate: true,                  // rotation automatique
          cameraControls: true,              // zoom / rotation par l'utilisateur
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}