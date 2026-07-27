import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:project_structure/core/database/database_service.dart';

class NoteSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> pushLocalChangesToFirebase(String userId, String userEmail) async {
    try {
      final db = await DatabaseService.db;

      final List<Map<String, dynamic>> localNotes = await db.query(
        'notes',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      if (localNotes.isEmpty) return;

      await _firestore.collection('users').doc(userId).set({
        'email': userEmail,
        'last_sync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      for (var note in localNotes) {
        String firebaseId = note['firebase_id'] ?? _firestore.collection('users').doc().id;

        Map<String, dynamic> firebaseData = Map.from(note);
        firebaseData.remove('id');
        firebaseData['firebase_id'] = firebaseId;

        await _firestore.collection('users').doc(userId).collection('notes').doc(firebaseId).set(firebaseData, SetOptions(merge: true));

        await db.update(
          'notes',
          {'firebase_id': firebaseId, 'is_synced': 1},
          where: 'id = ?',
          whereArgs: [note['id']],
        );
        debugPrint("✅ Synced Note Local ID: ${note['id']} to Firebase.");
      }
    } catch (e) {
      debugPrint("❌ Failed to push notes to Firebase: $e");
    }
  }

  Future<void> pullChangesFromFirebase(String userId, String lastSyncTime) async {
    try {
      final db = await DatabaseService.db;

      QuerySnapshot snapshot = await _firestore.collection('users').doc(userId).collection('notes').where('updated_at', isGreaterThan: lastSyncTime).get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> remoteNote = doc.data() as Map<String, dynamic>;
        String firebaseId = doc.id;

        final List<Map<String, dynamic>> localExist = await db.query(
          'notes',
          where: 'firebase_id = ?',
          whereArgs: [firebaseId],
        );

        if (localExist.isEmpty) {
          if (remoteNote['is_deleted'] == 1) continue;

          Map<String, dynamic> insertData = Map.from(remoteNote);
          insertData['is_synced'] = 1;

          await db.insert('notes', insertData);
        } else {
          String? localUpdatedAt = localExist.first['updated_at'];
          String? remoteUpdatedAt = remoteNote['updated_at'];

          if (remoteUpdatedAt != null && (localUpdatedAt == null || remoteUpdatedAt.compareTo(localUpdatedAt) > 0)) {
            if (remoteNote['is_deleted'] == 1) {
              await db.delete('notes', where: 'firebase_id = ?', whereArgs: [firebaseId]);
            } else {
              Map<String, dynamic> updateData = Map.from(remoteNote);
              updateData['is_synced'] = 1;

              await db.update(
                'notes',
                updateData,
                where: 'firebase_id = ?',
                whereArgs: [firebaseId],
              );
            }
          }
        }
      }
      debugPrint("🔄 Pull processes completed successfully.");
    } catch (e) {
      debugPrint("❌ Error pulling from Firebase: $e");
    }
  }

  Future<void> deleteNoteFromFirebase(String userId, String firebaseId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('notes').doc(firebaseId).delete();
      debugPrint("🔥 Permanently deleted doc $firebaseId from Firebase.");
    } catch (e) {
      debugPrint("❌ Error deleting doc from Firebase: $e");
    }
  }
}
