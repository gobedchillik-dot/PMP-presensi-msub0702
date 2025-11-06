import 'package:flutter/material.dart';
import 'package:tes_flutter/utils/route_generator.dart';
// Import wajib untuk animasi:
import '../../../utils/animated_fade_slide.dart'; 
import '../../base_page.dart'; 
// Import wajib untuk navigasi tombol back:
import '../../home_page.dart'; 

class KeuanganIndexPage extends StatefulWidget {
  const KeuanganIndexPage({super.key});

  @override
  State<KeuanganIndexPage> createState() => _KeuanganIndexPageState();
}

class _KeuanganIndexPageState extends State<KeuanganIndexPage> {

  final List<Map<String, dynamic>> weeklySummary = [
    {'minggu': 1, 'total': 1300000000, 'isUp': true},
    {'minggu': 2, 'total': 1300000000, 'isUp': false},
    {'minggu': 3, 'total': 1300000000, 'isUp': false},
    {'minggu': 4, 'total': 1300000000, 'isUp': true},
  ];

  String formatMoney(int number) {
    if (number >= 1000000000) {
      // Jika di atas 1 Miliar (untuk kartu summary)
      double billions = number / 1000000000;
      return "Rp ${billions.toStringAsFixed(1).replaceAll('.', ',')} M";
    }
    // Untuk tampilan detail (Ribuan separator)
    return "Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
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


  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Keuangan",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('keuanganIndexScroll'), 
        child: Column(
          key: const Key('keuanganIndexColumn'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // ===== 1. CUSTOM TITLE & BACK BUTTON (Delay 0.1) =====
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
                    "Keuangan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              )
            ),
            AnimatedFadeSlide(
              delay: 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  const Text(
                    "Rangkuman keuangan",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ]
              )
            ),
            const SizedBox(height: 12),
                  AnimatedFadeSlide(
                    delay: 0.3,
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
                              Text("Est. Pemasukan", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Gaji karyawan", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Operasional", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const Divider(color: Colors.white30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Total pengeluaran", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Total keuntungan", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),

                          // === LIST KARYAWAN (DUMMY DATA) ===
                      
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 24),

            // ===== 4. KUARTAL GMV MINGGUAN (Weekly Summary Cards) (Delay 0.3) =====
            AnimatedFadeSlide(
              delay: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  const Text(
                    "Est. Pemasukan GMV",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Total : Rp 123.456.789",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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

            // ===== ✅ KARTU GAJI KARYAWAN (New Section) (Delay 0.5) =====
            AnimatedFadeSlide(
              delay: 0.5,
              child: const _EmployeeSalaryCard(initialDelay: 0.5), // Meneruskan delay untuk staggered item
            ),
            const SizedBox(height: 24),
            
            // ===== 5. PENGELUARAN OPERASIONAL (Tabs dan Tabel) (Delay 0.7) =====
            AnimatedFadeSlide(
              delay: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pengeluaran operasional",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Total : Rp 123.456.789",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 8),
                  // Tombol Edit/Tambah Data (Delay 0.9)
                  AnimatedFadeSlide(
                    delay: 0.7,
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
                  const SizedBox(height: 12),
                  // Detail Operasional (Delay 1.1)
                  AnimatedFadeSlide(
                    delay: 0.8,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF152A46),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Est. Pemasukan", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Gaji karyawan", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Operasional", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Divider(color: Colors.white30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total pengeluaran", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total keuntungan", style: TextStyle(color: Colors.white)),
                              Text(":", style: TextStyle(color: Colors.white)),
                              Text("Rp 123.456.789", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // 
          ],
          
        )
      )
    );
  }
}

// ====================================================================
//                   WIDGET BARU UNTUK GAJI KARYAWAN
// ====================================================================

// Definisi data dummy untuk daftar gaji
class EmployeeSalary {
  final String name;
  final String salary;

  EmployeeSalary(this.name, this.salary);
}

// Data Dummy Karyawan
final List<EmployeeSalary> dummySalaries = [
  EmployeeSalary("Karyawan 1", "Rp 1.234.567"),
  EmployeeSalary("Karyawan 2", "Rp 1.234.567"),
  EmployeeSalary("Karyawan 3", "Rp 1.234.567"),
  EmployeeSalary("Karyawan 4", "Rp 1.234.567"),
  EmployeeSalary("Karyawan 5", "Rp 1.234.567"),
  EmployeeSalary("Karyawan 6", "Rp 1.234.567"),
  EmployeeSalary("Karyawan 7", "Rp 1.234.567"),
  EmployeeSalary("Karyawan 8", "Rp 1.234.567"),
];

// Widget untuk setiap baris gaji karyawan
class _SalaryListItem extends StatelessWidget {
  final String name;
  final String salary;

  const _SalaryListItem({required this.name, required this.salary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C385C), // Warna card item
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
              Text(
                salary,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          // Tombol Aksi
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementasi logika bayar gaji
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Membayar gaji untuk $name'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5), // Warna tombol
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

// Widget utama Pengeluaran Gaji Karyawan
class _EmployeeSalaryCard extends StatelessWidget {
  final double initialDelay; // Delay awal dari AnimatedFadeSlide pembungkus

  const _EmployeeSalaryCard({required this.initialDelay});

  @override
  Widget build(BuildContext context) {
    const String totalPengeluaran = "Rp 12.345.678";

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
          // Header
          Text(
            "Pengeluaran gaji karyawan",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Total : $totalPengeluaran",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 12),

          // Daftar Karyawan yang Dapat Digulir (Scrollable List)
          SizedBox(
            // Tinggi 3 item karyawan
            height: 3 * 80.0, 
            child: ListView.builder(
              padding: EdgeInsets.zero, // Hapus padding default ListView
              physics: const ClampingScrollPhysics(), // Memastikan scroll halus di dalam SingleChildScrollView
              itemCount: dummySalaries.length,
              itemBuilder: (context, index) {
                final employee = dummySalaries[index];

                // AnimatedFadeSlide untuk setiap item (Staggered List)
                return AnimatedFadeSlide(
                  // Delay awal + penambahan 100ms per item untuk efek staggered
                  delay: 0.9,
                  duration: const Duration(milliseconds: 600),
                  child: _SalaryListItem(
                    name: employee.name,
                    salary: employee.salary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}