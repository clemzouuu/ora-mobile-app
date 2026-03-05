import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/glass_text_container.dart';
import '../util/page_transition.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/marble_texture_welcome_screen.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                

                GlassTextContainer(
                  child: const Text(
                    'ORA',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9D7B1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                // Slogan
                GlassTextContainer(
                  child: const Text(
                    'Intime Renaissance Douceur',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9D7B1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
                Image.asset(
                  'assets/images/marble_texture_welcome_screen.jpg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                GlassTextContainer(
                  child: const Text(
                    'Appuyez sur le bouton pour commencer',
                    style: TextStyle(fontSize: 16, color: Color(0xFF9D7B1A)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF9D7B1A), // texte
                    backgroundColor: Colors.white, // bouton
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(FadeSlideRoute(page: const LoginScreen()));
                  },
                  child: const Text('Commencer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
