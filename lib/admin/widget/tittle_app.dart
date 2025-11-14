import 'package:flutter/material.dart';
import 'package:tes_flutter/utils/route_generator.dart'; 

class CustomAppTitle extends StatelessWidget {
  final String title;
  // Halaman tujuan saat tombol kembali ditekan. Jika null, akan menggunakan Navigator.pop.
  final Widget? backToPage; 

  const CustomAppTitle({
    super.key,
    required this.title,
    this.backToPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (backToPage != null) {
              Navigator.push(
                context,
                reverseCreateRoute(backToPage!),
              );
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}