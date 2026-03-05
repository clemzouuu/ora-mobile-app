import 'package:flutter/material.dart';

class GlassTextContainer extends StatelessWidget {
  final Widget child;

  const GlassTextContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}