import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:tes_flutter/auth/login_page.dart';
import 'package:tes_flutter/database/controller/absen/payroll_controller.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart'; 
import 'package:tes_flutter/database/controller/gmv/gmv_controller_extra.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart'; 
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        ChangeNotifierProvider(create: (_) => PengeluaranController()),
      ],
      child: const MaterialApp(
        // 💡 Tambahkan LocalizationsDelegates di MaterialApp
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
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