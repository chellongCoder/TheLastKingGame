import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class ResourceBar extends StatefulWidget {
  final int value;
  final IconData icon;
  final Color color;
  final String label;

  const ResourceBar({
    super.key,
    required this.value,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  State<ResourceBar> createState() => _ResourceBarState();
}

class _ResourceBarState extends State<ResourceBar> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 500));
  }

  @override
  void didUpdateWidget(covariant ResourceBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value > oldWidget.value) {
        // Gain: Blast
        _confettiController.play();
      } else {
        // Loss: Maybe shake or something else? For now just blast smaller?
        // User asked for "like confetti", usually implies positive reinforcement or just visual feedback.
        // Let's play for any change but maybe different logic if desired.
        // For now, simple blast on any change.
        _confettiController.play();
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center, // Center confetti on the icon/bar
        clipBehavior: Clip.none, // Allow confetti to fly out
        children: [
          Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 28),
              const SizedBox(height: 4),
              Text(widget.label, style: const TextStyle(fontSize: 10)),
              SizedBox(
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.value / 100.0,
                    backgroundColor: widget.color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  ),
                ),
              ),
            ],
          ),
          // Confetti Widget
          Positioned(
             top: 0,
             child: ConfettiWidget(
               confettiController: _confettiController,
               blastDirection: -pi / 2, // Up
               maxBlastForce: 5,
               minBlastForce: 2,
               emissionFrequency: 0.5,
               numberOfParticles: 5, // Small burst
               gravity: 0.5,
               colors: [widget.color, Colors.white], // Use bar color
             ),
          ),
        ],
      ),
    );
  }
}
