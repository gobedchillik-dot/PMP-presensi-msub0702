// lib/admin/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/widget/admin_summary_card.dart';
import 'package:tes_flutter/admin/widget/attendance_tracker_section.dart';
import 'package:tes_flutter/admin/widget/sales_chart_section.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/ui_page/format_money.dart';
import 'package:tes_flutter/ui_page/shimmer_page_loader.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/controller/CashflowController.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  List<Map<String, dynamic>> _mapPayrollDataToTracker(
      List<Map<String, dynamic>> payrollList) {
    const maxAbsence = 30;

    return payrollList.map((data) {
      final totalUnpaid = data['totalUnpaidCounts'] as int? ?? 0;
      final progress = (totalUnpaid / maxAbsence).clamp(0.0, 1.0);

      return {
        'userId': data['userId'],
        'userName': data['userName'] ?? '—',
        'totalUnpaidCounts': totalUnpaid,
        'progressValue': progress,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GmvController()),
        ChangeNotifierProvider(create: (_) => PengeluaranController()),
        ChangeNotifierProvider(create: (_) => PayrollController()),
        ChangeNotifierProxyProvider3<
            GmvController,
            PengeluaranController,
            PayrollController,
            CashflowController>(
          create: (_) => CashflowController(),
          update: (context, gmv, pengeluaran, payroll, controller) {
            controller!.updateSources(gmv, pengeluaran, payroll);
            return controller;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final gmvController = context.watch<GmvController>();
          final formattedGmv = MoneyFormatter.format(
              gmvController.weeklySummary.fold<double>(
                  0.0, (sum, item) => sum + (item.total )));
          final formattedProfit = MoneyFormatter.format(
              gmvController.weeklySummary.fold<double>(
                      0.0, (sum, item) => sum + (item.total )) *
                  0.05);

          return BasePage(
            title: "Dashboard",
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedFadeSlide(
                    delay: 0.1,
                    child: CustomTitle(text: "Dashboard"),
                  ),
                  const SizedBox(height: 16),

                  // GMV Summary
                  AnimatedFadeSlide(
                    delay: 0.2,
                    child: AdminSummaryCards(
                      formattedGmv: formattedGmv,
                      formattedProfit: formattedProfit,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grafik GMV
                  AnimatedFadeSlide(
                    delay: 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CustomSubtitle(text: "Grafik GMV"),
                        CustomInfo(
                          text: "Periode : 1 November - 30 November 2025",
                        ),
                      ],
                    ),
                  ),
                  AnimatedFadeSlide(
                    delay: 0.4,
                    child: const SalesChartSection(),
                  ),
                  const SizedBox(height: 24),

                  // Absen Tracker
                  AnimatedFadeSlide(
                    delay: 0.5,
                    child: const CustomSubtitle(text: "Absen Tracker"),
                  ),
                  AnimatedFadeSlide(
                    delay: 0.6,
                    child: Consumer<PayrollController>(
                      builder: (_, payrollController, __) {
                        if (payrollController.isLoading) {
                          return const SkeletonBox();
                        }
                        final trackerData = _mapPayrollDataToTracker(
                            payrollController.unpaidEmployeeList);
                        return AttendanceTrackerSection(
                          employeeData: trackerData,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
