// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/database/controller/absen/absen_controller.dart';
import '../pages/profil/index.dart';
import '../pages/keuangan/index.dart';
import '../pages/karyawan/index.dart'; // pastikan path ini sesuai struktur project kamu
import '../pages/gmv/index.dart'; // pastikan path ini sesuai struktur project kamu
import '../pages/absen/index.dart'; // pastikan path ini sesuai struktur project kamu
import 'package:tes_flutter/auth/auth_service.dart';
import 'package:tes_flutter/auth/login_page.dart';
import '../../utils/route_generator.dart';


class SideBar extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const SideBar({
    super.key,
    required this.isOpen,
    required this.onClose,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _isDataExpanded = true; // ✅ default langsung terbuka

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E3A5F),
      child: SafeArea(
        child: SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER ===
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Msub0702',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Administration',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24),

              // === MENU ITEMS ===
              Expanded(
                child: ListView(
                  children: [
                    // === MENU DATA (expandable) ===
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent, // hilangkan garis bawaan
                      ),
                      child: ExpansionTile(
                        collapsedIconColor: Colors.white,
                        iconColor: Colors.white,
                        initiallyExpanded: _isDataExpanded,
                        backgroundColor: const Color(0xFF244872),
                        onExpansionChanged: (expanded) {
                          setState(() => _isDataExpanded = expanded);
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.database, color: Colors.amber),
                        ),
                        title: const Text(
                          'Data',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        childrenPadding: const EdgeInsets.only(left: 40, bottom: 8),
                        children: [
                          _buildSubmenuItem(
                            "Data Karyawan",
                            LucideIcons.user,
                            () {
                              // ✅ Navigasi ke halaman KaryawanIndexPage
                    Navigator.push(
                        context,
                        createRoute(const KaryawanIndexPage()),
                    );
                              widget.onClose(); // sidebar otomatis tertutup
                            },
                          ),
                          _buildSubmenuItem(
                            "Data Absen",
                            LucideIcons.calendarCheck,
                            () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider(
      create: (_) => AbsenController(),
      child: const AbsenIndexPage(),
    ),
  ),
);

                              widget.onClose();
                            },
                          ),
                          _buildSubmenuItem(
                            "Data GMV",
                            LucideIcons.barChart3,
                            () {
                    Navigator.push(
                        context,
                        createRoute(const GmvIndexPage()),
                    );
                              widget.onClose();
                            },
                          ),
                        ],
                      ),
                    ),

                    // === MENU LAIN ===
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.dollarSign, color: Colors.green),
                      ),
                      title: const Text('Keuangan', style: TextStyle(color: Colors.white)),
                      onTap: () {
                    Navigator.push(
                        context,
                        createRoute(const KeuanganIndexPage()),
                    );
                        widget.onClose();
                      },
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.checkSquare, color: Colors.lightBlue),
                      ),
                      title: const Text('Validasi Absen', style: TextStyle(color: Colors.white)),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.user, color: Colors.blue),
                      ),
                      title: const Text('Profil', style: TextStyle(color: Colors.white)),
                      onTap: () {
                    Navigator.push(
                        context,
                        createRoute(const ProfilIndexPage()),
                    );
                        widget.onClose();
                      },
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24),

              // === LOGOUT ===
              ListTile(
                leading: const Icon(LucideIcons.logOut, color: Colors.red),
                title: const Text('Keluar', style: TextStyle(color: Colors.red)),
                onTap: () async {

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1F3B5B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: const Text(
                        'Konfirmasi Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Apakah Anda yakin ingin keluar?',
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
                    widget.onClose(); // tutup sidebar dulu
                    await AuthService.signOut(); // ✅ Logout dari Firebase

                    if (context.mounted) {
                    Navigator.push(
                        context,
                        reverseCreateRoute(const LoginPage()),
                    );
                    }
                  }
                },
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 16, left: 16),
                child: Text(
                  'powered by TIUCIC23',
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === WIDGET SUBMENU ===
  Widget _buildSubmenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 8,
      leading: Icon(icon, color: Colors.white70, size: 18),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
