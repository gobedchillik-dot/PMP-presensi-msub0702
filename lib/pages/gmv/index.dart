import 'package:flutter/material.dart';
import '../base_page.dart';

class GmvIndexPage extends StatefulWidget {
  const GmvIndexPage({super.key});

  @override
  State<GmvIndexPage> createState() => _GmvIndexPageState();
}

class _GmvIndexPageState extends State<GmvIndexPage> {
  final List<Map<String, dynamic>> dummyData = [
    {
      'id': 'GMV-001',
      'tanggal': '2025-10-21',
      'total': 1250000,
      'status': 'Selesai',
    },
    {
      'id': 'GMV-002',
      'tanggal': '2025-10-20',
      'total': 890000,
      'status': 'Menunggu',
    },
    {
      'id': 'GMV-003',
      'tanggal': '2025-10-19',
      'total': 650000,
      'status': 'Selesai',
    },
  ];

  String formatRupiah(int number) {
    return "Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Data GMV",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daftar Transaksi GMV",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // === LIST DATA ===
          ListView.builder(
            itemCount: dummyData.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final data = dummyData[index];
              final bool selesai = data['status'] == 'Selesai';
              return Card(
                color: const Color(0xFF152A46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: selesai ? Colors.green : Colors.orange,
                    child: Icon(
                      selesai ? Icons.check : Icons.timer,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['id'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Tanggal: ${data['tanggal']}\nTotal: ${formatRupiah(data['total'])}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  trailing: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          selesai ? Colors.greenAccent.shade400 : Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      // === LOGIKA DETAIL DUMMY ===
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1E2F4D),
                          title: Text("Detail ${data['id']}",
                              style: const TextStyle(color: Colors.white)),
                          content: Text(
                            "Tanggal: ${data['tanggal']}\n"
                            "Total Transaksi: ${formatRupiah(data['total'])}\n"
                            "Status: ${data['status']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup", style: TextStyle(color: Colors.blueAccent)),
                            )
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      "Detail",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
