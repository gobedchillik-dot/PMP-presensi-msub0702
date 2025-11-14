import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/user.dart';
import '../../../auth/auth_service.dart';
import 'package:flutter/material.dart';

class ProfilController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ambil stream user aktif agar real-time
  Stream<UserModel?> streamCurrentUserProfile() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('tbl_user').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromFirestore(snapshot.data()!);
      } else {
        return null;
      }
    });
  }




  Future<UserModel?> getCurrentUserProfileOnce() async {
  final user = AuthService.currentUser;
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance.collection('tbl_user').doc(user.uid).get();
  if (!doc.exists) return null;

  return UserModel.fromFirestore(doc.data()!);
}


  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        throw Exception('User belum login');
      }

      // Bersihkan field kosong agar tidak menimpa data lama dengan string kosong
      updatedData.removeWhere((key, value) => value == null || value.toString().trim().isEmpty);

      // Update ke Firestore
      await _firestore.collection('tbl_user').doc(user.uid).update(updatedData);

      // Logika tambahan (opsional): perbarui timestamp terakhir update
      await _firestore.collection('tbl_user').doc(user.uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout(BuildContext context) async {
    await AuthService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
