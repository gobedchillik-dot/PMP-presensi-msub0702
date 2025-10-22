import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'base_page.dart';
import 'karyawan/index.dart'; // ✅ pastikan path ini sesuai dengan struktur project kamu
import 'gmv/index.dart'; // ✅ pastikan path ini sesuai dengan struktur project kamu

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Beranda',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header =====
            Text(
              "Dashboard",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

            const SizedBox(height: 16),

            // ===== Statistik Cards (Vertikal - Fleksibel) =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatCard(
                  title: "Pendapatan",
                  subtitle: "Rp 1.234.567,89",
                  color: Colors.greenAccent.shade400,
                  icon: Iconsax.money_4,
                    onTap: () {
                        Navigator.of(context).push(createRoute(const GmvIndexPage()));
                      },
                ),
                const SizedBox(height: 12),
                _StatCard(
                  title: "Validasi Kehadiran",
                  subtitle: "1.234 data",
                  color: Colors.blueAccent.shade400,
                  icon: Iconsax.user_tick,
                ),
                const SizedBox(height: 12),
                _StatCard(
                  title: "Data Karyawan",
                  subtitle: "123 Pekerja",
                  color: Colors.amberAccent.shade400,
                  icon: Iconsax.people,
                  onTap: () {
                    Navigator.of(context).push(createRoute(const KaryawanIndexPage()));
                  },
                ),
              ],
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // ===== Rekap Penjualan =====
            Text(
              "Rekap Penjualan",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "Periode: 1 Oktober – 31 Oktober 2025",
              style: TextStyle(color: Colors.grey.shade400),
            ),

            const SizedBox(height: 12),

            _FilterBar(),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A3A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Belum ada data",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ).animate().fadeIn(duration: 1000.ms),

            const SizedBox(height: 24),

            // ===== Absen Tracker =====
            Text(
              "Absen Tracker",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            _ProgressItem(name: "Karyawan 1", value: 0.5),
            _ProgressItem(name: "Karyawan 2", value: 0.75),
            _ProgressItem(name: "Karyawan 3", value: 1.0),
          ],
        ),
      ),
    );
  }
}

// ===== Widget Card Statistik =====
class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2A3A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Filter Bar (Semua | Hari ini | 7 Hari | 1 Bulan) =====
class _FilterBar extends StatefulWidget {
  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  int selected = 3; // default: 1 Bulan

  final filters = ["Semua", "Hari ini", "7 Hari", "1 Bulan"];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters.asMap().entries.map((entry) {
        final i = entry.key;
        final text = entry.value;
        final active = selected == i;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? Colors.blueAccent.shade400
                    : Colors.transparent,
                border: Border.all(color: Colors.blueAccent.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: active ? Colors.white : Colors.blueAccent.shade200,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===== Progress Tracker Item =====
class _ProgressItem extends StatelessWidget {
  final String name;
  final double value;

  const _ProgressItem({
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blueAccent.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Fungsi Route Fleksibel =====
Route createRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // slide dari kanan
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

