import 'package:flutter/material.dart';
import '../../home_page.dart';
// Import BasePage (asumsi path ini benar dari pages/profil/index.dart)
import '../../../base_page.dart'; 
// Import AnimatedFadeSlide
import '../../widget/animated_fade_slide.dart'; 

class ProfilIndexPage extends StatelessWidget {
  const ProfilIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Diasumsikan BasePage menangani background color (biasanya gelap)
    return BasePage(
      // Judul BasePage akan kosong jika tombol 'Back' & 'Profil' dihandle di dalam child
      title: 'Profil', 
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding untuk menggantikan area BasePage header/title bar
            const SizedBox(height: 8), 

            // 1. Header (Tombol Kembali & Judul) - Delay 0.1
            AnimatedFadeSlide(
              delay: 0.1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const adminHomePage(),
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
                    "Profil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 2. Foto Profil & Nama - Delay 0.2
            Center(
              child: AnimatedFadeSlide(
                delay: 0.2,
                child: Column(
                  children: [
                    // Lingkaran Foto Profil
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white12, // Placeholder
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Msub0702 Official",
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Admin",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tombol Sesuaikan Profil
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigasi ke halaman edit profil
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00ADB5), // Warna Tombol
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        "Sesuaikan profil",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 3. Bio Data Section - Delay 0.3
            AnimatedFadeSlide(
              delay: 0.3,
              child: const _ProfileSection(
                title: "Bio data",
                children: [
                  _DataRow(label: "Nama lengkap", value: "Admin"),
                  _DataRow(label: "Panggilan", value: "Admin"),
                  _DataRow(label: "Alamat", value: "Bojong, cilimus, kuningan", isMultiLine: true),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 4. Perbankan Section - Delay 0.4
            AnimatedFadeSlide(
              delay: 0.4,
              child: const _ProfileSection(
                title: "Perbankan",
                children: [
                  _DataRow(label: "Nomor rekening", value: "xxxxxxxxx"),
                  _DataRow(label: "Bank", value: "BCA"),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            // 5. Kontak Section - Delay 0.5
            AnimatedFadeSlide(
              delay: 0.5,
              child: const _ProfileSection(
                title: "Kontak",
                isSimple: true, // Untuk menghilangkan padding luar section
                children: [
                  _SimpleCard(
                    label: "Nomor hp",
                    value: "089765885",
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // 6. Tombol Keluar - Delay 0.6
            AnimatedFadeSlide(
              delay: 0.6,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implementasi Logout
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anda telah keluar.'), duration: Duration(milliseconds: 800)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Warna Merah
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
//                   WIDGET PEMBANTU
// ====================================================================

// Wrapper untuk setiap bagian (Bio data, Perbankan, dll.)
class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isSimple; // Untuk bagian yang hanya memiliki satu card (Kontak)

  const _ProfileSection({
    required this.title,
    required this.children,
    this.isSimple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Jika isSimple true (seperti Kontak), tidak ada padding/background box
        isSimple
            ? Column(children: children)
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46), // Warna box data
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: children),
              ),
      ],
    );
  }
}

// Widget untuk menampilkan sepasang data (Label dan Nilai) dalam format terstruktur
class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiLine;

  const _DataRow({
    required this.label,
    required this.value,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120, // Lebar tetap untuk label agar titik dua sejajar
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const Text(
            " : ",
            style: TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
              maxLines: isMultiLine ? 3 : 1,
              overflow: isMultiLine ? TextOverflow.ellipsis : TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk satu data dalam card khusus (digunakan untuk Kontak)
class _SimpleCard extends StatelessWidget {
  final String label;
  final String value;

  const _SimpleCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}