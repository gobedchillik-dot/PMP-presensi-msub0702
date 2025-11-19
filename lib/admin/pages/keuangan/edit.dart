// File: lib/admin/pages/keuangan/edit.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../../utils/animated_fade_slide.dart'; 
import '../../base_page.dart'; 
import '../../../admin/widget/tittle_app.dart';
import './update.dart'; // Import halaman update

// Asumsi Konstanta Kategori
const String _kategoriOperasional = 'Operasional';

class KeuanganEditPage extends StatelessWidget {
  const KeuanganEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Edit & Hapus Pengeluaran",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFadeSlide(
              delay: 0.1, 
              child: CustomAppTitle(title: "Kelola Pengeluaran", backToPage: null)
            ),
            const SizedBox(height: 24),
            
            // --- Kartu Pengeluaran Operasional ---
            AnimatedFadeSlide(
              delay: 0.3,
              child: _ExpenseListCard(
                title: "Pengeluaran Operasional (Bulan Ini)",
                kategoriFilter: _kategoriOperasional,
              ),
            ),
            const SizedBox(height: 24),

            // --- Kartu Pengeluaran Lainnya ---
            AnimatedFadeSlide(
              delay: 0.5,
              child: _ExpenseListCard(
                title: "Pengeluaran Lainnya (Bulan Ini)",
                kategoriFilter: _kategoriOperasional, // Filter akan membalik logika di dalam widget
                isOther: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// WIDGET BANTU: Menampilkan Daftar Pengeluaran dengan Aksi
// ====================================================================

class _ExpenseListCard extends StatelessWidget {
  final String title;
  final String kategoriFilter;
  final bool isOther; // true jika menampilkan NON-operasional

  const _ExpenseListCard({
    required this.title,
    required this.kategoriFilter,
    this.isOther = false,
  });

  String _formatMoney(double number) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0, 
    );
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  // Fungsi untuk menampilkan konfirmasi hapus
  Future<void> _confirmDelete(BuildContext context, Pengeluaran expense) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus pengeluaran '${expense.deskripsi}' senilai ${_formatMoney(expense.nominal)}?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm && expense.id != null) {
      final controller = Provider.of<PengeluaranController>(context, listen: false);
      try {
        await controller.deleteExpense(expense.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengeluaran berhasil dihapus!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pengeluaran: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PengeluaranController, (List<Pengeluaran>, bool)>(
      // Logika Filter: Jika isOther=true, ambil yang TIDAK SAMA dengan kategoriFilter
      selector: (_, controller) => (
        controller.allExpenses.where(
          (e) => isOther 
            ? e.kategori != kategoriFilter 
            : e.kategori == kategoriFilter
        ).toList(), 
        controller.isLoading
      ),
      builder: (context, data, child) {
        final List<Pengeluaran> expenses = data.$1;
        final bool isLoading = data.$2;
        
        // Asumsi: Kita tidak menampilkan total di sini, hanya daftar.
        
        if (isLoading && expenses.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (expenses.isEmpty) {
          return Text("$title: Tidak ada data bulan ini.", style: const TextStyle(color: Colors.white70));
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF152A46),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              
              ...expenses.map((expense) { 
                final formattedValue = _formatMoney(expense.nominal);
                final formattedDate = DateFormat('dd/MM').format(expense.dateTime); 
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Kolom Detail
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${expense.deskripsi} - $formattedDate',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Kategori: ${expense.kategori}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      // Kolom Nominal
                      Text(
                        formattedValue,
                        style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                      ),
                      
                      const SizedBox(width: 12),

                      // Tombol Edit
                      InkWell(
                        onTap: () {
                          // 🔥 TRANSISI KE UPDATE.DART
                          Navigator.push(
                            context,
                            createRoute(KeuanganUpdatePage(existingExpense: expense),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.edit, color: Color(0xFF00ADB5), size: 20),
                        ),
                      ),

                      // Tombol Hapus
                      InkWell(
                        onTap: () => _confirmDelete(context, expense),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}