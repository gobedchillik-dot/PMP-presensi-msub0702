import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/pages/gmv/add.dart';
import 'package:tes_flutter/admin/pages/gmv/edit.dart';
import 'package:tes_flutter/db/controller/gmv_controller.dart';
import 'package:tes_flutter/db/model/gmv.dart';
import 'package:tes_flutter/utils/route_generator.dart';

// Import wajib untuk animasi:
import '../../../utils/animated_fade_slide.dart';

// Import wajib untuk navigasi tombol back:
import '../../base_page.dart';
import '../../home_page.dart';

class GmvIndexPage extends StatefulWidget {
  const GmvIndexPage({super.key});

  @override
  State<GmvIndexPage> createState() => _GmvIndexPageState();
}

class _GmvIndexPageState extends State<GmvIndexPage> {
  // Dummy Data untuk Summary Mingguan
  final List<Map<String, dynamic>> weeklySummary = [
    {'minggu': 1, 'total': 1300000000, 'isUp': true},
    {'minggu': 2, 'total': 1300000000, 'isUp': false},
    {'minggu': 3, 'total': 1300000000, 'isUp': false},
    {'minggu': 4, 'total': 1300000000, 'isUp': true},
  ];

  String selectedPeriod = '1 Bulan';
  String selectedQuarter = 'M4';

  // Fungsi untuk format uang
  String formatMoney(int number) {
    if (number >= 1000000000) {
      double billions = number / 1000000000;
      return "Rp ${billions.toStringAsFixed(1).replaceAll('.', ',')} M";
    }
    return "Rp ${number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => "${m[1]}.",
    )}";
  }

  // Widget kartu summary mingguan
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
                formatMoney(data['total']),
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
      title: "Data GMV",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('gmvIndexScroll'),
        child: Column(
          key: const Key('gmvIndexColumn'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 1. CUSTOM TITLE & BACK BUTTON =====
            AnimatedFadeSlide(
              delay: 0.1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        reverseCreateRoute(const adminHomePage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Data GMV",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),


            // ===== 3. GRAFIK GMV =====
            AnimatedFadeSlide(
              delay: 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grafik GMV",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Periode : 1 Oktober - 31 Oktober 2025",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Hari ini', '7 Hari', '1 Bulan']
                          .map(
                            (period) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => selectedPeriod = period),
                                style: TextButton.styleFrom(
                                  backgroundColor: selectedPeriod == period
                                      ? const Color(0xFF3366CC)
                                      : const Color(0xFF1E2F4D),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  period,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2F4D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Belum ada data",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== 4. KUARTAL GMV MINGGUAN =====
            AnimatedFadeSlide(
              delay: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kuartal GMV Mingguan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
            AnimatedFadeSlide(
              delay: 0.2,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                        context,
                        createRoute(const EditGmvPage()),
                    );
                      },
                      icon: const Icon(Icons.edit, color: Colors.black),
                      label: const Text("Edit data"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {                      
                        Navigator.push(
                        context,
                        createRoute(const AddGmvPage()),
                    );
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.black),
                      label: const Text("Tambah data"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== 5. DATA GMV (DARI FIRESTORE) =====
            AnimatedFadeSlide(
              delay: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data GMV",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Periode : 20 Oktober - 30 Oktober 2025",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // PILIHAN KUARTAL
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['M1', 'M2', 'M3', 'M4']
                          .map(
                            (quarter) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => selectedQuarter = quarter),
                                style: TextButton.styleFrom(
                                  backgroundColor: selectedQuarter == quarter
                                      ? const Color(0xFF3366CC)
                                      : const Color(0xFF1E2F4D),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  quarter,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CARD DATA GMV
                  AnimatedFadeSlide(
                    delay: 0.4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF152A46),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Tanggal",
                                  style: TextStyle(color: Colors.white)),
                              Text("GMV",
                                  style: TextStyle(color: Colors.white)),
                              Text("Est. Profit",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const Divider(color: Colors.white30),

                          // === STREAMBUILDER FIRESTORE ===
                          StreamBuilder<List<GmvModel>>(
                            stream: context.watch<GmvController>().gmvStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    "Belum ada data GMV",
                                    style:
                                        TextStyle(color: Colors.white54),
                                  ),
                                );
                              }

                              final data = snapshot.data!;
                              final dateFormat =
                                  DateFormat('dd-MM-yyyy');


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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dateFormat
                                              .format(gmv.tanggal.toDate()),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Text(
                                          formattedGmv,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Text(
                                          formattedProfit,
                                          style: TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
