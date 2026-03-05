import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ora App',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFCED8E1),

        // Style de texte global
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF9D7B1A)),
          bodyMedium: TextStyle(color: Color(0xFF9D7B1A)),
          bodySmall: TextStyle(color: Color(0xFF9D7B1A)),
          headlineLarge: TextStyle(color: Color(0xFF9D7B1A)),
          headlineMedium: TextStyle(color: Color(0xFF9D7B1A)),
          headlineSmall: TextStyle(color: Color(0xFF9D7B1A)),
        ),

        // Style global des TextButtons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF9D7B1A), // couleur du texte du bouton
          ),
        ),

        // Style global des ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Color(0xFF9D7B1A), // texte
            backgroundColor: Colors.white,       // optionnel : couleur du bouton
          ),
        ),

        // Style global des OutlinedButtons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF9D7B1A), // texte
            side: BorderSide(color: Color(0xFF9D7B1A)), // contour
          ),
        ),
      ),
      home: WelcomePage(),
    );
  }
}