// lib/admin/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/widget/admin_summary_card.dart';
import 'package:tes_flutter/admin/widget/attendance_tracker_section.dart';
import 'package:tes_flutter/admin/widget/sales_chart_section.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
// ⚠️ Pastikan Anda mengimpor UnpaidSalaryModel di sini jika digunakan secara eksplisit,
// tetapi karena kita menggunakannya melalui Controller, cukup pastikan Controller sudah diimpor.

import 'package:tes_flutter/database/model/unpaid_gaji.dart'; // Impor Model
import 'package:tes_flutter/ui_page/format_money.dart';
import 'package:tes_flutter/ui_page/shimmer_page_loader.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/controller/CashflowController.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  // ⚠️ KOREKSI UTAMA: Mengubah tipe input dari List<Map> menjadi List<UnpaidSalaryModel>
  List<Map<String, dynamic>> _mapPayrollDataToTracker(
      List<UnpaidSalaryModel> payrollList) {
    const maxAbsence = 30;

    return payrollList.map((data) {
      // Mengakses properti langsung dari objek Model, bukan dari Map
      final totalUnpaid = data.totalUnpaidCounts; 
      final progress = (totalUnpaid / maxAbsence).clamp(0.0, 1.0);

      return {
        'idUser': data.idUser,
        'userName': data.userName, // Mengakses properti Model
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
            // MENTOR'S NOTE: Pastikan CashflowController.updateSources juga sudah
            // diupdate untuk menerima List<UnpaidSalaryModel> dari payroll.
            controller!.updateSources(gmv, pengeluaran, payroll);
            return controller;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final gmvController = context.watch<GmvController>();
          
          // Asumsi MoneyFormatter.format menerima double/num
          final formattedGmv = MoneyFormatter.format(
              gmvController.weeklySummary.fold<double>(
                  0.0, (sum, item) => sum + item.total));
                  
          // Perhitungan Profit (asumsi 5% margin)
          final formattedProfit = MoneyFormatter.format(
              gmvController.weeklySummary.fold<double>(
                      0.0, (sum, item) => sum + item.total) *
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
                  
                  AnimatedFadeSlide(
                    delay: 0.2,
                    child: 
                    AdminSummaryCards(
                      formattedGmv: formattedGmv,
                      formattedProfit: formattedProfit,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
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
                    
                    AnimatedFadeSlide(
                      delay: 0.5,
                      child: const CustomSubtitle(text: "Absen Tracker"),
                    ),
                    AnimatedFadeSlide(
                      delay: 0.6,
                      child: Consumer<PayrollController>(
                        builder: (_, payrollController, __) {
                          if (payrollController.isLoading) {
                            // Asumsi SkeletonBox adalah widget loader
                            return const SkeletonBox(); // Mengganti SkeletonBox dengan ShimmerPageLoader
                          }
                          // ⚠️ KOREKSI: Meneruskan List<UnpaidSalaryModel> ke fungsi mapping
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