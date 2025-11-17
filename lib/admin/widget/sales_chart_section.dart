import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/model/gmv.dart';

class SalesChartSection extends StatelessWidget {
  const SalesChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch Controller untuk mendapatkan status filter dan rentang tanggal
    final gmvController = context.watch<GmvController>();
    final startDate = gmvController.startDate; // 💡 Ambil tanggal awal
    final endDate = gmvController.endDate; // 💡 Ambil tanggal akhir

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2A3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: StreamBuilder<List<GmvModel>>(
            stream: gmvController.filteredGmvStream, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Tampilan default jika tidak ada data sama sekali dalam periode tersebut
                return const Center(
                  child: Text(
                    "Tidak ada data GMV dalam periode ini.",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              final data = snapshot.data!;
              
              // 🎯 LOGIKA FILTER "HARI INI"
              if (gmvController.isChartFilterToday) {
                final totalGmv = data.fold<double>(0.0, (sum, item) => sum + item.gmv);

                if (totalGmv == 0) {
                    return const Center(
                      child: Text(
                        "Tidak ada transaksi GMV pada hari ini.",
                        style: TextStyle(color: Colors.white54, fontSize: 18),
                      ),
                    );
                }
                
                final numberFormat = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Total GMV Hari Ini:",
                          style: TextStyle(fontSize: 16, color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          numberFormat.format(totalGmv),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // ----------------------------------------------------
              // TAMPILAN GRAFIK UNTUK periode > 1 hari
              // ----------------------------------------------------
              
              // Urutkan data berdasarkan tanggal secara menaik untuk chart yang benar
              data.sort((a, b) => a.tanggal.toDate().compareTo(b.tanggal.toDate())); 

              return SfCartesianChart(
                backgroundColor: Colors.transparent,
                primaryXAxis: DateTimeAxis( // 💡 Gunakan DateTimeAxis
                  // 🎯 SOLUSI UTAMA: Mengatur batas minimum dan maksimum
                  minimum: startDate, // Memaksa sumbu dimulai dari filter startDate
                  maximum: endDate, // Memaksa sumbu berakhir di filter endDate
                  
                  labelStyle: const TextStyle(color: Colors.white),
                  dateFormat: DateFormat('dd MMM'),
                  intervalType: DateTimeIntervalType.days,
                  interval: (startDate != null && endDate != null && endDate.difference(startDate).inDays > 14)
                      ? 7.0 
                      : 1.0, 
                  // Sembunyikan label jika filter "Semua" (optional, tapi disarankan jika tidak ada data)
                  isVisible: startDate != null && endDate != null, 
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  numberFormat: NumberFormat.compactSimpleCurrency(locale: 'id', name: 'Rp'), 
                ),
                series: <LineSeries<GmvModel, DateTime>>[
                  LineSeries<GmvModel, DateTime>(
                    dataSource: data,
                    xValueMapper: (gmv, _) => gmv.tanggal.toDate(),
                    yValueMapper: (gmv, _) => gmv.gmv,
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}