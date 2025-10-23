import 'package:flutter/material.dart';
import 'widget/top_bar.dart';
import 'widget/bottom_bar.dart';

class BasePage extends StatefulWidget {
  final Widget child; // konten unik setiap halaman
  final String title; // nama karyawan
  final bool isPresentToday; // status kehadiran
  const BasePage({
    super.key,
    required this.child,
    required this.title,
    required this.isPresentToday,
  });

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage>
    with SingleTickerProviderStateMixin {
  bool _isSidebarVisible = false;
  late AnimationController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
      if (_isSidebarVisible) {
        _sidebarController.forward();
      } else {
        _sidebarController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0E1A2A),
          
          // ✅ TopBar versi baru
          appBar: TopBar(
            employeeName: widget.title,
            isPresentToday: widget.isPresentToday,
            onAvatarTap: _toggleSidebar, // aksi ketika avatar ditekan
          ),
          
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight, // isi penuh layar
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // === BODY ===
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: widget.child,
                        ),

                        // === FOOTER (selalu di dasar) ===
                        const BottomBar(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
