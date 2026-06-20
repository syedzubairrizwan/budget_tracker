import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/transaction.dart';

class FirestoreSplitService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a split group (shared transaction)
  Future<void> createSplitGroup(Transaction txn, String otherUserId) async {
    final groupId = _db.collection('splitGroups').doc().id;
    final map = txn.toMap()
      ..addAll({
        'splitGroupId': groupId,
        'splitWithUserId': otherUserId,
        'splitStatus': 'pending',
        'isCreator': true,
      });
    await _db.collection('splitGroups').doc(groupId).set(map);
    // Also add a copy for the other user (mirrored document with isCreator = false)
    final otherMap = Map<String, dynamic>.from(map)
      ..addAll({'isCreator': false, 'splitStatus': 'pending'});
    await _db
        .collection('users')
        .doc(otherUserId)
        .collection('splitGroups')
        .doc(groupId)
        .set(otherMap);
  }

  // Update settlement status (approve / deny)
  Future<void> updateSettlement(String groupId, SplitStatus status) async {
    await _db.collection('splitGroups').doc(groupId).update({
      'splitStatus': status.name,
    });
  }
}
