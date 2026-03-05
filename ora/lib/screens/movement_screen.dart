import 'package:flutter/material.dart';
import '../services/statistics_services.dart';

class MovementScreen extends StatefulWidget {
  final String movementValue;

  const MovementScreen({super.key, required this.movementValue});

  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {
  final LiveHealthService liveService = LiveHealthService();
  late String currentMovement;

  @override
  void initState() {
    super.initState();
    currentMovement = widget.movementValue;
    _initMqttListener();
  }

  void _initMqttListener() {
    // Écoute le topic accel/abcd via ton service existant
    liveService.movementStream.listen((newData) {
      if (mounted) {
        setState(() {
          currentMovement = newData;
        });
      }
    });
  }

  // Logique : < 1 est OK, > 1 est un mouvement brusque
  Map<String, dynamic> getStatus(double val) {
    if (val > 1.0) {
      return {
        "color": Colors.red,
        "label": "MOUVEMENT BRUSQUE",
        "icon": Icons.warning_amber_rounded,
        "bg": Colors.red.withOpacity(0.1),
      };
    } else {
      return {
        "color": Colors.green,
        "label": "Mouvement Normal",
        "icon": Icons.check_circle_outline,
        "bg": Colors.green.withOpacity(0.1),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    double val = double.tryParse(currentMovement) ?? 0.0;
    final status = getStatus(val);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mouvements Brusques"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- CARRÉ LIVE (MQTT) ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Accélération\nLive",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    "${val.toStringAsFixed(2)} m/s",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: status['color'],
                    ),
                  ),
                ],
              ),
            ),

            // --- ZONE DE DIAGNOSTIC ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: status['bg'],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: status['color'], width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(status['icon'], size: 100, color: status['color']),
                    const SizedBox(height: 20),
                    Text(
                      status['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: status['color'],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Analyse de l'accéléromètre abcd",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}