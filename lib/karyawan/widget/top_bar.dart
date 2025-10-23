import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final String title;
  final bool showBack; // ✅ tambahan
  final Color backgroundColor;

  const TopBar({
    super.key,
    required this.onMenuTap,
    this.title = '',
    this.showBack = false, // default = false agar tidak wajib diisi
    this.backgroundColor = const Color(0xFF152A45),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF16345A),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuTap,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // penting: Scaffold.appBar membutuhkan PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(56);
}
