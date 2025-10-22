import 'package:flutter/material.dart';
// Import wajib untuk animasi:
import '../../widget/animated_fade_slide.dart'; 
import '../base_page.dart'; 
// Import wajib untuk navigasi tombol back:
import '../home_page.dart'; 

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

  // Fungsi untuk format uang: Rp X.XXX.XXX atau Rp X,X M
  String formatMoney(int number) {
    if (number >= 1000000000) {
      // Jika di atas 1 Miliar (untuk kartu summary)
      double billions = number / 1000000000;
      return "Rp ${billions.toStringAsFixed(1).replaceAll('.', ',')} M";
    }
    // Untuk tampilan detail (Ribuan separator)
    return "Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildActionButton(
      IconData icon, String text, Color color, BorderRadius borderRadius) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
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

  // --- WIDGET UTAMA ---

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
            // ===== 1. CUSTOM TITLE & BACK BUTTON (Delay 0.1) =====
            AnimatedFadeSlide(
              delay: 0.1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomePage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
                            final slide = Tween<Offset>(
                              begin: const Offset(-0.2, 0),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: fade,
                              child: SlideTransition(position: slide, child: child),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
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

            // ===== TOMBOL EDIT & TAMBAH DATA =====
            AnimatedFadeSlide(
              delay: 0.2,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
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
                      onPressed: () {},
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

            // ===== 3. GRAFIK GMV (Chart Placeholder) (Delay 0.3) =====
            AnimatedFadeSlide(
              delay: 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grafik GMV",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "periode : 1 Oktober - 31 Oktober 2025",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Hari ini', '7 Hari', '1 Bulan']
                          .map((period) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextButton(
                                  onPressed: () => setState(() => selectedPeriod = period),
                                  style: TextButton.styleFrom(
                                    backgroundColor: selectedPeriod == period
                                        ? const Color(0xFF3366CC)
                                        : const Color(0xFF1E2F4D),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(period, style: const TextStyle(color: Colors.white)),
                                ),
                              ))
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

            // ===== 4. KUARTAL GMV MINGGUAN (Weekly Summary Cards) (Delay 0.4) =====
            AnimatedFadeSlide(
              delay: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kuartal GMV mingguan",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

            // ===== 5. DATA GMV (Tabs dan Tabel) (Delay 0.5) =====
            AnimatedFadeSlide(
              delay: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data gmv",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "periode : 20 Oktober - 30 Oktober 2025",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['M1', 'M2', 'M3', 'M4']
                          .map((quarter) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextButton(
                                  onPressed: () => setState(() => selectedQuarter = quarter),
                                  style: TextButton.styleFrom(
                                    backgroundColor: selectedQuarter == quarter
                                        ? const Color(0xFF3366CC)
                                        : const Color(0xFF1E2F4D),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(quarter, style: const TextStyle(color: Colors.white)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== CARD DATA KARYAWAN =====
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
                              Text("Tanggal", style: TextStyle(color: Colors.white)),
                              Text("GMV", style: TextStyle(color: Colors.white)),
                              Text("Profit", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const Divider(color: Colors.white30),

                          // === LIST KARYAWAN (DUMMY DATA) ===
                          ...List.generate(7, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("01-10-2025 ${index + 1}",
                                      style: const TextStyle(color: Colors.white)),
                                  Text("Rp. 123.456.789 ${index + 1}",
                                      style: const TextStyle(color: Colors.white)),
                                  Text("Rp. 12.345.678 ${index + 1}",
                                      style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Spasi ekstra di bawah tabel
          ],
        ),
      ),
    );
  }
}
