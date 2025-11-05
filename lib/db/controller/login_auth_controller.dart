import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart'; // pastikan path sesuai struktur proyekmu

class LoginAuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userCollection = 'tbl_user';

  /// Login, lalu kembalikan role pengguna.
  Future<String> login(String email, String password) async {
    // 1) Sign in
    UserCredential userCred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = userCred.user!.uid;

    // 2) Ambil dokumen user
    final doc = await _firestore.collection(_userCollection).doc(uid).get();

    if (!doc.exists) {
      throw Exception("Data user tidak ditemukan di Firestore!");
    }

    final data = doc.data();
    if (data == null) {
      throw Exception("Data user tidak valid.");
    }

    // 3) Konversi ke model dan kembalikan role
    final user = UserModel.fromFirestore(Map<String, dynamic>.from(data));
    return user.role;
  }

  /// Helper: ambil UserModel berdasarkan uid (bisa dipakai di banyak tempat)
  Future<UserModel> getUserByUid(String uid) async {
    final doc = await _firestore.collection(_userCollection).doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception("User tidak ditemukan.");
    }
    return UserModel.fromFirestore(Map<String, dynamic>.from(doc.data()!));
  }
}
