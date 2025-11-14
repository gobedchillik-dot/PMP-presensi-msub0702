import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../karyawan/widget/alert_data.dart'; // ⚠️ ganti 'your_project_name' sesuai nama proyekmu
import '../karyawan/pages/profil/index.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('tbl_user')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      throw Exception("Gagal login: $e");
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('tbl_user').doc(user.uid).get();
    return doc.data();
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔹 Fungsi untuk mengecek kelengkapan data profil
  static Future<void> checkUserProfileCompleteness(BuildContext context) async {
    final data = await getCurrentUserData();
    if (data == null) return;

    // Field wajib diisi
    final requiredFields = ['name', 'panggilan', 'alamat', 'nohp', 'norek', 'bank'];

    // Cek apakah ada yang kosong (null atau string kosong)
    bool incomplete = requiredFields.any((field) {
      final value = data[field];
      return value == null || value.toString().trim().isEmpty;
    });

    // Jika data belum lengkap, tampilkan alert
    if (incomplete && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDataWidget(
    onCompletePressed: () {
      Navigator.pop(context); // Tutup dialog dulu
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfilIndexPage(), // Ganti dengan halaman form profil lo
        ),
      );
    },

          onSkipPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }
  }
}
