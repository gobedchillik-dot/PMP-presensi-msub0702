import 'package:flutter/material.dart';
import '../pages/profil/index.dart'; // Ganti 'your_app' dengan nama project kamu

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String employeeName;
  final bool isPresentToday;
  final VoidCallback? onAvatarTap;

  const TopBar({
    super.key,
    required this.employeeName,
    required this.isPresentToday,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: const Color(0xFF152A45),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bagian kiri: salam dan status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hai, $employeeName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isPresentToday ? Icons.check_circle : Icons.cancel,
                      color: isPresentToday ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPresentToday
                          ? 'Hadir hari ini'
                          : 'Belum mengisi daftar hadir hari ini',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Avatar + menu popup
            PopupMenuButton<String>(
              color: const Color(0xFF1F3B5B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white30,
                child: Icon(
                  Icons.person,
                  size: 26,
                  color: Colors.white,
                ),
              ),
              onSelected: (value) {
                if (value == 'profil') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilIndexPage(),
                    ),
                  );
                } else if (value == 'keluar') {
                  // Nanti diisi aksi logout
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profil',
                  child: Row(
                    children: const [
                      Icon(Icons.account_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Profil',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'keluar',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Keluar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
