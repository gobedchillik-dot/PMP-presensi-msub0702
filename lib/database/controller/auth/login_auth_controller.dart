import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user.dart'; // pastikan path sesuai struktur proyekmu

class LoginAuthController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userCollection = 'tbl_user';

  /// Login, lalu kembalikan role pengguna.
  Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    UserCredential userCred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    String uid = userCred.user!.uid;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('tbl_user')
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw Exception("Data user tidak ditemukan di database.");
    }

    final data = doc.data() as Map<String, dynamic>;

    return {
      'role': data['role'] ?? 'karyawan',
      'isActive': data['isActive'] ?? true, // default aktif
    };

  } on FirebaseAuthException catch (e) {
    throw Exception(e.message);
  }
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
