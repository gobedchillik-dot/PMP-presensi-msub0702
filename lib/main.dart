import 'package:flutter/material.dart';
import 'karyawan/home_page.dart';
import 'admin/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: adminHomePage(),
    );
  }
}
