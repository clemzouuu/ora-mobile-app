import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Dans statistics_services.dart
class StatisticsService {
  Future<Map<String, dynamic>> fetchStatistics() async {
    try {
      // Appeler votre API Node.js au lieu de SharedPreferences
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/sizeBust/manual'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "tour_poitrine": data['value']
              .toString(), // Récupère le "100" de la BDD
        };
      }
    } catch (e) {
      debugPrint("Erreur de récupération BDD : $e");
    }

    // Retourne une valeur par défaut si l'API échoue
    return {"tour_poitrine": "à définir"};
  }
}

class LiveHealthService {
  MqttServerClient? client;

  // Controllers pour diffuser les données en temps réel
  final _tempController = StreamController<String>.broadcast();
  final _heartController = StreamController<String>.broadcast();
  final _movementController = StreamController<String>.broadcast();
  final _bustController = StreamController<String>.broadcast();

  // Flux (Streams) écoutés par l'interface utilisateur
  Stream<String> get temperatureStream => _tempController.stream;
  Stream<String> get heartStream => _heartController.stream;
  Stream<String> get movementStream => _movementController.stream;
  Stream<String> get bustStream => _bustController.stream;

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
      client!.subscribe('accel/abcd', MqttQos.atMostOnce);
      client!.subscribe('sizeBust/abcd', MqttQos.atMostOnce);

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
          else if (topic == 'accel/abcd') {
             if (data.containsKey('accel')) {
              _movementController.add(data['accel'].toString());
            } else {
               _movementController.add(payload);
            }
          }
         else if (topic == 'sizeBust/abcd') {
            // Print pour voir l'objet complet reçu
            print("Donnée MQTT reçue sur $topic : $data");

            if (data.containsKey('sizebust')) {
              print("Succès : Clé 'sizebust' trouvée -> ${data['sizebust']}");
              _bustController.add(data['sizebust'].toString());
            } else if (data.containsKey('sizeBust')) {
              print("Succès : Clé 'sizeBust' trouvée -> ${data['sizeBust']}");
              _bustController.add(data['sizeBust'].toString());
            } else {
              print(
                "Erreur : Le JSON a été reçu mais ne contient ni 'sizebust' ni 'sizeBust'.",
              );
            }
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
    _heartController.close(); 
    _movementController.close();
  }
}
