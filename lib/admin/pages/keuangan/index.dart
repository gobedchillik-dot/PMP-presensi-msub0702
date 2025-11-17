import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:intl/intl.dart'; 
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart'; 
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
    if (number.abs() >= 1000000) { 
      return compactFormatter.format(number);
    }
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  double calculateProfit(double gmvTotal) {
    const double profitPercentage = 0.05; // 5%
    return gmvTotal * profitPercentage;
  }

  // WIDGET KARTU YANG FLEKSIBEL
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

  // 🎯 Helper untuk membangun kartu mingguan di dalam Row
  Widget _buildWeeklyCardRow(List<WeeklyGmvSummary> data, int index, bool isProfit) {
    // Pastikan index yang diminta valid
    if (data.length > index) {
      final summary = data[index];
      final amount = isProfit ? calculateProfit(summary.total) : summary.total;
      final title = "Minggu ke -${summary.mingguKe} (${isProfit ? 'Profit' : 'GMV'})";
      
      return _buildSummaryCard(
        mingguKe: summary.mingguKe,
        totalAmount: amount, 
        isUp: summary.isUp,
        title: title,
      );
    }
    // Jika data kurang, berikan Expanded kosong agar tata letak tetap rapi
    return const Expanded(child: SizedBox.shrink()); 
  }


  @override
  Widget build(BuildContext context) {
    
    // Perhitungan GMV/Profit tidak bisa dilakukan di sini, harus di dalam Consumer
    
    return BasePage(
      title: "Keuangan",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('keuanganIndexScroll'), 
        child: Column(
          key: const Key('keuanganIndexColumn'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // ... (Header dan Rangkuman Keuangan - Bagian ini akan menggunakan nilai statis/dummy karena data GMV dinamis dihitung di dalam Consumer)
            AnimatedFadeSlide(delay: 0.1, child: CustomAppTitle(title: "Keuangan", backToPage: const AdminHomePage())),
            
            // -----------------------------------------------------------------
            // 🎯 MENGGUNAKAN CONSUMER UNTUK MENDAPATKAN STATE GMV CONTROLLER
            // -----------------------------------------------------------------
            Consumer<GmvController>(
              builder: (context, gmvController, child) {
                
                final weeklySummary = gmvController.weeklySummary; 
                final bool isLoading = gmvController.isLoading;
                
                // Hitung total keseluruhan hanya di dalam builder
                final totalGmv = weeklySummary.fold(0.0, (sum, item) => sum + item.total);
                final totalProfit = calculateProfit(totalGmv);

                if (isLoading && weeklySummary.isEmpty) {
                  return const Center(child: Padding(
                       padding: EdgeInsets.symmetric(vertical: 40.0),
                       child: CircularProgressIndicator(color: Colors.white),
                  ));
                }
                
                // Gunakan nilai totalProfit dan totalGmv di sini
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Rangkuman Keuangan Dinamis (di dalam Consumer) ===
                    AnimatedFadeSlide(
                      delay: 0.3,
                      child: ProfileSectionWrapper(
                        title: "Rangkuman keuangan",
                        children: [
                          ProfileDataRow(label: "Est. Pemasukan", value: formatMoney(totalProfit)), // 💡 PERBAIKAN: Menggunakan totalGmv
                          const ProfileDataRow(label: "Gaji karyawan", value: "Rp 123,456,789"), // Statis
                          const ProfileDataRow(label: "Operasional", value: "Rp 123,456,789"), // Statis
                          const Divider(color: Colors.white30),
                          const ProfileDataRow(label: "Total pengeluaran", value: "Rp 123,456,789"), // Statis
                          ProfileDataRow(label: "Est. Keuntungan", value: formatMoney(totalProfit)), // 💡 PERBAIKAN: Menggunakan totalProfit
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
                            "Total : ${formatMoney(totalGmv)}",
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          
                          if (weeklySummary.isEmpty) 
                            const Text("Tidak ada data GMV mingguan tersedia.", style: TextStyle(color: Colors.white54))
                          else 
                            // 💡 GMV - KUARTAL 1 & 2
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 0, false)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 1, false)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // 💡 GMV - KUARTAL 3 & 4
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 2, false)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 3, false)),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),


                    // === Bagian Keuntungan (5% Profit) ===
                    AnimatedFadeSlide(
                      delay: 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Est. Keuntungan (5% dari GMV)",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Total : ${formatMoney(totalProfit)}",
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          
                          if (weeklySummary.isEmpty) 
                            const Text("Tidak ada data keuntungan mingguan tersedia.", style: TextStyle(color: Colors.white54))
                          else 
                            // 💡 PROFIT - KUARTAL 1 & 2
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 0, true)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 1, true)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // 💡 PROFIT - KUARTAL 3 & 4
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 2, true)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildWeeklyCardRow(weeklySummary, 3, true)),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),


            // ... (Bagian Gaji Karyawan dan Pengeluaran Opsional)
            AnimatedFadeSlide(
              delay: 0.6,
              child: _EmployeeSalaryCard(initialDelay: 0.6), 
            ),
            const SizedBox(height: 24),
            
            AnimatedFadeSlide(
              delay: 0.7,
              child: const ProfileSectionWrapper(
                title: "Pengeluaran opsional",
                subtitle: "Total : Rp 123,456,789",
                children: [
                  ProfileDataRow(label: "Kopi", value: "Rp 123,456,789"),
                  ProfileDataRow(label: "Listrik", value: "Rp 123,456,789"),
                  ProfileDataRow(label: "Wifi", value: "Rp 123,456,789"),
                  ProfileDataRow(label: "", value: ""),
                  ProfileDataRow(label: "", value: ""),
                  Divider(color: Colors.white30),
                  ProfileDataRow(label: "Total pengeluaran", value: "Rp 123,456,789"),
                  ProfileDataRow(label: "Total keuntungan", value: "Rp 123,456,789"),
                ],
              ),
            ),
            const SizedBox(height: 24), 
          ],
        ),
      )
    );
  }
}

// ====================================================================
// WIDGET KARYAWAN (Tidak Berubah)
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
                Provider.of<PayrollController>(context, listen: false);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Memproses pembayaran gaji untuk $name...'),
                    duration: const Duration(seconds: 1),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran gaji berhasil dicatat! (Fungsi processPayment masih perlu diimplementasikan)'),
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
    return Consumer<PayrollController>(
      builder: (context, controller, child) {
        
        final List<Map<String, dynamic>> employeeList = controller.unpaidEmployeeList;
        
        final double totalUnpaidSalary = employeeList.fold(
          0.0, 
          (sum, item) => sum + (item['unpaidAmount'] as double)
        );
        
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
              ProfileSectionWrapper(title: "Pengeluaran gaji karyawan", subtitle: "Total : $formattedTotal", children: const []),

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
                          name: employeeData['userName'],
                          userId: employeeData['userId'],
                          salary: employeeData['unpaidAmount'],
                          totalCounts: employeeData['totalUnpaidCounts'],
                          newPeriodStartDate: employeeData['newPeriodStartDate'],
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