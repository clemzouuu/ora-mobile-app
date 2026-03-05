import 'package:flutter/material.dart';

class StatisticDetailScreen extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const StatisticDetailScreen({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Center(
        child: Text(
          "$value $unit",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
