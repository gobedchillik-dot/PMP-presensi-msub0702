// lib/admin/pages/admin_home_page.dart (Atau path yang sesuai)

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/widget/admin_summary_card.dart';
import 'package:tes_flutter/admin/widget/attendance_tracker_section.dart';
import 'package:tes_flutter/admin/widget/sales_chart_section.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller_extra.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';


class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  final GmvControllerExtra _gmvControllerExtra = GmvControllerExtra(); 
  double totalGmv = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadTotalGmv();
  }

  Future<void> _loadTotalGmv() async {
    // Asumsi ini memuat data GMV dan menyimpan totalnya
    final total = await _gmvControllerExtra.getTotalGmv(); 
    setState(() {
      totalGmv = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    // **Logika Bisnis & Formatting tetap di sini**
    // Karena data totalGmv adalah state milik AdminHomePage, ia harus dihitung di sini.
    final formattedGmv = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalGmv);

    final profit = (totalGmv * 5) / 100; // Contoh kalkulasi profit 5%
    final formattedProfit = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(profit);

    return BasePage(
      title: 'Dashboard',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header (Tinggal untuk judul) =====
            AnimatedFadeSlide(
              delay: 0.1,
              beginY: 0.3,
              child:CustomTitle(text: "Dashboard")
            ),
            const SizedBox(height: 16),
            
            AdminSummaryCards(
              formattedGmv: formattedGmv,
              formattedProfit: formattedProfit,
            ),
            
            const SizedBox(height: 24),
            
            const SalesChartSection(),
            
            const SizedBox(height: 24),
            
            const AttendanceTrackerSection(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}