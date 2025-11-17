import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
// ... (Imports lainnya tetap sama)
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/widget/admin_summary_card.dart';
import 'package:tes_flutter/admin/widget/attendance_tracker_section.dart';
import 'package:tes_flutter/admin/widget/sales_chart_section.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart'; // Controller utama
import 'package:tes_flutter/database/controller/gmv/gmv_controller_extra.dart';
import 'package:tes_flutter/ui_page/format_money.dart';
import 'package:tes_flutter/ui_page/shimmer_page_loader.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';


// KAMI AKAN MENGGANTI INI MENJADI STATELESS DAN MENGGUNAKAN CONSUMER
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  // Karena kita tidak lagi menggunakan initState, kita tetap butuh fungsi fetch GMV
  Future<double> _loadTotalGmv(GmvControllerExtra controller) async {
    return await controller.getTotalGmv();
  }

  // --- Fungsi konversi data dari PayrollController ke format AttendanceTrackerSection ---
  List<Map<String, dynamic>> _mapPayrollDataToTracker(List<Map<String, dynamic>> payrollList) {
    // maxAbsenceCount (30) harus diakses sebagai konstanta global
    const int maxAbsenceCount = 30; 
    
    return payrollList.map((data) {
      final int totalUnpaidCounts = data['totalUnpaidCounts'] as int;
      double progress = totalUnpaidCounts / maxAbsenceCount;
      double progressValue = progress.clamp(0.0, 1.0);
      
      return {
        'userId': data['userId'],
        'userName': data['userName'], 
        'totalUnpaidCounts': totalUnpaidCounts,
        'progressValue': progressValue, // Nilai progres yang dibutuhkan AttendanceTrackerSection
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Akses controller untuk fungsi fetch GMV
    final gmvController = Provider.of<GmvControllerExtra>(context, listen: false);

    // Menggunakan FutureBuilder untuk data GMV (karena tidak real-time)
    return FutureBuilder<double>(
      future: _loadTotalGmv(gmvController),
      builder: (context, gmvSnapshot) {
        
        final totalGmv = gmvSnapshot.data ?? 0.0;
        final _isLoadingGmv = gmvSnapshot.connectionState == ConnectionState.waiting;
        
        final formattedGmv = MoneyFormatter.format(totalGmv);
        final profit = (totalGmv * 5) / 100;
        final formattedProfit = MoneyFormatter.format(profit);

        return BasePage(
          title: 'Dashboard',
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // area body - tittle page
                AnimatedFadeSlide(
                  delay: 0.1,
                  child: CustomTitle(text: "Dashboard"),
                ),
                const SizedBox(height: 16),

                // area body - Summary card
                AnimatedFadeSlide(
                  delay: 0.2,
                  child: _isLoadingGmv 
                      ? Column(
                          children: const [
                            SkeletonBox(),
                            SizedBox(height: 12),
                            SkeletonBox(),
                          ],
                        )
                      : AdminSummaryCards(
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

                // area body - absen tracker (MENGGUNAKAN CONSUMER UNTUK PAYROLL CONTROLLER)
                AnimatedFadeSlide(
                  delay: 0.5,
                  child: CustomSubtitle(text: "Absen tracker")
                ),
                
                // 🔥 CONSUMER UNTUK MENDENGARKAN DATA REAL-TIME DARI PAYROLLCONTROLLER
                AnimatedFadeSlide(
                  delay: 0.6,
                  child: Consumer<PayrollController>(
                    builder: (context, payrollController, child) {
                      
                      if (payrollController.isLoading) {
                        return const SkeletonBox(); // Tampilkan loading
                      }
                      
                      // Konversi data dari format Payroll ke format Attendance Tracker
                      final trackerData = _mapPayrollDataToTracker(payrollController.unpaidEmployeeList);

                      // Mengirim List Data Lengkap ke AttendanceTrackerSection
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
      }
    );
  }
}