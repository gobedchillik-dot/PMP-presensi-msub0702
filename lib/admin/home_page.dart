import 'package:flutter/material.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/widget/admin_summary_card.dart';
import 'package:tes_flutter/admin/widget/attendance_tracker_section.dart';
import 'package:tes_flutter/admin/widget/sales_chart_section.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller_extra.dart';
import 'package:tes_flutter/ui_page/format_money.dart';
import 'package:tes_flutter/ui_page/shimmer_page_loader.dart';
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
    final total = await _gmvControllerExtra.getTotalGmv();
    setState(() {
      totalGmv = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedGmv = MoneyFormatter.format(totalGmv);
    final profit = (totalGmv * 5) / 100;
    final formattedProfit = MoneyFormatter.format(profit);

    return BasePage(
      title: 'Dashboard',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

//area body - tittle page
            AnimatedFadeSlide(
              delay: 0.1,
              child: CustomTitle(text: "Dashboard"),
            ),
            const SizedBox(height: 16),

//area body - Summary card
            AnimatedFadeSlide(
              delay: 0.2,
              child:totalGmv == 0 ? 
              Column(
                children: const [
                  SkeletonBox(),
                  SizedBox(height: 12),
                  SkeletonBox(),
                  SizedBox(height: 12),
                  SkeletonBox(),
                ],
              )
              : 
              AdminSummaryCards(
                formattedGmv: formattedGmv,
                formattedProfit: formattedProfit,
              ),
            ),
            const SizedBox(height: 24),

// area body - Grafik GMV
            AnimatedFadeSlide(
              delay: 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Grafik GMV"),
                  CustomInfo(text: "Periode : 1 November - 30 November 2025"),
                ],
              ),
            ),
            AnimatedFadeSlide(
              delay: 0.4,
              child: const SalesChartSection(),
            ),
            const SizedBox(height: 24),

//area body - absen tracker
            AnimatedFadeSlide(
              delay:0.5,
              child: CustomSubtitle(text: "Absen tracker")
            ),
            AnimatedFadeSlide(
              delay: 0.6,
              child: const AttendanceTrackerSection(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}