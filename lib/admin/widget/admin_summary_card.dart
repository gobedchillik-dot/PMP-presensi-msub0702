// lib/admin/widget/admin_summary_cards.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tes_flutter/admin/pages/gmv/index.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import 'stat_card.dart';

class AdminSummaryCards extends StatelessWidget {
  final String formattedGmv;
  final String formattedProfit;

  const AdminSummaryCards({
    super.key,
    required this.formattedGmv,
    required this.formattedProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCard(
          title: "Data GMV",
          subtitle: formattedGmv,
          color: Colors.amberAccent.shade400,
          icon: Iconsax.chart,
          onTap: () {
            Navigator.push(
              context,
              createRoute(const GmvIndexPage()),
            );
          },
        ),

        const SizedBox(height: 12),

        StatCard(
          title: "Est. Keuntungan",
          subtitle: formattedProfit,
          color: Colors.greenAccent.shade400,
          icon: Iconsax.money_4,
          onTap: () {
            // Arahkan ke halaman yang kamu mau
          },
        ),

        const SizedBox(height: 12),

        StatCard(
          title: "Validasi Kehadiran",
          subtitle: "1.234 data",
          color: Colors.blueAccent,
          icon: Iconsax.user_tick,
          onTap: () {
            // Halaman validasi kehadiran
          },
        ),
      ],
    );
  }
}
