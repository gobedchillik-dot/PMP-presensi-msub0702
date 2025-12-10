import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tes_flutter/database/controller/CashflowController.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import '../../base_page.dart';

class CashflowHistoryPage extends StatelessWidget {
  CashflowHistoryPage({super.key});

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _formatMoney(double number) {
    return _currencyFormatter.format(number).replaceAll(',', '.');
  }

  Color _getTipeColor(String tipe) {
    return tipe == 'IN' ? Colors.green.shade400 : Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Histori Cashflow",
      child: Consumer<CashflowController>(
        builder: (context, controller, child) {
          final historyData = controller.cashflowHistory;

          // Asumsi: controller sudah mengambil data dari sumber.
          if (historyData.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada riwayat cashflow yang tercatat.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Halaman
              const CustomAppTitle(
                title: "Histori Cashflow",
                // Diasumsikan kembali ke KeuanganIndexPage
              ),
              const SizedBox(height: 20),

              // Total Saldo Saat Ini (Opsional, untuk konteks)
              Card(
                color: const Color(0xFF152A46),
                child: ListTile(
                  title: const Text(
                    "Est. Saldo Bersih Terkini",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    _formatMoney(controller.netCashflow),
                    style: TextStyle(
                      color: controller.netCashflow >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List Histori Cashflow
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final item = historyData[index];
                    final nominal = item['nominal'] as double;
                    final tipe = item['tipe'] as String;
                    final tanggal = item['tanggal'];

                    String formattedDate;
                    if (tanggal is String) {
                      try {
                        // Coba parsing tanggal string ke format yang lebih mudah dibaca
                        formattedDate = DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(tanggal));
                      } catch (e) {
                        // Jika gagal parsing, tampilkan apa adanya
                        formattedDate = tanggal;
                      }
                    } else if (tanggal is DateTime) {
                      formattedDate = DateFormat('dd MMM yyyy').format(tanggal);
                    } else {
                      formattedDate = "Tanggal Tidak Valid";
                    }

                    return Card(
                      color: const Color(0xFF152A46),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          tipe == 'IN' ? Icons.arrow_downward : Icons.arrow_upward,
                          color: _getTipeColor(tipe),
                        ),
                        title: Text(
                          item['deskripsi'] ?? item['kategori'] ?? 'Transaksi',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${item['kategori']} | $formattedDate",
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Text(
                          (tipe == 'OUT' ? '- ' : '+ ') + _formatMoney(nominal),
                          style: TextStyle(
                            color: _getTipeColor(tipe),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}