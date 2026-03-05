import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  Future<Map<String, dynamic>> fetchStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    // Récupération de la valeur stockée localement par ChestInputScreen
    final tourPoitrine = prefs.getString('tour_poitrine');

    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "mouvements_brusques": 12,
      "tour_poitrine": tourPoitrine, // Retourne la valeur réelle ou null
    };
  }
}

class LiveHealthService {
  MqttServerClient? client;

  // Controllers pour diffuser les données en temps réel
  final _tempController = StreamController<String>.broadcast();
  final _heartController = StreamController<String>.broadcast();

  // Flux (Streams) écoutés par l'interface utilisateur
  Stream<String> get temperatureStream => _tempController.stream;
  Stream<String> get heartStream => _heartController.stream;

  Future<void> connectMqtt() async {
    client = MqttServerClient(
      'helpother.fr',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    client!.port = 1883;
    client!.logging(on: false);
    client!.keepAlivePeriod = 20;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
          'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        )
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } catch (e) {
      print('Erreur de connexion MQTT: $e');
      client!.disconnect();
      return;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT Connecté');

      // Souscription aux deux topics identifiés sur le broker
      client!.subscribe('temperature/abcd', MqttQos.atMostOnce);
      client!.subscribe('cardiac/abcd', MqttQos.atMostOnce);

      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final topic = c[0].topic; // Récupération du topic d'origine
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        try {
          final data = jsonDecode(payload);

          // Filtrage et distribution des données selon le topic
          if (topic == 'temperature/abcd' && data.containsKey('temp')) {
            _tempController.add(data['temp'].toString());
          } else if (topic == 'cardiac/abcd' && data.containsKey('cardiac')) {
            _heartController.add(data['cardiac'].toString());
          }
        } catch (e) {
          print("Erreur de décodage JSON: $e");
        }
      });
    } else {
      client!.disconnect();
    }
  }

  // Envoi de message vers le broker (utilisé pour le tour de poitrine)
  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    client?.disconnect();
    _tempController.close();
    _heartController.close(); // Fermeture des deux flux
  }
}
