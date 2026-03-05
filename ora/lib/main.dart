import 'package:flutter/material.dart';
import 'features/avatar/presentation/avatar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avatar App',
      home: const AvatarPage(),
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Voir Avatar"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AvatarPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}