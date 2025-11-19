import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tes_flutter/admin/pages/keuangan/add.dart';
import 'package:tes_flutter/admin/pages/keuangan/edit.dart';
import 'package:tes_flutter/admin/widget/cashflow.dart';
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/employee_salary_card.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/controller/CashflowController.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/admin/widget/kartu_pengeluaran.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/utils/route_generator.dart';

import '../../base_page.dart';
import '../../home_page.dart';

class KeuanganIndexPage extends StatefulWidget {
  const KeuanganIndexPage({super.key});

  @override
  State<KeuanganIndexPage> createState() => _KeuanganIndexPageState();
}

class _KeuanganIndexPageState extends State<KeuanganIndexPage> {
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 1,
  );

  String formatMoney(double number) {
    if (number.abs() >= 1000000) {
      return _compactFormatter.format(number);
    }
    return _currencyFormatter.format(number).replaceAll(',', '.');
  }

  double calculateProfit(double gmvTotal) {
    const double profitPercentage = 0.05;
    return gmvTotal * profitPercentage;
  }

  Widget _buildSummaryCard({
    required double totalAmount,
    required bool isUp,
    required String title,
  }) {
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
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                formatMoney(totalAmount),
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

  Widget _buildWeeklyCardRow(List<dynamic> data, int index, bool isProfit) {
    if (data.length > index) {
      final summary = data[index];
      // Peringatan Mentor: Menggunakan 'as double'/'as int' pada List<dynamic>
      // berisiko runtime error jika tipe data berubah. Lebih baik gunakan Model
      // Class yang terdefinisi dengan baik.
      final double totalAmount = summary.total as double;
      final int mingguKe = summary.mingguKe as int;
      final bool isUp = summary.isUp as bool;

      final amount = isProfit ? calculateProfit(totalAmount) : totalAmount;
      final title = "Minggu ke - $mingguKe (${isProfit ? 'Profit' : 'GMV'})";

      return Expanded(
        child: _buildSummaryCard(
          totalAmount: amount,
          isUp: isUp,
          title: title,
        ),
      );
    }
    return const Expanded(child: SizedBox.shrink());
  }

  // =============================================
  // === HELPER: Data Aggregation for PDF (Refactored)
  // =============================================
  List<Map<String, dynamic>> _prepareCashflowPdfData({
    required GmvController gmvController,
    required CashflowController cashflowController,
    required PayrollController payrollController,
  }) {
    final pdfList = <Map<String, dynamic>>[];

    // 1. GMV/Income (IN)
    for (final w in gmvController.weeklySummary) {
      pdfList.add({
        'tanggal': w.dateRange,
        'kategori': 'GMV Mingguan',
        'nominal': w.total,
        'tipe': 'IN',
        'isPaid': true,
      });
    }

    // 2. Other Expenses (OUT)
    if (cashflowController.pengeluaranController?.allExpenses != null) {
      for (final e in cashflowController.pengeluaranController!.allExpenses) {
        pdfList.add({
          'tanggal': e.tanggal,
          'deskripsi': e.deskripsi,
          'kategori': e.kategori,
          'nominal': e.nominal,
          'tipe': 'OUT',
        });
      }
    }

    // 3. Unpaid Salaries (OUT)
    final Iterable<dynamic> unpaidSalaryRecords =
        payrollController.totalUnpaidSalary is Iterable
        ? payrollController.totalUnpaidSalary as Iterable<dynamic>
        : [];

    if (unpaidSalaryRecords.isNotEmpty) {
      for (final s in unpaidSalaryRecords) {
        pdfList.add({
          'tanggal': s.tanggal,
          'deskripsi': 'Gaji: ${s.employeeName}',
          'kategori': 'Gaji Karyawan',
          'nominal': s.salaryAmount,
          'tipe': 'OUT',
        });
      }
    }

    return pdfList;
  }


  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Keuangan",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('keuanganIndexScroll'),
        child: Column(
          key: const Key('keuanganIndexColumn'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFadeSlide(
              delay: 0.1,
              child: CustomAppTitle(
                title: "Keuangan",
                backToPage: const AdminHomePage(),
              ),
            ),

            Consumer3<GmvController, PayrollController, PengeluaranController>(
              builder: (
                context,
                gmvController,
                payrollController,
                pengeluaranController,
                child,
              ) {
                final List<dynamic> weeklySummary =
                    gmvController.weeklySummary;
                final bool isLoadingGmv = gmvController.isLoading;

                final cashflowController = context.read<CashflowController>();
                // BARIS INI DIHAPUS KARENA MENYEBABKAN ProviderNotFoundException
                // dan variabelnya tidak digunakan di sini.
                // final karyawanController = context.read<KaryawanController>();

                // REFACTOR: Panggil fungsi helper untuk menyiapkan data PDF
                final pdfList = _prepareCashflowPdfData(
                  gmvController: gmvController,
                  cashflowController: cashflowController,
                  payrollController: payrollController,
                );

                // --- Perhitungan Tetap di Dalam Builder (diperlukan untuk tampilan) ---
                final double totalGmv = weeklySummary.fold(
                    0.0, (sum, item) => sum + (item.total as double));
                final double totalProfitMargin = calculateProfit(totalGmv);
                final double income = totalProfitMargin;

                final double totalUnpaidSalary = payrollController.totalUnpaidSalary;
                final double totalOperational =pengeluaranController.totalOperationalCost;
                final double totalOtherExpenses =pengeluaranController.totalOtherExpenses;

                final double totalExpenditure = totalUnpaidSalary + totalOperational + totalOtherExpenses;
                final double actualProfit = income - totalExpenditure;

                final String formattedGmv = formatMoney(totalGmv);
                final String formattedIncome = formatMoney(income);
                final String formattedUnpaidSalary = formatMoney(totalUnpaidSalary);
                final String formattedOperational = formatMoney(totalOperational);
                final String formattedOther = formatMoney(totalOtherExpenses);
                final String formattedExpenditure = formatMoney(totalExpenditure);
                final String formattedActualProfit = formatMoney(actualProfit);

                if (isLoadingGmv && weeklySummary.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedFadeSlide(
                      delay: 0.3,
                      child: ProfileSectionWrapper(
                        title: "Rangkuman keuangan",
                        children: [
                          ProfileDataRow(label: "Est. Pemasukan",value: formattedIncome),
                          const Divider(color: Colors.white30),
                          ProfileDataRow(label: "Gaji belum dibayar",value: formattedUnpaidSalary),
                          ProfileDataRow(label: "Operasional",value: formattedOperational),
                          ProfileDataRow(label: "Pengeluaran Lain",value: formattedOther),
                          const Divider(color: Colors.white30),
                          ProfileDataRow(label: "Total pengeluaran",value: formattedExpenditure,isHighlight: true,
                          ),
                          ProfileDataRow(label: "Est. Keuntungan Bersih",value: formattedActualProfit,isHighlight: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AnimatedFadeSlide(
                      delay: 0.2,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final String adminName = "Admin";

                            await generateCashflowPdf(
                              nama: adminName,
                              estIncome: income,
                              totalUnpaidSalary: totalUnpaidSalary,
                              totalOperational: totalOperational,
                              totalOtherExpenses: totalOtherExpenses,
                              netProfit: actualProfit,
                              // Re-mapping weeklySummary untuk parameter fungsi
                              weeklySummary:
                                  gmvController.weeklySummary.map((w) {
                                return {
                                  'mingguKe': w.mingguKe,
                                  'total': w.total,
                                  'isUp': w.isUp,
                                };
                              }).toList(),
                              cashflowList: pdfList, // Gunakan list yang sudah di-prepare
                            );
                          },
                          icon:
                              const Icon(Icons.print, color: Colors.black),
                          label: const Text(
                            "Cetak cashflow",
                            style: TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    AnimatedFadeSlide(
                      delay: 0.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Est. Pemasukan GMV",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Total : $formattedGmv",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (weeklySummary.isEmpty)
                            const Text(
                              "Tidak ada data GMV mingguan tersedia.",
                              style:
                                  TextStyle(color: Colors.white54),
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildWeeklyCardRow(
                                        weeklySummary, 0, false),
                                    const SizedBox(width: 10),
                                    _buildWeeklyCardRow(
                                        weeklySummary, 1, false),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildWeeklyCardRow(
                                        weeklySummary, 2, false),
                                    const SizedBox(width: 10),
                                    _buildWeeklyCardRow(
                                        weeklySummary, 3, false),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AnimatedFadeSlide(
                      delay: 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Est. Keuntungan (Profit Margin)",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Total : ${formatMoney(totalProfitMargin)} (5% dari GMV)",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (weeklySummary.isEmpty)
                            const Text(
                              "Tidak ada data keuntungan mingguan tersedia.",
                              style:
                                  TextStyle(color: Colors.white54),
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildWeeklyCardRow(
                                        weeklySummary, 0, true),
                                    const SizedBox(width: 10),
                                    _buildWeeklyCardRow(
                                        weeklySummary, 1, true),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildWeeklyCardRow(
                                        weeklySummary, 2, true),
                                    const SizedBox(width: 10),
                                    _buildWeeklyCardRow(
                                        weeklySummary, 3, true),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AnimatedFadeSlide(
                      delay: 0.6,
                      child:
                          const EmployeeSalaryCard(initialDelay: 0.6),
                    ),
                    const SizedBox(height: 24),

                    AnimatedFadeSlide(
                      delay: 0.7,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context,
                                    createRoute(const KeuanganEditPage()));
                              },
                              icon: const Icon(Icons.edit,
                                  color: Colors.black),
                              label: const Text("Edit data"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF00BCD4),
                                foregroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft:
                                          Radius.circular(12)),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context,
                                    createRoute(const KeuanganAddPage()));
                              },
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.black),
                              label: const Text("Tambah data"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight:
                                          Radius.circular(12)),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AnimatedFadeSlide(
                      delay: 0.7,
                      child:
                          const OperationalExpenseCard(initialDelay: 0.7),
                    ),
                    const SizedBox(height: 24),

                    AnimatedFadeSlide(
                      delay: 0.8,
                      child: const OtherExpenseCard(
                          initialDelay: 0.8),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}