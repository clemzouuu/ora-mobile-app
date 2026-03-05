import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HeartRateScreen extends StatefulWidget {
  final String currentHeartRate; // Valeur live provenant du MQTT
  const HeartRateScreen({super.key, required this.currentHeartRate});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  List<dynamic> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      // Route spécifique pour le rythme cardiaque
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/measurements/type/cardiac'),
      );
      if (response.statusCode == 200) {
        setState(() {
          history = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur API : $e");
      setState(() => isLoading = false);
    }
  }

  // Diagnostic pour le rythme cardiaque (BPM)
  Map<String, dynamic> getStatus(double bpm) {
    if (bpm < 60.0) {
      return {"color": Colors.blue, "label": "Pouls lent", "icon": Icons.speed};
    } else if (bpm >= 60.0 && bpm <= 100.0) {
      return {
        "color": Colors.green,
        "label": "Rythme normal",
        "icon": Icons.favorite,
      };
    } else {
      return {
        "color": Colors.red,
        "label": "Pouls élevé",
        "icon": Icons.favorite_border,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Données de l'historique (Base de données)
    final bool hasData = history.isNotEmpty;
    final double dbLatestValue = hasData
        ? double.parse(history.first['value'].toString())
        : 0.0;

    // 2. Donnée actuelle (MQTT Live)
    final double liveValue =
        double.tryParse(widget.currentHeartRate) ?? dbLatestValue;

    String latestTime = "--:--";
    if (hasData) {
      DateTime date = DateTime.parse(history.first['created_at']).toLocal();
      latestTime = DateFormat('HH:mm:ss').format(date);
    }

    final status = getStatus(dbLatestValue);
    List<dynamic> chronoHistory = history.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rythme Cardiaque"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- CARRÉ RYTHME CARDIAQUE ACTUEL (MQTT LIVE) ---
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Rythme Live",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.sensors,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "MQTT Connecté",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          "${liveValue.toStringAsFixed(0)} BPM",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: getStatus(liveValue)['color'],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- SECTION : DERNIER ENREGISTREMENT (DB) ---
                  const Text(
                    "DERNIER ENREGISTREMENT (DB)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: status['color'].withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: status['color'].withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Relevé à $latestTime",
                          style: TextStyle(
                            color: status['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${dbLatestValue.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.w900,
                            color: status['color'],
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          "BPM",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: status['color'],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              status['icon'],
                              color: status['color'],
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              status['label'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: status['color'],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SECTION : GRAPHIQUE D'ÉVOLUTION ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Historique des pulsations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  AspectRatio(
                    aspectRatio: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 &&
                                      index < chronoHistory.length) {
                                    DateTime date = DateTime.parse(
                                      chronoHistory[index]['created_at'],
                                    ).toLocal();
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 10,
                                      child: Transform.rotate(
                                        angle: -0.6,
                                        child: Text(
                                          DateFormat('HH:mm').format(date),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                              left: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chronoHistory.asMap().entries.map((e) {
                                return FlSpot(
                                  e.key.toDouble(),
                                  double.parse(e.value['value'].toString()),
                                );
                              }).toList(),
                              isCurved: false, // Plus propre pour les BPM
                              color: status['color'],
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: status['color'].withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
