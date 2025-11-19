import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';

class EmployeeSalaryCard extends StatelessWidget {
  final double initialDelay; 

  const EmployeeSalaryCard({required this.initialDelay});

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