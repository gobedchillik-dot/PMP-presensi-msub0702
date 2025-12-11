import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';

class FilterBar extends StatelessWidget {
 const FilterBar({super.key});
 
 final filters = const ["Semua", "Hari ini", "7 Hari", "Bulan ini"];

 @override
 Widget build(BuildContext context) {
  // 🔥 Menggunakan watch untuk mendapatkan index yang aktif dari Controller
  final controller = context.watch<GmvController>();
  final selected = controller.selectedFilterIndex;
  
  return SingleChildScrollView(
   scrollDirection: Axis.horizontal,
   child: Row(
    children: filters.asMap().entries.map((entry) {
     final i = entry.key;
     final text = entry.value;
     final active = selected == i;

     return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
       // 🔥 Memanggil setFilter di Controller saat tombol ditekan
       onTap: () => context.read<GmvController>().setFilter(i),
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
   ),
  );
 }
}