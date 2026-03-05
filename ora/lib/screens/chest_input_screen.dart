// chest_input_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importez le package http
import 'dart:convert';

class ChestInputScreen extends StatefulWidget {
  const ChestInputScreen({super.key});

  @override
  State<ChestInputScreen> createState() => _ChestInputScreenState();
}

class _ChestInputScreenState extends State<ChestInputScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false; // Pour gérer l'état du bouton

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);

      final nouvelleTaille = _controller.text.trim();
      final url = Uri.parse(
        'https://helpother.fr/sizeBust/abcd/get',
      ); // URL HTTP

      try {
        // 1. Requête HTTP POST
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"sizeBust": nouvelleTaille}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 2. Sauvegarde locale uniquement si la requête a réussi
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('tour_poitrine', nouvelleTaille);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Taille synchronisée avec succès !"),
              ),
            );
            Navigator.pop(context);
          }
        } else {
          throw Exception("Erreur serveur : ${response.statusCode}");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur : Impossible d'envoyer la donnée ($e)"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le tour de poitrine")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Taille en cm",
                  border: OutlineInputBorder(),
                  suffixText: "cm",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Champ vide";
                  if (double.tryParse(value) == null) return "Nombre invalide";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _submit,
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Enregistrer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
