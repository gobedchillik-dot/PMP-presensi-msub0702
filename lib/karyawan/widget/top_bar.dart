import 'package:flutter/material.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../pages/profil/index.dart';
import 'package:tes_flutter/auth/auth_service.dart';
import 'package:tes_flutter/auth/login_page.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String employeeName;
  // Catatan: Nama parameter di BasePage diubah menjadi isPresentToday (String)
  // namun di TopBar Anda menggunakan isTodayStatusMessage, saya akan menggunakannya
  // sebagai teks pesan status dinamis.
  final String isTodayStatusMessage; 
  final bool isPresentToday; // Digunakan untuk warna dan ikon
  final VoidCallback? onAvatarTap;

  const TopBar({
    super.key,
    required this.employeeName,
    required this.isTodayStatusMessage,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hai, $employeeName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
                      Flexible(
                        child: Text(
                          // <-- PERUBAHAN UTAMA: Menggunakan pesan status dinamis
                          isTodayStatusMessage,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                        createRoute(const ProfilIndexPage()),
                    );
                } else if (value == 'keluar') {
                  _handleLogout(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profil',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Profil', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'keluar',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Keluar', style: TextStyle(color: Colors.white)),
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

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F3B5B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.signOut();
      if (context.mounted) {
                    Navigator.push(
                        context,
                        reverseCreateRoute(const LoginPage()),
                    );
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(101);
}