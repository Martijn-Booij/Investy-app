import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investy/datamodel/portfolio_asset_model.dart';
import 'package:investy/datamodel/portfolio_value_snapshot_model.dart';

class PortfolioRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final String _assetsCollection = 'assets';
  final String _valueHistoryCollection = 'valueHistory';

  // Get current user ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference _getAssetsCollection() {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('portfolio')
        .doc('data')
        .collection(_assetsCollection);
  }

  CollectionReference _getValueHistoryCollection() {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('portfolio')
        .doc('data')
        .collection(_valueHistoryCollection);
  }

  Future<List<PortfolioAsset>> getPortfolioAssets() async {
    try {
      final snapshot = await _getAssetsCollection().get();
      return snapshot.docs
          .map((doc) => PortfolioAsset.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get portfolio assets: $e');
    }
  }

  Stream<List<PortfolioAsset>> getPortfolioAssetsStream() {
    return _getAssetsCollection().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PortfolioAsset.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<String> addPortfolioAsset(PortfolioAsset asset) async {
    try {
      final docRef = await _getAssetsCollection().add(asset.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add portfolio asset: $e');
    }
  }

  Future<void> updatePortfolioAsset(String assetId, PortfolioAsset asset) async {
    try {
      await _getAssetsCollection().doc(assetId).update(asset.toMap());
    } catch (e) {
      throw Exception('Failed to update portfolio asset: $e');
    }
  }

  Future<void> removePortfolioAsset(String assetId) async {
    try {
      await _getAssetsCollection().doc(assetId).delete();
    } catch (e) {
      throw Exception('Failed to remove portfolio asset: $e');
    }
  }

  Future<void> savePortfolioValueSnapshot({
    required double totalValue,
    double? change,
    DateTime? specificDate,
  }) async {
    try {
      final date = specificDate ?? DateTime.now();
      // Use date as ID (YYYY-MM-DD format) to ensure one snapshot per day
      final dateId = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Check if snapshot for this date already exists
      final existingDoc = await _getValueHistoryCollection().doc(dateId).get();
      
      if (existingDoc.exists) {
        // Update existing snapshot
        await _getValueHistoryCollection().doc(dateId).update({
          'timestamp': date.toIso8601String(),
          'totalValue': totalValue,
          'change': change,
        });
      } else {
        // Create new snapshot
        await _getValueHistoryCollection().doc(dateId).set({
          'timestamp': date.toIso8601String(),
          'totalValue': totalValue,
          'change': change,
        });
      }
    } catch (e) {
      throw Exception('Failed to save portfolio value snapshot: $e');
    }
  }

  // Get portfolio value history (for chart)
  Future<List<PortfolioValueSnapshot>> getPortfolioValueHistory({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _getValueHistoryCollection().orderBy('timestamp', descending: true);
      
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PortfolioValueSnapshot.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to get portfolio value history: $e');
    }
  }

  Future<PortfolioValueSnapshot?> getLatestPortfolioValueSnapshot() async {
    try {
      final snapshot = await _getValueHistoryCollection()
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      final doc = snapshot.docs.first;
      return PortfolioValueSnapshot.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to get latest portfolio value snapshot: $e');
    }
  }
}
