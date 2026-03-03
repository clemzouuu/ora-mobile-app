import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

class OraApp extends StatelessWidget {
  const OraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ora',
      theme: ThemeData(fontFamily: 'Coroy'),
      home: const LoginScreen(),
    );
  }
}
