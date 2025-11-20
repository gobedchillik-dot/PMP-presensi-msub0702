import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../model/gmv.dart';

class WeeklyGmvSummary {
  final int mingguKe;
  final double total;
  final bool isUp;
  final String dateRange;

  WeeklyGmvSummary({
    required this.mingguKe,
    required this.total,
    this.isUp = false,
    required this.dateRange,
  });
}

class GmvController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_gmv';

  int _selectedFilterIndex = 3;
  int get selectedFilterIndex => _selectedFilterIndex;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  bool get isChartFilterToday => _selectedFilterIndex == 1;

  final _weeklySummaryController = StreamController<List<WeeklyGmvSummary>>.broadcast();
  Stream<List<WeeklyGmvSummary>> get weeklySummaryStream => _weeklySummaryController.stream;

  StreamSubscription<QuerySnapshot>? _gmvSubscription;

  List<WeeklyGmvSummary> _weeklySummary = [];
  List<WeeklyGmvSummary> get weeklySummary => _weeklySummary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GmvController() {
    setFilter(_selectedFilterIndex);
    _initializeWeeklySummaryStream();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<WeeklyGmvSummary>> _processWeeklySummary(List<GmvModel> allGmvData) async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    List<WeeklyGmvSummary> summaries = [];
    List<double> weeklyTotals = [];
    final DateFormat formatter = DateFormat('dd MMM');

    for (int i = 1; i <= 4; i++) {
      DateTime start;
      DateTime end;

      if (i < 4) {
        start = firstDayOfMonth.add(Duration(days: (i - 1) * 7));
        end = start.add(const Duration(days: 6)).copyWith(hour: 23, minute: 59, second: 59);
      } else {
        start = firstDayOfMonth.add(const Duration(days: 21));
        end = lastDayOfMonth.copyWith(hour: 23, minute: 59, second: 59);
      }

      if (start.isAfter(lastDayOfMonth)) break;

      final gmvDataThisWeek = allGmvData.where((item) {
        final itemDate = item.tanggal.toDate();
        return itemDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
               itemDate.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();

      final totalGmv = gmvDataThisWeek.fold<double>(0.0, (sum, item) => sum + item.gmv);
      weeklyTotals.add(totalGmv);

      bool isUp = false;
      if (i > 1 && weeklyTotals.length > 1) {
        isUp = totalGmv > weeklyTotals[i - 2];
      }

      summaries.add(
        WeeklyGmvSummary(
          mingguKe: i,
          total: totalGmv,
          isUp: isUp,
          dateRange: '${formatter.format(start)} - ${formatter.format(end)}',
        ),
      );
    }

    return summaries;
  }

  void _initializeWeeklySummaryStream() {
    _gmvSubscription?.cancel();

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    _gmvSubscription = _firestore
        .collection(_collectionName)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
        .snapshots()
        .listen((snapshot) async {
          final allGmvData = snapshot.docs.map((doc) {
            return GmvModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null);
          }).toList();

          final newSummaries = await _processWeeklySummary(allGmvData);

          _weeklySummary = newSummaries;
          _weeklySummaryController.sink.add(newSummaries);
          notifyListeners();
        }, onError: (error) {});
  }

  Future<bool> store({required double gmv, required DateTime tanggal}) async {
    _setLoading(true);
    try {
      final newGmv = GmvModel(id: '', gmv: gmv, tanggal: Timestamp.fromDate(tanggal));
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

  @override
  void dispose() {
    _gmvSubscription?.cancel();
    _weeklySummaryController.close();
    super.dispose();
  }

  Stream<List<GmvModel>> get filteredGmvStream {
    Query<Map<String, dynamic>> query = _firestore.collection(_collectionName);

    if (_startDate != null && _endDate != null) {
      query = query
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(_endDate!));
    }

    return query
        .orderBy('tanggal', descending: true)
        .withConverter<GmvModel>(
          fromFirestore: (snapshot, options) => GmvModel.fromFirestore(snapshot, options),
          toFirestore: (gmv, options) => gmv.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<GmvModel>> get allGmvStream {
    return _firestore
        .collection(_collectionName)
        .withConverter<GmvModel>(
          fromFirestore: (snapshot, options) => GmvModel.fromFirestore(snapshot, options),
          toFirestore: (gmv, options) => gmv.toFirestore(),
        )
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  void setFilter(int index) {
    _selectedFilterIndex = index;
    final now = DateTime.now();

    switch (index) {
      case 1:
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 2:
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 3:
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 0:
        break;
      default:
        break;
    }

    notifyListeners();
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
}
