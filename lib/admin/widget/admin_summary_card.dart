// lib/admin/widget/admin_summary_cards.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tes_flutter/admin/pages/gmv/index.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import 'stat_card.dart'; // Import StatCard yang baru dipisah

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
        // StatCard GMV (Delay: 0.2s)
        AnimatedFadeSlide(
          delay: 0.2,
          child: StatCard(
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
        ),
        const SizedBox(height: 12),

        // StatCard Est. Keuntungan (Delay: 0.3s)
        AnimatedFadeSlide(
          delay: 0.3,
          child: StatCard(
            title: "Est. Keuntungan",
            subtitle: formattedProfit,
            color: Colors.greenAccent.shade400,
            icon: Iconsax.money_4,
            onTap: () {
              // ... Navigasi ke GmvIndexPage
            },
          ),
        ),
        const SizedBox(height: 12),

        // StatCard Validasi Kehadiran (Delay: 0.4s)
        AnimatedFadeSlide(
          delay: 0.4,
          child: const StatCard(
            title: "Validasi Kehadiran",
            subtitle: "1.234 data",
            color: Colors.blueAccent,
            icon: Iconsax.user_tick,
          ),
        ),
      ],
    );
  }
}