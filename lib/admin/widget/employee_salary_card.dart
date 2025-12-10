// File: lib/admin/widget/employee_salary_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/pages/keuangan/detail_gaji.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
// BARU: Impor Model yang dibutuhkan
import 'package:tes_flutter/database/model/unpaid_gaji.dart'; 
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/utils/route_generator.dart';

class EmployeeSalaryCard extends StatelessWidget {
  final double initialDelay; 

  const EmployeeSalaryCard({required this.initialDelay, super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ KOREKSI UTAMA: Selector sekarang langsung meminta List<UnpaidSalaryModel> dari Controller
    return Selector<PayrollController, (List<UnpaidSalaryModel>, double, bool)>(
      selector: (_, controller) => (
        // HILANG: Baris .map(...).toList() dihapus!
        controller.unpaidEmployeeList, 
        controller.totalUnpaidSalary, 
        controller.isLoading
      ),
      builder: (context, data, child) {
        final List<UnpaidSalaryModel> employeeList = data.$1;
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
                subtitle: "Total: $formattedTotal",
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
                SizedBox(
                  height: employeeList.length < 3 ? employeeList.length * 80.0 : 3 * 80.0, 
                  child: ListView.builder(
                    padding: EdgeInsets.zero, 
                    physics: const ClampingScrollPhysics(),
                    itemCount: employeeList.length,
                    itemBuilder: (context, index) {
                      final UnpaidSalaryModel employeeData = employeeList[index];

                      return AnimatedFadeSlide(
                        delay: initialDelay + (index * 0.1), 
                        duration: const Duration(milliseconds: 600),
                        child: _SalaryListItem(
                          payrollData: employeeData, 
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

// =======================================================
// Refaktor Widget Item Daftar (_SalaryListItem tidak berubah)
// =======================================================
class _SalaryListItem extends StatelessWidget {
  final UnpaidSalaryModel payrollData; 
  final NumberFormat currencyFormatter;

  const _SalaryListItem({
    required this.payrollData,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    // Kode ini sekarang aman karena payrollData.periodStartDate pasti DateTime
    
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
                payrollData.userName,
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              // Tampilkan Nominal Gaji
              Text(
                currencyFormatter.format(payrollData.unpaidAmount).replaceAll(',', '.'),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
              ),
              // Tambahkan keterangan total counts sebagai info
              Text(
                "Total jam: ${payrollData.totalUnpaidCounts * 2} jam",
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),

          // Tombol Aksi
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // Meneruskan objek Model ke halaman detail
                Navigator.push(
                  context, 
                  createRoute(DetailGajiPage(payrollData: payrollData)), 
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