import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Wajib: Import provider
import 'package:intl/intl.dart'; // Wajib: Untuk format uang yang lebih baik
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import '../../../utils/animated_fade_slide.dart'; 
import '../../base_page.dart'; 
import '../../home_page.dart'; 


class KeuanganIndexPage extends StatefulWidget {
  const KeuanganIndexPage({super.key});

  @override
  State<KeuanganIndexPage> createState() => _KeuanganIndexPageState();
}

class _KeuanganIndexPageState extends State<KeuanganIndexPage> {

  final List<Map<String, dynamic>> weeklySummary = [
    {'minggu': 1, 'total': 1300000000, 'isUp': true},
    {'minggu': 2, 'total': 1300000000, 'isUp': false},
    {'minggu': 3, 'total': 1300000000, 'isUp': false},
    {'minggu': 4, 'total': 1300000000, 'isUp': true},
  ];

  // Menggunakan NumberFormat untuk format uang yang lebih aman dan global
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // Lokasi Indonesia
    symbol: 'Rp ', 
    decimalDigits: 0, // Tidak menampilkan desimal
  );

  String formatMoney(double number) {
    if (number >= 1000000000) {
      // Format Miliar (untuk kartu summary)
      double billions = number / 1000000000;
      return "Rp ${billions.toStringAsFixed(1).replaceAll('.', ',')} M";
    }
    // Untuk tampilan detail (Ribuan separator)
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  Widget _buildSummaryCard(Map<String, dynamic> data) {
    final bool isUp = data['isUp'];
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
            "Minggu ke -${data['minggu']}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                // Mengubah total dari int ke double
                formatMoney(data['total'].toDouble()), 
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
            
            // ... (Bagian header dan rangkuman lainnya tidak berubah)
            AnimatedFadeSlide(
              delay: 0.1,
              child: CustomAppTitle( 
                title: "Keuangan",
                backToPage: const AdminHomePage(),
              ),
            ),

            AnimatedFadeSlide(
              delay: 0.3,
              child: const ProfileSectionWrapper(
                title: "Rangkuman keuangan",
                children: [
                  ProfileDataRow(label: "Est. Pemasukan", value: "Rp 123,456,789"),
                  ProfileDataRow(label: "Gaji karyawan", value: "Rp 123,456,789"),
                  ProfileDataRow(label: "Operasional", value: "Rp 123,456,789"),
                  Divider(color: Colors.white30),
                  ProfileDataRow(label: "Total pengeluaran", value: "Rp 123,456,789"),
                  ProfileDataRow(label: "Total keuntungan", value: "Rp 123,456,789"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ... (Bagian Weekly Summary Cards tidak berubah)
            AnimatedFadeSlide(
              delay: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Est. Pemasukan GMV",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Total : Rp 123.456.789",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSummaryCard(weeklySummary[0])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSummaryCard(weeklySummary[1])),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSummaryCard(weeklySummary[2])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSummaryCard(weeklySummary[3])),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== ✅ KARTU GAJI KARYAWAN (Menggunakan PayrollController) =====
            AnimatedFadeSlide(
              delay: 0.5,
              // Mengganti widget lama dengan versi berbasis Provider
              child: _EmployeeSalaryCard(initialDelay: 0.5), 
            ),
            const SizedBox(height: 24),
            
            // ... (Bagian Pengeluaran Opsional tidak berubah)
            AnimatedFadeSlide(
              delay: 0.3,
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
        )
      )
    );
  }
}

// ====================================================================
//                   WIDGET BARU YANG TERINTEGRASI DENGAN CONTROLLER
// ====================================================================

// Widget untuk setiap baris gaji karyawan
class _SalaryListItem extends StatelessWidget {
  final String name;
  final String userId;
  final double salary;
  final int totalCounts;
  final DateTime newPeriodStartDate;
  final NumberFormat currencyFormatter; // Terima formatter dari luar

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

                // await payrollController.processPayment(
                //   userId: userId,
                //   amount: double.parse(salary.replaceAll(RegExp(r'[Rp .,]'), '')), // Hati-hati dengan konversi string ke double
                //   totalCounts: totalCounts,
                //   newStartDate: newPeriodStartDate,
                // );
                
                // Setelah pembayaran, refresh data (hanya contoh sementara)
                // await payrollController.fetchUnpaidEmployeeData(); 

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pembayaran gaji untuk $name berhasil dicatat! (Fungsi processPayment masih perlu diimplementasikan)'),
                    duration: const Duration(milliseconds: 1500),
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

// Widget utama Pengeluaran Gaji Karyawan (Menggunakan Consumer)
class _EmployeeSalaryCard extends StatelessWidget {
  final double initialDelay; 

  const _EmployeeSalaryCard({required this.initialDelay});

  @override
  Widget build(BuildContext context) {
    // Akses controller untuk mendengarkan perubahan state
    return Consumer<PayrollController>(
      builder: (context, controller, child) {
        
        final List<Map<String, dynamic>> employeeList = controller.unpaidEmployeeList;
        
        // 1. Hitung Total Pengeluaran Gaji yang Belum Dibayar
        final double totalUnpaidSalary = employeeList.fold(
          0.0, 
          (sum, item) => sum + (item['unpaidAmount'] as double)
        );
        
        // Formatter yang sama dari KeuanganIndexPage
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
              ProfileSectionWrapper(title: "Pengeluaran gaji karyawan", subtitle: "Total : $formattedTotal", children: []),

              // Tampilan Loading atau Daftar Karyawan
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
                // Daftar Karyawan yang Dapat Digulir
                SizedBox(
                  height: 3 * 80.0, // Tinggi tetap untuk 3 item
                  child: ListView.builder(
                    padding: EdgeInsets.zero, 
                    physics: const ClampingScrollPhysics(),
                    itemCount: employeeList.length,
                    itemBuilder: (context, index) {
                      final employeeData = employeeList[index];

                      return AnimatedFadeSlide(
                        // Staggered list: delay 0.1 detik per item
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