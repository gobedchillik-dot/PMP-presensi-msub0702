// lib/admin/widget/cashflow_summary_card.dart
import 'package:flutter/material.dart';

class CashflowSummaryCard extends StatelessWidget {
  final String cashIn;
  final String cashOut;
  final String netCashflow;

  const CashflowSummaryCard({
    super.key,
    required this.cashIn,
    required this.cashOut,
    required this.netCashflow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Cash In", cashIn, color: Colors.green),
            const SizedBox(height: 8),
            _buildRow("Cash Out", cashOut, color: Colors.red),
            const SizedBox(height: 8),
            _buildRow("Net Cashflow", netCashflow,
                color: netCashflow.startsWith('-') ? Colors.red : Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
