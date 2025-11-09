import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/gmv.dart';

class GmvController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_gmv';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Stream<List<GmvModel>> get gmvStream {
    return _firestore
        .collection(_collectionName)
        .withConverter<GmvModel>(
          fromFirestore: GmvModel.fromFirestore,
          toFirestore: (gmv, _) => gmv.toFirestore(),
        )
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<GmvModel?> show(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return GmvModel.fromFirestore(doc, null);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> store({required double gmv, required DateTime tanggal}) async {
    _setLoading(true);
    try {
      final newGmv = GmvModel(
        id: '',
        gmv: gmv,
        tanggal: Timestamp.fromDate(tanggal),
      );
      await _firestore.collection(_collectionName).add(newGmv.toFirestore());
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> update(GmvModel gmvToUpdate) async {
    _setLoading(true);
    try {
      await _firestore
          .collection(_collectionName)
          .doc(gmvToUpdate.id)
          .update(gmvToUpdate.toFirestore());
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> destroy(String id) async {
    _setLoading(true);
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }
}
