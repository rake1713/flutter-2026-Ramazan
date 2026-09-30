import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  int sec = 0;
  Timer? timer;

  String get formattedTime {
    final min = (sec ~/ 60).toString().padLeft(2, '0');
    final secs = (sec % 60).toString().padLeft(2, '0');
    return '$min:$secs';
  }

  void startTimer() {
    if (timer != null) return;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        sec++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      sec = 0;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(onPressed: startTimer, child: const Text('Start')),
                OutlinedButton(onPressed: stopTimer, child: const Text('Stop')),
                OutlinedButton(
                  onPressed: resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
