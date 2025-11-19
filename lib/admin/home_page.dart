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
import 'package:tes_flutter/admin/widget/cashflow.dart';
import 'package:tes_flutter/admin/widget/cashflow_summary_card.dart';
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

                  // Cashflow Summary (realtime)
                  AnimatedFadeSlide(
                    delay: 0.7,
                    child: Consumer<CashflowController>(
                      builder: (_, cashflow, __) {
                        final cashIn =
                            MoneyFormatter.format(cashflow.cashIn);
                        final cashOut =
                            MoneyFormatter.format(cashflow.cashOut);
                        final netCash =
                            MoneyFormatter.format(cashflow.netCashflow);

                        return CashflowSummaryCard(
                          cashIn: cashIn,
                          cashOut: cashOut,
                          netCashflow: netCash,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Export PDF
                  AnimatedFadeSlide(
                    delay: 0.9,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final gmvController = context.read<GmvController>();
                          final cashflowController = context.read<CashflowController>();
                          final payrollController = context.read<PayrollController>();

                          final pdfList = <Map<String, dynamic>>[];

                          // GMV Mingguan
                          for (final w in gmvController.weeklySummary) {
                            pdfList.add({
                              'tanggal': w.dateRange,
                              'kategori': 'GMV Mingguan',
                              'nominal': w.total,
                              'tipe': 'IN',
                              'isPaid': true,
                            });
                          }

                          // Detail pengeluaran/gaji
                          if (cashflowController.pengeluaranController?.allExpenses != null) {
                            for (final e in cashflowController.pengeluaranController!.allExpenses) {
                              pdfList.add({
                                'tanggal': e.tanggal,
                                'kategori': e.kategori,
                                'nominal': e.nominal,
                                'tipe': 'OUT',
                                'isPaid': e.kategori.toLowerCase() == 'gaji' ? e.isPaid : true,
                              });
                            }
                          }

                          // Total pengeluaran
                          final totalOperational = cashflowController
                              .pengeluaranController?.allExpenses
                              .where((e) => e.kategori.toLowerCase() == 'operasional')
                              .fold<double>(0.0, (sum, e) => sum + e.nominal) ?? 0.0;

                          final totalOtherExpenses = cashflowController
                              .pengeluaranController?.allExpenses
                              .where((e) => e.kategori.toLowerCase() != 'operasional' &&
                                            e.kategori.toLowerCase() != 'gaji')
                              .fold<double>(0.0, (sum, e) => sum + e.nominal) ?? 0.0;

                          // Total gaji belum dibayar (pakai nominal sebenarnya)
                          final totalUnpaidSalary = payrollController.unpaidEmployeeList
                              .where((e) => e['isPaid'] == false)
                              .fold<double>(
                                0.0,
                                (sum, e) => sum + ((e['amountPaid'] ?? 0).toDouble()),
                              );
                          // Estimasi pemasukan = total GMV 5%
                          final estIncome = gmvController.weeklySummary
                              .fold<double>(0.0, (sum, item) => sum + item.total) * 0.05;

                          // Net profit = estIncome - (operasional + pengeluaran lain + gaji belum dibayar)
                          final netProfit = estIncome - (totalOperational + totalOtherExpenses + totalUnpaidSalary);

                          generateCashflowPdf(
                            nama: "Admin",
                            estIncome: estIncome,
                            totalOperational: totalOperational,
                            totalOtherExpenses: totalOtherExpenses,
                            netProfit: netProfit,
                            weeklySummary: gmvController.weeklySummary.map((w) => {
                              'mingguKe': w.mingguKe,
                              'total': w.total,
                              'isUp': w.isUp,
                            }).toList(),
                            cashflowList: pdfList,
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                        label: const Text(
                          "Cetak Cashflow (PDF)",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
