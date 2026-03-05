import 'package:flutter/material.dart';
import '../services/statistics_services.dart';
import 'statistic_detail_screen.dart';
import 'home_screen.dart';
import 'chest_input_screen.dart';

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
  String liveHeartRate = "-"; // Nouvelle variable pour le flux en direct

  @override
  void initState() {
    super.initState();
    loadData();
    initMqtt();
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

    // Écoute de la température
    liveService.temperatureStream.listen((temp) {
      if (mounted) {
        setState(() {
          liveTemperature = temp;
        });
      }
    });

    // Écoute du rythme cardiaque en temps réel
    liveService.heartStream.listen((heart) {
      if (mounted) {
        setState(() {
          liveHeartRate = heart;
        });
      }
    });
  }

  @override
  void dispose() {
    liveService.disconnect();
    super.dispose();
  }

  // Builder pour les données statiques ou persistantes (ex: Tour de poitrine)
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

  // Builder pour les données MQTT en direct
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
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatisticDetailScreen(
                  title: title,
                  value: value,
                  unit: unit,
                ),
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
                  // Données en direct (MQTT)
                  buildLiveCard("Température", liveTemperature, "°C"),
                  buildLiveCard("Rythme cardiaque", liveHeartRate, "bpm"),

                  // Données statiques / locales
                  buildCard(
                    "Mouvements brusques",
                    "mouvements_brusques",
                    "m/s",
                  ),
                  buildCard("Tour de poitrine", "tour_poitrine", "cm"),
                ],
              ),
            ),
    );
  }
}
