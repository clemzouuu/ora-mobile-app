import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import nécessaire pour accéder au LoginScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ora App',
      // L'application affiche désormais le LoginScreen au démarrage
      home: LoginScreen(), 
    );
  }
}