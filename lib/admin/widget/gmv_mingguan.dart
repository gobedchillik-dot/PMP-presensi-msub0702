// lib/widgets/gmv/gmv_weekly_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GmvWeeklyCard extends StatelessWidget {
  final int mingguKe;
  final int total;
  final bool isUp;

  const GmvWeeklyCard({
    super.key,
    required this.mingguKe,
    required this.total,
    required this.isUp,
  });

  String formatMoney(int number) {
    if (number >= 1000000000) {
      final formatter = NumberFormat.compactCurrency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 1,
      );
      return formatter.format(number);
    }
    return "Rp ${number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => "${m[1]}.",
    )}";
  }

  @override
  Widget build(BuildContext context) {
    final Color color = isUp ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Minggu ke - $mingguKe",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                formatMoney(total),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}