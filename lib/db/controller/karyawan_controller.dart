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
      final snapshot = await _firestore
          .collection('tbl_user')
          .where('role', isNotEqualTo: 'admin')
          .get();

      karyawanList = snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      print('✅ Berhasil memuat ${karyawanList.length} data karyawan');
    } catch (e) {
      print('❌ Gagal memuat data karyawan: $e');
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
      final doc = await _firestore.collection('tbl_user').doc(uid).get();
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

  // 🔹 Tambah karyawan baru (dengan akun Firebase Auth)
  Future<void> addKaryawan({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      final data = {
        'uid': uid,
        'email': email,
        'name': '',
        'panggilan': '',
        'alamat': '',
        'norek': '',
        'bank': '',
        'nohp': '',
        'role': 'karyawan',
        'face_id': '',
        'face_image': '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('tbl_user').doc(uid).set(data);

      print('✅ Berhasil menambahkan karyawan baru: $email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('❌ Email sudah terdaftar.');
      } else if (e.code == 'invalid-email') {
        print('❌ Format email tidak valid.');
      } else {
        print('❌ Terjadi error FirebaseAuth: ${e.message}');
      }
    } catch (e) {
      print('❌ Gagal menambahkan karyawan: $e');
    }
  }

  // 🔹 Update data karyawan
  Future<void> updateKaryawan(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('tbl_user').doc(uid).update(data);
      print('✅ Data karyawan dengan UID $uid berhasil diperbarui');
    } catch (e) {
      print('❌ Gagal memperbarui data karyawan: $e');
    }
  }

  // 🔹 Update Face ID dan gambar wajah
  Future<void> updateFaceData({
    required String uid,
    required String faceId,
    required String faceImage,
  }) async {
    try {
      await _firestore.collection('tbl_user').doc(uid).update({
        'face_id': faceId,
        'face_image': faceImage,
      });
      print('✅ Face data berhasil diperbarui untuk $uid');
    } catch (e) {
      print('❌ Gagal memperbarui face data: $e');
    }
  }
}
