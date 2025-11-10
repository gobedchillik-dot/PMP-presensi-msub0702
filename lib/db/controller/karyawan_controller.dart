// ignore_for_file: empty_catches, unused_catch_clause

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

    } catch (e) {}
  }

   Future<void> updateStatus(String uid, bool status) async {
  try {
    await _firestore.collection('tbl_user').doc(uid).update({
      'isActive': status,
    });
  } catch (e) {}
}

Future<void> deleteUserFirestore(String uid) async {
  try {
    await _firestore.collection('tbl_user').doc(uid).delete();
  } catch (e) {}
}



  // 🔹 Stream real-time data karyawan
  Stream<List<UserModel>> streamKaryawan() {
    return _firestore
        .collection('tbl_user')
        .where('role', isNotEqualTo: 'admin')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                UserModel.fromFirestore(doc.data()))
            .toList());
  }

    Stream<UserModel?> streamUserByUid(String uid) {
      return FirebaseFirestore.instance
          .collection('tbl_user')
          .where('uid', isEqualTo: uid) // ✅ Cari berdasarkan field uid
          .limit(1)
          .snapshots()
          .map((query) => 
              query.docs.isNotEmpty ? UserModel.fromFirestore(query.docs.first as Map<String, dynamic>) : null
          );
    }


  // 🔹 Ambil 1 data karyawan berdasarkan UID
  Future<UserModel?> getKaryawanByUid(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('tbl_user').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
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

    } on FirebaseAuthException catch (e) {
    } catch (e) {}
  }
}
