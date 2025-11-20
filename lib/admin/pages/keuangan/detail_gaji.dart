// File: lib/admin/pages/keuangan/detail_gaji.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/pages/keuangan/index.dart';
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/model/unpaid_gaji.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';

class DetailGajiPage extends StatelessWidget {
  // Wajib menerima data Model di konstruktor
  final UnpaidSalaryModel payrollData; 

  const DetailGajiPage ({
    required this.payrollData,
    super.key
  });

  // Helper untuk format mata uang
  String _formatMoney(double number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0, 
    );
    return formatter.format(number).replaceAll(',', '.');
  }

  // Helper untuk format tanggal
  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  // Helper untuk memicu pembayaran
  Future<void> _handlePayment(BuildContext context) async {
    final payrollController = context.read<PayrollController>();

    try {
      await payrollController.processPayment(payrollData: payrollData);
      
      // Tampilkan notifikasi sukses
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pembayaran Gaji untuk ${payrollData.userName} berhasil dicatat!')),
        );
        // Kembali ke halaman index setelah sukses
        Navigator.pop(context); 
      }
    } catch (e) {
      // Tampilkan notifikasi error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Memproses Pembayaran: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Pastikan locale Indonesia sudah diinisialisasi
    Intl.defaultLocale = 'id_ID';
    
    final String formattedAmount = _formatMoney(payrollData.unpaidAmount);
    final String formattedStartDate = _formatDate(payrollData.periodStartDate);
    final String formattedEndDate = _formatDate(payrollData.periodEndDate);

    return BasePage(
      title: "Pembayaran Gaji - ${payrollData.userName}",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('detailGajiScroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AnimatedFadeSlide(
              delay: 0.1,
              child:
              CustomAppTitle(
                title: "Pembayaran Gaji",
                backToPage: const KeuanganIndexPage(),
              )
            ),
            const SizedBox(height: 20),

            // Card Rangkuman Pembayaran
            AnimatedFadeSlide(
              delay: 0.3,
              child: ProfileSectionWrapper(
                title: "Rincian Pembayaran",
                children: [
                  ProfileDataRow(
                    label: "Nama Karyawan", 
                    value: payrollData.userName
                  ),
                  const Divider(color: Colors.white30),
                  ProfileDataRow(
                    label: "Periode Gaji (Mulai)", 
                    value: formattedStartDate
                  ),
                  ProfileDataRow(
                    label: "Periode Gaji (Akhir)", 
                    value: formattedEndDate
                  ),
                  const Divider(color: Colors.white30),
                  ProfileDataRow(
                    label: "Total Sesi Kehadiran", 
                    value: '${payrollData.totalUnpaidCounts} Sesi kehadiran'
                  ),
                  ProfileDataRow(
                    label: "Total Jam Kerja", 
                    value: '${payrollData.totalUnpaidCounts * 2} Jam' // Asumsi 1 Count = 2 Jam
                  ),
                  const Divider(color: Colors.white30),
                  ProfileDataRow(
                    label: "TOTAL GAJI DIBAYAR", 
                    value: formattedAmount,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Bayar
            AnimatedFadeSlide(
              delay: 0.5,
              child: SizedBox(
                width: double.infinity,
                child: Consumer<PayrollController>(
                  builder: (context, controller, child) {
                    return ElevatedButton.icon(
                      onPressed: () => _handlePayment(context),
                      icon: const Icon(Icons.payment, color: Colors.black),
                      label: Text(
                        "Konfirmasi Pembayaran $formattedAmount",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}