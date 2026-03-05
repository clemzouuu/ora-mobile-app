import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../services/statistics_services.dart';

class ChestInputScreen extends StatefulWidget {
  final String currentBust; // Valeur initiale passée depuis StatisticsScreen
  const ChestInputScreen({super.key, required this.currentBust});

  @override
  State<ChestInputScreen> createState() => _ChestInputScreenState();
}

class _ChestInputScreenState extends State<ChestInputScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Utilisation de l'instance unique (Singleton) du service MQTT
  final LiveHealthService liveService = LiveHealthService();

  bool _isSending = false;
  List<dynamic> history = [];
  bool isLoading = true;
  late String liveAdjustment;

  @override
  void initState() {
    super.initState();
    // On initialise l'affichage avec la valeur reçue du menu précédent
    liveAdjustment = widget.currentBust;
    fetchHistory();
    _initMqttListener();
  }

  void _initMqttListener() {
    // Écoute en temps réel du flux bustStream défini dans ton service
    liveService.bustStream.listen((newData) {
      if (mounted) {
        setState(() {
          // Cette valeur correspondra à "0.56" ou "-10.0" selon tes captures
          liveAdjustment = newData;
        });
      }
    });
  }

  Future<void> fetchHistory() async {
    try {
      // Récupération de la valeur "fixe" enregistrée en base de données
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/measurements/type/sizeBustManual'),
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);
      final nouvelleTaille = _controller.text.trim();

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/sizeBust/manual'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"value": nouvelleTaille}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _controller.clear();
          fetchHistory(); // On rafraîchit l'historique et le graphique
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Taille de base mise à jour !")),
            );
          }
        }
      } catch (e) {
        debugPrint("Erreur envoi : $e");
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // On récupère la dernière valeur de la BDD (ex: 100 cm)
    final double dbValue = history.isNotEmpty
        ? double.parse(history.first['value'].toString())
        : 0.0;

    List<dynamic> chronoHistory = history.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Détail Tour de Poitrine")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- AFFICHAGE COMBINÉ BDD + MQTT ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Taille de base (BDD)",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "${dbValue.toStringAsFixed(0)} cm",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 30),
                        const Text(
                          "Ajustement actuel (MQTT Live)",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        // Affichage de la valeur live (ex: +0.56 ou +-10.0)
                        Text(
                          "+$liveAdjustment",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Formulaire pour modifier la valeur de base en BDD
                  Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Changer la base (cm)",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? "Vide" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isSending ? null : _submit,
                          child: _isSending
                              ? const CircularProgressIndicator()
                              : const Text("OK"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Historique des réglages",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chronoHistory.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                double.parse(e.value['value'].toString()),
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
