// File: lib/views/admin/keuangan/keuangan_index_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart'; 
// Asumsi: Perubahan nama file di folder controller// <<< PERBAIKAN: Import WeeklyGmvSummary

import '../../../utils/animated_fade_slide.dart'; 
import '../../base_page.dart'; 
import '../../home_page.dart'; 


class KeuanganIndexPage extends StatefulWidget {
  const KeuanganIndexPage({super.key});

  @override
  State<KeuanganIndexPage> createState() => _KeuanganIndexPageState();
}

class _KeuanganIndexPageState extends State<KeuanganIndexPage> {
  
  // --- Formatter & Helper Functions ---
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', 
    symbol: 'Rp ', 
    decimalDigits: 0, 
  );
  
  
  final NumberFormat compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID', 
    symbol: 'Rp', 
    decimalDigits: 1,
  );

  String formatMoney(double number) {
    // Memperbaiki logika formatting yang mungkin terlalu membatasi (Rp 10,000,000)
    if (number.abs() >= 10000000) { 
      return compactFormatter.format(number);
    }
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  double calculateProfit(double gmvTotal) {
    const double profitPercentage = 0.05; // 5%
    return gmvTotal * profitPercentage;
  }
  

  // WIDGET KARTU YANG FLEKSIBLE (Tidak ada perubahan)
  Widget _buildSummaryCard({
    required int mingguKe,
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

  //   Helper untuk membangun kartu mingguan di dalam Row
  Widget _buildWeeklyCardRow(List<WeeklyGmvSummary> data, int index, bool isProfit) {
    // Pastikan index yang diminta valid
    if (data.length > index) {
      final summary = data[index];
      final amount = isProfit ? calculateProfit(summary.total) : summary.total;
      final title = "Minggu ke -${summary.mingguKe} (${isProfit ? 'Profit' : 'GMV'})";
      
      return Expanded( 
        child: _buildSummaryCard(
          mingguKe: summary.mingguKe,
          totalAmount: amount, 
          isUp: summary.isUp,
          title: title,
        ),
      );
    }
    return const Expanded(child: SizedBox.shrink()); 
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
            
            AnimatedFadeSlide(delay: 0.1, child: CustomAppTitle(title: "Keuangan", backToPage: const AdminHomePage())),
            
            // -----------------------------------------------------------------
            // CONSUMER 1: GMV CONTROLLER
            // -----------------------------------------------------------------
            Consumer<GmvController>(
              builder: (context, gmvController, child) {
                
                final weeklySummary = gmvController.weeklySummary; 
                final bool isLoadingGmv = gmvController.isLoading;
                
                final double totalGmv = weeklySummary.fold(0.0, (sum, item) => sum + item.total);
                final double totalProfitMargin = calculateProfit(totalGmv); 
                final double income = totalProfitMargin; // Pemasukan (Est. Profit Margin)
                
                final String formattedGmv = formatMoney(totalGmv);


                if (isLoadingGmv && weeklySummary.isEmpty) {
                  return const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(color: Colors.white),
                  ));
                }
                
                // -----------------------------------------------------------------
                // CONSUMER 2: PAYROLL & PENGELUARAN CONTROLLER (Nested Consumer)
                // -----------------------------------------------------------------
                return Consumer<PayrollController>(
                  builder: (context, payrollController, child) {
                    
                    // MENGAKSES PENGELUARAN CONTROLLER DI SINI
                    final pengeluaranController = Provider.of<PengeluaranController>(context);
                    
                    // MENGGUNAKAN GETTER DINAMIS DARI CONTROLLER YANG SUDAH DIBUAT
                    final double totalOperational = pengeluaranController.totalOperationalCost; 
                    final double totalUnpaidSalary = payrollController.totalUnpaidSalary;
// Tambahan: Mengambil biaya Gaji dari Pengeluaran
                    
                    //   PERHITUNGAN AKHIR DINAMIS
                    // Catatan: Anda menggunakan totalUnpaidSalary (Gaji yang Belum dibayar) sebagai pengeluaran di sini.
                    // Namun, karena PengeluaranController juga memiliki totalSalaryCost (Gaji yang sudah dibayar/dicatat), 
                    // untuk perhitungan keuntungan *bulanan* yang akurat, Anda harus menggunakan SUMBER Gaji yang konsisten.
                    // Saya akan tetap mengikuti logika Anda (menggunakan UnpaidSalary) untuk kompatibilitas, namun menambahkan Catatan Mentor.
                    
                    final double totalExpenditure = totalUnpaidSalary + totalOperational + pengeluaranController.totalOtherExpenses; // Disesuaikan
                    final double actualProfit = income - totalExpenditure; 

                    // Formatting
                    final String formattedIncome = formatMoney(income); // Est. Pemasukan (Profit Margin)
                    final String formattedUnpaidSalary = formatMoney(totalUnpaidSalary);
                    final String formattedOperational = formatMoney(totalOperational);
                    final String formattedOther = formatMoney(pengeluaranController.totalOtherExpenses); // BARU
                    final String formattedExpenditure = formatMoney(totalExpenditure); 
                    final String formattedActualProfit = formatMoney(actualProfit);
                    

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === Rangkuman Keuangan Dinamis ===
                        AnimatedFadeSlide(
                          delay: 0.3,
                          child: ProfileSectionWrapper(
                            title: "Rangkuman keuangan",
                            children: [
                              ProfileDataRow(label: "Est. Pemasukan", value: formattedIncome), 
                              const Divider(color: Colors.white30),
                              ProfileDataRow(label: "Gaji belum dibayar", value: formattedUnpaidSalary), // Menggunakan Unpaid Salary
                              ProfileDataRow(label: "Operasional", value: formattedOperational), // DINAMIS
                              ProfileDataRow(label: "Pengeluaran Lain", value: formattedOther), // BARU: Tampilkan Kategori lain
                              const Divider(color: Colors.white30),
                              ProfileDataRow(
                                label: "Total pengeluaran", 
                                value: formattedExpenditure, 
                                isHighlight: true, 
                              ), 
                              ProfileDataRow(
                                label: "Est. Keuntungan Bersih", 
                                value: formattedActualProfit,
                                isHighlight: true, 
                              ), 
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // === Bagian GMV (Pemasukan) ===
                        AnimatedFadeSlide(
                          delay: 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Est. Pemasukan GMV",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Total : $formattedGmv", 
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              
                              if (weeklySummary.isEmpty) 
                                const Text("Tidak ada data GMV mingguan tersedia.", style: TextStyle(color: Colors.white54))
                              else 
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildWeeklyCardRow(weeklySummary, 0, false),
                                        const SizedBox(width: 10),
                                        _buildWeeklyCardRow(weeklySummary, 1, false),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildWeeklyCardRow(weeklySummary, 2, false),
                                        const SizedBox(width: 10),
                                        _buildWeeklyCardRow(weeklySummary, 3, false),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),


                        // === Bagian Keuntungan (5% Profit Margin) ===
                        AnimatedFadeSlide(
                          delay: 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Est. Keuntungan (Profit Margin)",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Total : ${formatMoney(totalProfitMargin)} (5% dari GMV)", 
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              
                              if (weeklySummary.isEmpty) 
                                const Text("Tidak ada data keuntungan mingguan tersedia.", style: TextStyle(color: Colors.white54))
                              else 
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildWeeklyCardRow(weeklySummary, 0, true),
                                        const SizedBox(width: 10),
                                        _buildWeeklyCardRow(weeklySummary, 1, true),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildWeeklyCardRow(weeklySummary, 2, true),
                                        const SizedBox(width: 10),
                                        _buildWeeklyCardRow(weeklySummary, 3, true),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // === BAGIAN GAJI KARYAWAN ===
                        AnimatedFadeSlide(
                          delay: 0.6,
                          child: _EmployeeSalaryCard(initialDelay: 0.6), 
                        ),
                        const SizedBox(height: 24),
                        
                        
                        // === PENGELUARAN OPSIONAL (DINAMIS) ===
                        AnimatedFadeSlide(
                          delay: 0.7,
                          child: _OperationalExpenseCard(
                            pengeluaranController: pengeluaranController,
                            initialDelay: 0.7,
                          ),
                        ),
                        const SizedBox(height: 24), 
                        
                        // === PENGELUARAN LAINNYA (DIBUAT BARU) ===
                        AnimatedFadeSlide(
                          delay: 0.8,
                          child: _OtherExpenseCard(
                            pengeluaranController: pengeluaranController,
                            initialDelay: 0.8,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ]
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
    
  }
}

// ====================================================================
// WIDGET BARU: KARTU PENGELUARAN OPERASIONAL (Dipisahkan agar lebih rapi)
// ====================================================================

class _OperationalExpenseCard extends StatelessWidget {
  final PengeluaranController pengeluaranController;
  final double initialDelay;

  const _OperationalExpenseCard({
    required this.pengeluaranController,
    required this.initialDelay,
  });
  
  // Helper untuk format mata uang
  String _formatMoney(double number) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0, 
    );
    return currencyFormatter.format(number).replaceAll(',', '.');
  }


  @override
  Widget build(BuildContext context) {
    
    // Filter data di UI: Ambil semua data lalu saring yang 'Operasional'
    // Catatan: Filter ini seharusnya sudah dilakukan di getter 'operationalExpenses' dari Controller, 
    // namun karena saya belum melihat definisi Controller Anda, saya akan asumsikan 
    // Anda sudah menambahkan getter untuk pengeluaran Operasional di Controller.
    final List<Pengeluaran> allExpenses = pengeluaranController.allExpenses;
    final List<Pengeluaran> operationalExpenses = allExpenses
        .where((e) => e.kategori == 'Operasional')
        .toList();
    
    final double total = pengeluaranController.totalOperationalCost;
    final bool isLoading = pengeluaranController.isLoading;
    final String formattedTotal = _formatMoney(total);

    return ProfileSectionWrapper(
      title: "Pengeluaran Operasional (Bulan Ini)",
      subtitle: "Total : $formattedTotal",
      children: [
        if (isLoading && operationalExpenses.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Color(0xFF00ADB5)),
          ))
        else if (operationalExpenses.isEmpty) // Menggunakan list hasil filter
          const ProfileDataRow(
            label: "Tidak ada data pengeluaran operasional bulan ini.", 
            value: "",
          )
        else
          ...operationalExpenses.map((expense) { // Menggunakan list hasil filter
            final formattedValue = _formatMoney(expense.nominal);
            
            return ProfileDataRow(
              label: '${expense.deskripsi} (${DateFormat('dd/MM').format(expense.tanggal)})',
              value: formattedValue,
            );
          }),
      ],
    );
  }
}


// ====================================================================
// WIDGET BARU: KARTU PENGELUARAN LAINNYA (Dibuat untuk menampilkan kategori lain)
// ====================================================================

class _OtherExpenseCard extends StatelessWidget {
  final PengeluaranController pengeluaranController;
  final double initialDelay;

  const _OtherExpenseCard({
    required this.pengeluaranController,
    required this.initialDelay,
  });
  
  String _formatMoney(double number) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0, 
    );
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    // Filter data di UI: Ambil semua data lalu saring yang BUKAN 'Operasional' dan BUKAN 'Gaji'
    final List<Pengeluaran> allExpenses = pengeluaranController.allExpenses;
    final List<Pengeluaran> otherExpenses = allExpenses
        .where((e) => e.kategori != 'Operasional' && e.kategori != 'Gaji')
        .toList();
    
    final double total = pengeluaranController.totalOtherExpenses;
    final bool isLoading = pengeluaranController.isLoading;
    final String formattedTotal = _formatMoney(total);

    return ProfileSectionWrapper(
      title: "Pengeluaran Lainnya (Bulan Ini)",
      subtitle: "Total : $formattedTotal",
      children: [
        if (isLoading && otherExpenses.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Color(0xFF00ADB5)),
          ))
        else if (otherExpenses.isEmpty) 
          const ProfileDataRow(
            label: "Tidak ada data pengeluaran non-operasional bulan ini.", 
            value: "",
          )
        else
          ...otherExpenses.map((expense) { 
            final formattedValue = _formatMoney(expense.nominal);
            
            return ProfileDataRow(
              label: '${expense.deskripsi} (${expense.kategori}) - ${DateFormat('dd/MM').format(expense.tanggal)}',
              value: formattedValue,
            );
          }),
      ],
    );
  }
}

// ====================================================================
// WIDGET KARYAWAN (Tidak Berubah)
// ====================================================================

class _SalaryListItem extends StatelessWidget {
// ... (Kode _SalaryListItem tidak berubah) ... 
  final String name;
  final String userId;
  final double salary;
  final int totalCounts;
  final DateTime newPeriodStartDate;
  final NumberFormat currencyFormatter;

  const _SalaryListItem({
    required this.name, 
    required this.userId, 
    required this.salary,
    required this.totalCounts,
    required this.newPeriodStartDate,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C385C), 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nama & Gaji
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              // Tampilkan Nominal Gaji
              Text(
                salary.toInt().toString().isNotEmpty
                    ? currencyFormatter.format(salary).replaceAll(',', '.')
                    : 'Rp 0',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
              ),
              // Tambahkan keterangan total counts sebagai info
              Text(
                "Total jam kerja: ${totalCounts*2} jam",
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),

          // Tombol Aksi
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () async {
                // Mendapatkan instance PayrollController untuk memanggil fungsi processPayment
                final payrollController = Provider.of<PayrollController>(context, listen: false);

                // Dummy call to simulate payment
                await payrollController.processPayment(
                  userId: userId,
                  amount: salary,
                  totalCounts: totalCounts,
                  newStartDate: newPeriodStartDate,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Memproses pembayaran gaji untuk $name...'),
                    duration: const Duration(milliseconds: 700),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran gaji berhasil dicatat!'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                "Bayar gaji",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeSalaryCard extends StatelessWidget {
// ... (Kode _EmployeeSalaryCard tidak berubah) ... 
  final double initialDelay; 

  const _EmployeeSalaryCard({required this.initialDelay});

  @override
  Widget build(BuildContext context) {
    return Consumer<PayrollController>(
      builder: (context, controller, child) {
        
        final List<Map<String, dynamic>> employeeList = controller.unpaidEmployeeList;
        
        // Kita menggunakan totalUnpaidSalary dari controller, tidak perlu hitung ulang
        final double totalUnpaidSalary = controller.totalUnpaidSalary;
        
        final NumberFormat currencyFormatter = NumberFormat.currency(
          locale: 'id_ID', 
          symbol: 'Rp ', 
          decimalDigits: 0, 
        );
        final String formattedTotal = currencyFormatter.format(totalUnpaidSalary).replaceAll(',', '.');

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF152A46),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileSectionWrapper(
                title: "Daftar Gaji Karyawan Belum Dibayar", 
                subtitle: "Total: $formattedTotal", // Menggunakan total dari controller
                children: const [],
              ),

              if (controller.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFF00ADB5)),
                ))
              else if (employeeList.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Tidak ada karyawan yang memiliki gaji yang belum dibayar.", style: TextStyle(color: Colors.white54)),
                ))
              else
                // PENTING: ListView.builder harus dibungkus dengan widget yang memiliki tinggi terbatas
                SizedBox(
                  height: employeeList.length < 3 ? employeeList.length * 80.0 : 3 * 80.0, 
                  child: ListView.builder(
                    padding: EdgeInsets.zero, 
                    physics: const ClampingScrollPhysics(),
                    itemCount: employeeList.length,
                    itemBuilder: (context, index) {
                      final employeeData = employeeList[index];

                      return AnimatedFadeSlide(
                        delay: initialDelay + (index * 0.1), 
                        duration: const Duration(milliseconds: 600),
                        child: _SalaryListItem(
                          name: employeeData['userName'] ?? 'N/A',
                          userId: employeeData['userId'] ?? '',
                          salary: employeeData['unpaidAmount'] ?? 0.0,
                          totalCounts: employeeData['totalUnpaidCounts'] ?? 0,
                          newPeriodStartDate: employeeData['newPeriodStartDate'] ?? DateTime.now(),
                          currencyFormatter: currencyFormatter,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}