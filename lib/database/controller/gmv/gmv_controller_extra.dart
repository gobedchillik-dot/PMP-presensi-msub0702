import 'package:cloud_firestore/cloud_firestore.dart';

class GmvControllerExtra {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_gmv';

  Future<double> getTotalGmv() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      double total = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('gmv')) {
          final value = data['gmv'];
          if (value is num) {
            total += value.toDouble();
          }
        }
      }

      return total;
    } catch (_) {
      return 0.0;
    }
  }
}
