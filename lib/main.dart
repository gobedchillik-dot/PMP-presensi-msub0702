import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:tes_flutter/auth/login_page.dart';
import 'package:tes_flutter/db/controller/gmv/gmv_controller.dart'; // Import GmvController
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Menggunakan MultiProvider di sini
    return MultiProvider(
      providers: [
        // 2. Mendaftarkan GmvController menggunakan ChangeNotifierProvider
        ChangeNotifierProvider(create: (_) => GmvController()),
        // Jika di masa depan ada Controller lain, tambahkan di sini
      ],
      // 3. MaterialApp sekarang menjadi child dari MultiProvider
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}