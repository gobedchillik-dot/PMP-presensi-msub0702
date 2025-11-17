import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/model/gmv.dart';

class TabelGmv extends StatelessWidget {
  const TabelGmv({super.key});

  // Tentukan tinggi baris (perkiraan)
  static const double _rowHeight = 40.0; 
  // Batas data yang ingin ditampilkan sebelum scroll
  static const int _maxDataToShow = 10; 
  // Tinggi maksimum Container (10 baris * tinggi baris + padding)
  static const double _maxContainerHeight = _maxDataToShow * _rowHeight + 16; 

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header kolom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Tanggal", style: TextStyle(color: Colors.white)),
              Text("GMV", style: TextStyle(color: Colors.white)),
              Text("Est. Profit", style: TextStyle(color: Colors.white)),
            ],
          ),
          const Divider(color: Colors.white30),

          // === STREAMBUILDER FIRESTORE (DIFILTER) ===
          StreamBuilder<List<GmvModel>>(
            stream: context.watch<GmvController>().filteredGmvStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Tidak ada data GMV dalam periode ini.",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              final data = snapshot.data!;
              final dateFormat = DateFormat('dd-MM-yyyy');

              // Hitung tinggi container
              // Jika data kurang dari 10, gunakan tinggi yang cukup untuk semua data
              // Jika data lebih dari 10, gunakan tinggi maksimum yang telah ditentukan
              final double actualHeight = data.length * _rowHeight;
              final double containerHeight = (actualHeight < _maxContainerHeight)
                  ? actualHeight
                  : _maxContainerHeight;


              // 🎯 PERUBAHAN UTAMA: Batasi tinggi dan gunakan ListView.builder
              return Container(
                height: containerHeight, // Batasi tinggi
                child: ListView.builder(
                  // Non-aktifkan scroll jika tabel induk sudah SingleChildScrollView (untuk menghindari "scrollception")
                  // Namun karena ini adalah batas tinggi, kita aktifkan scroll untuk data di atas batas.
                  physics: (data.length > _maxDataToShow) 
                      ? const AlwaysScrollableScrollPhysics() 
                      : const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final gmv = data[index];
                    final formattedGmv = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(gmv.gmv);

                    // Logika Est. Profit tetap (5% dari GMV)
                    final profit = (gmv.gmv * 5) / 100; 
                    final formattedProfit = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(profit);

                    // ⚠️ Pastikan height Row mendekati _rowHeight (40.0)
                    return SizedBox(
                      height: _rowHeight, 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormat.format(gmv.tanggal.toDate()),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(formattedGmv,
                                style: const TextStyle(color: Colors.white)),
                            Text(formattedProfit,
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}