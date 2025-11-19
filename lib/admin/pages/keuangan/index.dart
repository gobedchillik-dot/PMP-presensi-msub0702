// File: lib/views/admin/keuangan/keuangan_index_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tes_flutter/admin/pages/keuangan/add.dart';
import 'package:tes_flutter/admin/pages/keuangan/edit.dart'; 
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';
import 'package:tes_flutter/utils/route_generator.dart'; 

import '../../../utils/animated_fade_slide.dart'; 
import '../../base_page.dart'; 
import '../../home_page.dart'; 

// <<< ASUMSI: Definisikan Kategori Pengeluaran (HARUSNYA ada di tempat yang lebih global)
const String _kategoriOperasional = 'Operasional';
// >>>

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
    // Logika formatting yang lebih bersih
    if (number.abs() >= 10000000) { 
      return compactFormatter.format(number);
    }
    // Perbaikan: Gunakan replaceAll(',', '.') hanya jika locale menggunakan koma sebagai pemisah desimal, 
    // namun karena locale 'id_ID' sudah menggunakan titik sebagai pemisah ribuan, 
    // kita pastikan untuk menghilangkan ',' yang dihasilkan NumberFormat jika ada.
    return currencyFormatter.format(number).replaceAll(',', '.');
  }
  String kuartalFormatMoney(double number) {
    // Logika formatting yang lebih bersih
    if (number.abs() >= 1000000) { 
      return compactFormatter.format(number);
    }
    // Perbaikan: Gunakan replaceAll(',', '.') hanya jika locale menggunakan koma sebagai pemisah desimal, 
    // namun karena locale 'id_ID' sudah menggunakan titik sebagai pemisah ribuan, 
    // kita pastikan untuk menghilangkan ',' yang dihasilkan NumberFormat jika ada.
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  double calculateProfit(double gmvTotal) {
    // PENTING: Untuk Profit Margin, nilai ini harusnya didefinisikan secara global 
    // atau diambil dari konfigurasi.
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
                kuartalFormatMoney(totalAmount), 
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
  Widget _buildWeeklyCardRow(List<dynamic> data, int index, bool isProfit) {
    // Gunakan dynamic karena WeeklyGmvSummary tidak didefinisikan di sini.
    if (data.length > index) {
      final summary = data[index];
      final double totalAmount = summary.total as double; // ASUMSI: field 'total' ada
      final int mingguKe = summary.mingguKe as int; // ASUMSI: field 'mingguKe' ada
      final bool isUp = summary.isUp as bool; // ASUMSI: field 'isUp' ada

      final amount = isProfit ? calculateProfit(totalAmount) : totalAmount;
      final title = "Minggu ke - $mingguKe (${isProfit ? 'Profit' : 'GMV'})";
      
      return Expanded( 
        child: _buildSummaryCard(
          mingguKe: mingguKe,
          totalAmount: amount, 
          isUp: isUp,
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
            // MENGGUNAKAN SELECTOR UNTUK EFISIENSI REBUILD
            // -----------------------------------------------------------------
            Selector<GmvController, List<dynamic>>(
              // Gunakan dynamic karena WeeklyGmvSummary tidak didefinisikan di sini.
              selector: (_, controller) => controller.weeklySummary,
              builder: (context, weeklySummary, child) {
                
                // Cek loading dari GmvController (menggunakan Provider.of<GmvController> untuk cek isloading)
                final bool isLoadingGmv = Provider.of<GmvController>(context, listen: false).isLoading;

                final double totalGmv = weeklySummary.fold(0.0, (sum, item) => sum + (item.total as double));
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
                // SELECTOR 2: PAYROLL & PENGELUARAN CONTROLLER (Nested Selector/Consumer)
                // Kita butuh data dari 2 controller, kita buat Selector/Consumer untuk Payroll.
                // -----------------------------------------------------------------
                return Selector<PayrollController, double>(
                  selector: (_, controller) => controller.totalUnpaidSalary,
                  builder: (context, totalUnpaidSalary, child) {
                    
                    // MENGAKSES PENGELUARAN CONTROLLER DI SINI (Selector untuk properti pengeluaran)
                    return Selector<PengeluaranController, (double, double)>(
                      // Selector mengembalikan tuple dari 2 nilai yang dibutuhkan
                      selector: (_, controller) => (controller.totalOperationalCost, controller.totalOtherExpenses),
                      builder: (context, pengeluaranData, child) {
                        final double totalOperational = pengeluaranData.$1; 
                        final double totalOtherExpenses = pengeluaranData.$2; 
                        
                        // PERHITUNGAN AKHIR
                        // Catatan Mentor: Konsistensi Sumber Gaji harus diperhatikan. 
                        // totalUnpaidSalary hanya mencakup gaji yang BELUM dibayar. 
                        // Keuntungan *aktual* akan menggunakan total biaya gaji bulanan (paid + unpaid). 
                        // Namun, saya mengikuti logika Anda yang menggunakan totalUnpaidSalary.
                        
                        final double totalExpenditure = totalUnpaidSalary + totalOperational + totalOtherExpenses; 
                        final double actualProfit = income - totalExpenditure; 

                        // Formatting
                        final String formattedIncome = formatMoney(income);
                        final String formattedUnpaidSalary = formatMoney(totalUnpaidSalary);
                        final String formattedOperational = formatMoney(totalOperational);
                        final String formattedOther = formatMoney(totalOtherExpenses); 
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
                                  ProfileDataRow(label: "Operasional", value: formattedOperational), 
                                  ProfileDataRow(label: "Pengeluaran Lain", value: formattedOther), 
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
                              child: const _EmployeeSalaryCard(initialDelay: 0.6), // Dipertahankan di sini untuk kelengkapan
                            ),
                            const SizedBox(height: 24),

                            AnimatedFadeSlide(
                              delay: 0.7,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () { 
                                        Navigator.push(context, createRoute(const KeuanganEditPage()));
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.black),
                                      label: const Text("Edit data"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00BCD4),
                                        foregroundColor: Colors.black,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(context, createRoute(const KeuanganAddPage()));
                                      },
                                      icon: const Icon(Icons.add_circle, color: Colors.black),
                                      label: const Text("Tambah data"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00E676),
                                        foregroundColor: Colors.black,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            
                            // === PENGELUARAN OPSIONAL (DINAMIS) ===
                            AnimatedFadeSlide(
                              delay: 0.7,
                              child: _OperationalExpenseCard(
                                initialDelay: 0.7,
                              ),
                            ),
                            const SizedBox(height: 24), 
                            
                            // === PENGELUARAN LAINNYA (DIBUAT BARU) ===
                            AnimatedFadeSlide(
                              delay: 0.8,
                              child: const _OtherExpenseCard(
                                initialDelay: 0.8,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ]
                        );
                      },
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
// WIDGET KARTU PENGELUARAN OPERASIONAL (Diperbarui dengan Selector)
// ====================================================================

class _OperationalExpenseCard extends StatelessWidget {
  final double initialDelay;

  const _OperationalExpenseCard({
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
    // Menggunakan Selector untuk mendapatkan hanya data Pengeluaran Operasional dan status loading
    return Selector<PengeluaranController, (List<Pengeluaran>, double, bool)>(
      selector: (_, controller) => (
        controller.allExpenses.where((e) => e.kategori == _kategoriOperasional).toList(), // Filter di sini
        controller.totalOperationalCost, 
        controller.isLoading
      ),
      builder: (context, data, child) {
        final List<Pengeluaran> operationalExpenses = data.$1;
        final double total = data.$2;
        final bool isLoading = data.$3;

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
            else if (operationalExpenses.isEmpty) 
              const ProfileDataRow(
                label: "Tidak ada data pengeluaran operasional bulan ini.", 
                value: "",
              )
            else
              // Tampilkan data
              ...operationalExpenses.map((expense) { 
                final formattedValue = _formatMoney(expense.nominal);
                
                // 🔥 KOREKSI 1: Deklarasi dan penggunaan formattedDate
                final formattedDate = DateFormat('dd/MM').format(expense.dateTime); 
                
                return ProfileDataRow(
                  // Menggunakan formattedDate yang sudah dideklarasikan
                  label: '${expense.deskripsi} - $formattedDate', 
                  value: formattedValue,
                );
              }),
          ],
        );
      },
    );
  }
}

// ====================================================================
// WIDGET KARTU PENGELUARAN LAINNYA
// ====================================================================

class _OtherExpenseCard extends StatelessWidget {
  final double initialDelay;

  const _OtherExpenseCard({
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
    // Menggunakan Selector untuk mendapatkan hanya data Pengeluaran Lainnya dan status loading
    return Selector<PengeluaranController, (List<Pengeluaran>, double, bool)>(
      selector: (_, controller) => (
        controller.allExpenses.where((e) => e.kategori != _kategoriOperasional).toList(), // Filter di sini
        controller.totalOtherExpenses, 
        controller.isLoading
      ),
      builder: (context, data, child) {
        final List<Pengeluaran> otherExpenses = data.$1;
        final double total = data.$2;
        final bool isLoading = data.$3;

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
              // Tampilkan data
              ...otherExpenses.map((expense) { 
                final formattedValue = _formatMoney(expense.nominal);
                
                // 🔥 KOREKSI 2: Implementasi DateFormat yang sudah benar
                // Menggunakan getter .dateTime yang mengkonversi Timestamp ke DateTime
                final formattedDate = DateFormat('dd/MM').format(expense.dateTime); 
                
                return ProfileDataRow(
                  // Menghilangkan kategori dari label karena sudah jelas di judul "Pengeluaran Lainnya"
                  label: '${expense.deskripsi} (${expense.kategori}) - $formattedDate', 
                  value: formattedValue,
                );
              }),
          ],
        );
      },
    );
  }
}

// ====================================================================
// WIDGET KARYAWAN (Dipertahankan di sini)
// ====================================================================

class _SalaryListItem extends StatelessWidget {
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
                final payrollController = Provider.of<PayrollController>(context, listen: false);

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
  final double initialDelay; 

  const _EmployeeSalaryCard({required this.initialDelay});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Selector untuk menghindari rebuild jika ada properti lain di PayrollController yang berubah
    return Selector<PayrollController, (List<Map<String, dynamic>>, double, bool)>(
      selector: (_, controller) => (
        controller.unpaidEmployeeList, 
        controller.totalUnpaidSalary, 
        controller.isLoading
      ),
      builder: (context, data, child) {
        final List<Map<String, dynamic>> employeeList = data.$1;
        final double totalUnpaidSalary = data.$2;
        final bool isLoading = data.$3;
        
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
                subtitle: "Total: $formattedTotal", // Menggunakan total dari selector
                children: const [],
              ),

              if (isLoading && employeeList.isEmpty)
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