import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({super.key});

  @override
  State<FilterBar> createState() => FilterBarState();
}

class FilterBarState extends State<FilterBar> {
  int selected = 3; // default: 1 Bulan

  final filters = ["Semua", "Hari ini", "7 Hari", "1 Bulan"];

  @override
  Widget build(BuildContext context) {
    // Kami menggunakan Builder di HomePage untuk mengemas _FilterBar,
    // jadi animasi keseluruhan sudah dikerjakan di sana.
    // Animasi internal untuk tombol-tombol di sini dapat dipertahankan.
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