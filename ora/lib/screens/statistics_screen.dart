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
  String liveTemperature = "-";
  String liveHeartRate = "-";
  String liveMovement = "-"; // Initialisé pour le MQTT

  Timer? _batchTimer;
  final List<double> _tempBuffer = [];
  final List<double> _heartBuffer = [];

  @override
  void initState() {
    super.initState();
    loadData();
    initMqtt();
    startBatchSystem();
  }

  Future<void> loadData() async {
    final result = await service.fetchStatistics();
    setState(() {
      data = result;
      loading = false;
    });
  }

  Future<void> initMqtt() async {
    await liveService.connectMqtt();

    liveService.temperatureStream.listen((temp) {
      if (mounted) {
        setState(() {
          liveTemperature = temp;
        });
      }
    });

    liveService.heartStream.listen((heart) {
      if (mounted) {
        setState(() {
          liveHeartRate = heart;
        });
      }
    });

    // Écoute du flux de mouvements brusques
    liveService.movementStream.listen((movement) {
      if (mounted) {
        setState(() {
          liveMovement = movement;
        });
      }
    });
  }

  void startBatchSystem() {
    _batchTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      double? currentT = double.tryParse(liveTemperature);
      double? currentH = double.tryParse(liveHeartRate);

      if (currentT != null) _tempBuffer.add(currentT);
      if (currentH != null) _heartBuffer.add(currentH);

      debugPrint(
        "Batching: Temp count ${_tempBuffer.length}, BPM count ${_heartBuffer.length}",
      );

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

  Widget buildCard(String title, String keyName, String unit) {
    final rawValue = data?[keyName];
    String displayValue;
    String displayUnit = unit;

    if (rawValue == null || rawValue.toString().trim().isEmpty) {
      displayValue = "à définir";
      displayUnit = "";
    } else {
      displayValue = rawValue.toString();
    }

    return _buildListTile(title, displayValue, displayUnit, keyName: keyName);
  }

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
          if (keyName == "tour_poitrine") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChestInputScreen()),
            ).then((_) => loadData());
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
                  // Changement : On utilise buildLiveCard avec liveMovement
                  buildLiveCard("Mouvements brusques", liveMovement, "m/s"),
                  buildCard("Tour de poitrine", "tour_poitrine", "cm"),
                ],
              ),
            ),
    );
  }
}
