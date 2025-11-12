// lib/admin/widget/tabel_gmv.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/model/gmv.dart';

class TabelGmv extends StatelessWidget {
  const TabelGmv({super.key});

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

          // === STREAMBUILDER FIRESTORE ===
          StreamBuilder<List<GmvModel>>(
            stream: context.watch<GmvController>().gmvStream,
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
                    "Belum ada data GMV",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              final data = snapshot.data!;
              final dateFormat = DateFormat('dd-MM-yyyy');

              return Column(
                children: List.generate(data.length, (index) {
                  final gmv = data[index];
                  final formattedGmv = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(gmv.gmv);

                  final profit = (gmv.gmv * 5) / 100;
                  final formattedProfit = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(profit);

                  return Padding(
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
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
