import 'package:flutter/material.dart';
import '../widget/top_bar.dart';
import '../widget/bottom_bar.dart';
import '../widget/side_bar.dart';

class BasePage extends StatefulWidget {
  final Widget child; // konten unik setiap halaman
  final String title; // judul halaman (opsional)
  const BasePage({super.key, required this.child, this.title = ''});

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

  void _closeSidebar() {
    if (_isSidebarVisible) {
      setState(() {
        _isSidebarVisible = false;
        _sidebarController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0E1A2A),
          appBar: TopBar(onMenuTap: _toggleSidebar, title: widget.title),
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

        // === SIDEBAR OVERLAY ===
        AnimatedBuilder(
          animation: _sidebarController,
          builder: (context, child) {
            double slide = 250 * _sidebarController.value;
            double opacity = _sidebarController.value * 0.5;
            return Stack(
              children: [
                if (_isSidebarVisible)
                  GestureDetector(
                    onTap: _closeSidebar,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(color: Colors.black54),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(slide - 250, 0),
                  child: SideBar(
                    isOpen: _isSidebarVisible,
                    onClose: _toggleSidebar,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
