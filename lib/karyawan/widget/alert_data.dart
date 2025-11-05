import 'package:flutter/material.dart';

class AlertDataWidget extends StatelessWidget {
  final VoidCallback onCompletePressed;
  final VoidCallback onSkipPressed;

  const AlertDataWidget({
    super.key,
    required this.onCompletePressed,
    required this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Data Belum Lengkap',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Ups, sepertinya data dirimu belum dilengkapi.\n'
        'Silakan lengkapi data terlebih dahulu agar sistem dapat berjalan dengan baik.',
        style: TextStyle(fontSize: 14),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: onSkipPressed,
          child: const Text('Lewati'),
        ),
        ElevatedButton(
          onPressed: onCompletePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Lengkapi Data'),
        ),
      ],
    );
  }
}
