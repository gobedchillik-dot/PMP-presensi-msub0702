import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// 💡 TAMBAHKAN DUA IMPORTS INI
import 'package:intl/intl.dart'; 
import 'package:intl/date_symbol_data_local.dart'; 
// ===================================
import 'package:tes_flutter/auth/login_page.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart'; 
import 'package:tes_flutter/database/controller/gmv/gmv_controller_extra.dart'; 
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🎯 LANGKAH PENTING: INISIALISASI LOCALE
  // Ini harus dilakukan sebelum widget manapun yang menggunakan DateFormat dengan locale ('id_ID') di-build.
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID', null); 

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ⚠️ CATATAN PENTING TENTANG PROVIDER:
        // Jika GmvControllerExtra adalah controller lengkap, hapus GmvController
        ChangeNotifierProvider<GmvControllerExtra>(create: (_) => GmvControllerExtra()), 
        ChangeNotifierProvider(create: (_) => GmvController()), // Hapus baris ini jika GmvController tidak dipakai
        ChangeNotifierProvider(create: (_) => PayrollController()),
      ],
      child: const MaterialApp(
        // 💡 Tambahkan LocalizationsDelegates di MaterialApp
        localizationsDelegates: [
          // Anda mungkin perlu import flutter_localizations/flutter_localizations.dart
          // jika Anda menggunakan delegasi default
          // GlobalMaterialLocalizations.delegate,
          // GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', 'US'),
          Locale('id', 'ID'), 
        ],
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}