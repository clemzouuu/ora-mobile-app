import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/statistics_services.dart';
import 'home_screen.dart';
import 'chest_input_screen.dart';
import 'temperature_screen.dart';
import 'heart_rate_screen.dart';
import 'movement_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService service = StatisticsService();
  final LiveHealthService liveService = LiveHealthService();

  Map<String, dynamic>? data;
  bool loading = true;

  // Valeurs en temps réel (MQTT)
  String liveTemperature = "-";
  String liveHeartRate = "-";
  String liveMovement = "-";
  String liveBust = "-";

  // Système de batching pour l'envoi en BDD
  Timer? _batchTimer;
  final List<double> _tempBuffer = [];
  final List<double> _heartBuffer = [];

  @override
  void initState() {
    super.initState();
    loadData(); // Charge les données de la BDD (PostgreSQL)
    initMqtt(); // Active l'écoute des capteurs en direct
    startBatchSystem();
  }

  // Récupération des statistiques persistantes (ex: Tour de poitrine)
  Future<void> loadData() async {
    final result = await service.fetchStatistics();
    setState(() {
      data = result;
      loading = false;
    });
  }

  // Connexion et écoute des flux MQTT
  Future<void> initMqtt() async {
    await liveService.connectMqtt();

    liveService.temperatureStream.listen((temp) {
      if (mounted) setState(() => liveTemperature = temp);
    });

    liveService.heartStream.listen((heart) {
      if (mounted) setState(() => liveHeartRate = heart);
    });

    liveService.movementStream.listen((movement) {
      if (mounted) setState(() => liveMovement = movement);
    });

    liveService.bustStream.listen((bust) {
      if (mounted) setState(() => liveBust = bust);
    });
  }

  void startBatchSystem() {
    // Accumulation des données toutes les minutes, envoi toutes les 5 min
    _batchTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      double? currentT = double.tryParse(liveTemperature);
      double? currentH = double.tryParse(liveHeartRate);

      if (currentT != null) _tempBuffer.add(currentT);
      if (currentH != null) _heartBuffer.add(currentH);

      if (_tempBuffer.length >= 5) {
        _sendBatch('temperature', List.from(_tempBuffer));
        _tempBuffer.clear();
      }

      if (_heartBuffer.length >= 5) {
        _sendBatch('cardiac', List.from(_heartBuffer));
        _heartBuffer.clear();
      }
    });
  }

  Future<void> _sendBatch(String type, List<double> values) async {
    try {
      final List<Map<String, dynamic>> payload = values
          .map((v) => {"type": type, "value": v.toStringAsFixed(2)})
          .toList();

      final response = await http.post(
        Uri.parse('http://localhost:3000/batch'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"measurements": payload}),
      );

      if (response.statusCode == 200) {
        debugPrint("Batch $type envoyé avec succès");
      }
    } catch (e) {
      debugPrint("Erreur lors de l'envoi du batch $type : $e");
    }
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    liveService.disconnect();
    super.dispose();
  }

  // Affiche la valeur provenant de la BDD (Utilisé pour le Tour de poitrine)
  Widget buildCard(String title, String keyName, String unit) {
    final rawValue = data?[keyName];
    String displayValue =
        (rawValue == null || rawValue.toString().trim().isEmpty)
        ? "à définir"
        : rawValue.toString();

    return _buildListTile(title, displayValue, unit, keyName: keyName);
  }

  // Affiche la valeur provenant du MQTT (Utilisé pour Temp, BPM, Accel)
  Widget buildLiveCard(String title, String value, String unit) {
    return _buildListTile(title, value, unit, isLive: true);
  }

  Widget _buildListTile(
    String title,
    String value,
    String unit, {
    bool isLive = false,
    String? keyName,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Row(
          children: [
            Text(title),
            if (isLive) ...[
              const SizedBox(width: 8),
              const Icon(Icons.circle, color: Colors.green, size: 12),
            ],
          ],
        ),
        trailing: Text(
          "$value $unit".trim(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: value == "à définir" ? Colors.orange : Colors.black,
          ),
        ),
        onTap: () {
          if (title == "Tour de poitrine") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChestInputScreen(
                  currentBust: liveBust,
                ), // On envoie l'ajustement MQTT au détail
              ),
            ).then((_) => loadData()); // Rafraîchit la BDD au retour
          } else if (title == "Température") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TemperatureScreen(currentTemp: value),
              ),
            );
          } else if (title == "Rythme cardiaque") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HeartRateScreen(currentHeartRate: value),
              ),
            );
          } else if (title == "Mouvements brusques") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovementScreen(movementValue: value),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildLiveCard("Température", liveTemperature, "°C"),
                  buildLiveCard("Rythme cardiaque", liveHeartRate, "bpm"),
                  buildLiveCard("Mouvements brusques", liveMovement, "m/s"),

                  // AFFICHAGE BDD : Pour voir la valeur fixe enregistrée
                  buildCard("Tour de poitrine", "tour_poitrine", "cm"),
                ],
              ),
            ),
    );
  }
}
