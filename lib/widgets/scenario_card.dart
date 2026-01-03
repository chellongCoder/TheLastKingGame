import 'package:flutter/material.dart';
import '../models/scenario.dart';

class ScenarioCard extends StatelessWidget {
  final Scenario scenario;

  const ScenarioCard({super.key, required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             // Placeholder for Image
             Container(
               height: 150,
               width: 150,
               decoration: BoxDecoration(
                 color: Colors.grey.shade200,
                 borderRadius: BorderRadius.circular(12),
               ),
               child: const Icon(Icons.castle, size: 64, color: Colors.brown),
             ),
             const SizedBox(height: 32),
             Text(
               scenario.text,
               textAlign: TextAlign.center,
               style: const TextStyle(
                 fontSize: 22,
                 fontWeight: FontWeight.bold,
                 fontFamily: 'Serif', // Fallback
               ),
             ),
          ],
        ),
      ),
      ),
    );
  }
}
