import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart';

class KaryawanController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<UserModel> karyawanList = [];

  // 🔹 Ambil semua data karyawan (selain admin)
  Future<void> fetchKaryawan() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tbl_user')
          .where('role', isNotEqualTo: 'admin')
          .get();

      karyawanList = snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      print('✅ Berhasil memuat ${karyawanList.length} data karyawan');
    } catch (e) {
      print('❌ Terjadi kesalahan saat memuat data karyawan: $e');
    }
  }

  // 🔹 Stream real-time data karyawan
  Stream<List<UserModel>> streamKaryawan() {
    return _firestore
        .collection('tbl_user')
        .where('role', isNotEqualTo: 'admin')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                UserModel.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // 🔹 Ambil 1 data karyawan berdasarkan UID
  Future<UserModel?> getKaryawanByUid(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('tbl_user').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        print('⚠️ Data karyawan dengan UID $uid tidak ditemukan.');
        return null;
      }
    } catch (e) {
      print('❌ Gagal mengambil data karyawan: $e');
      return null;
    }
  }

  // 🔹 Tambah data karyawan baru (dengan Auth Firebase)
  Future<void> addKaryawan({
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Buat akun di Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2️⃣ Simpan data lengkap ke Firestore
      Map<String, dynamic> data = {
        'uid': uid,
        'email': email,
        'name': '',
        'panggilan': '',
        'alamat': '',
        'norek': '',
        'bank': '',
        'nohp': '',
        'role': 'karyawan',
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('tbl_user').doc(uid).set(data);

      print('✅ Berhasil menambahkan karyawan baru: $email');
    } on FirebaseAuthException catch (e) {
      // 3️⃣ Tangani error Firebase Auth
      if (e.code == 'email-already-in-use') {
        print('❌ Email sudah terdaftar.');
      } else if (e.code == 'invalid-email') {
        print('❌ Format email tidak valid.');
      } else {
        print('❌ Terjadi error FirebaseAuth: ${e.message}');
      }
    } catch (e) {
      print('❌ Gagal menambahkan data karyawan: $e');
    }
  }
}
