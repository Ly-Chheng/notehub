import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:project_structure/core/database/database_service.dart';

class NoteSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1. PUSH LOGIC: រុញ Note ណាដែលទើបបង្កើត/កែប្រែលើទូរស័ព្ទឡើងទៅ Firebase
  Future<void> pushLocalChangesToFirebase(String userId) async {
    try {
      final db = await DatabaseService.db;

      // ទាញយក Note ណាដែលមិនទាន់បាន Sync (is_synced = 0)
      final List<Map<String, dynamic>> localNotes = await db.query(
        'notes',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      if (localNotes.isEmpty) return;

      // កែប្រែពី (var note == in localNotes) មកជា (var note in localNotes) វិញ
      for (var note in localNotes) {
        // ប្រសិនបើគ្មាន firebase_id ទេ ត្រូវ Generate ថ្មីពី Firestore
        String firebaseId = note['firebase_id'] ?? _firestore.collection('users').doc().id;

        // រៀបចំទិន្នន័យសម្រាប់រុញទៅ Firebase
        Map<String, dynamic> firebaseData = Map.from(note);
        firebaseData.remove('id'); // ដក local primary key auto-increment ចេញ
        firebaseData['firebase_id'] = firebaseId;

        // រុញទៅ Cloud Storage ក្រោម Collection របស់ User ជាក់លាក់
        await _firestore.collection('users').doc(userId).collection('notes').doc(firebaseId).set(firebaseData, SetOptions(merge: true));

        // ពេលជោគជ័យ ត្រូវប្តូរស្ថានភាពលើ SQLite ទៅជា Sync រួចរាល់ (is_synced = 1)
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

  /// 2. PULL LOGIC: ទាញយកទិន្នន័យពី Firebase មក Update ក្នុង Local Database
  Future<void> pullChangesFromFirebase(String userId, String lastSyncTime) async {
    try {
      final db = await DatabaseService.db;

      // ទាញយកតែ Note ណាដែលមានការកែប្រែថ្មីជាង ម៉ោងដែលយើងធ្លាប់ Sync ចុងក្រោយ
      QuerySnapshot snapshot = await _firestore.collection('users').doc(userId).collection('notes').where('updated_at', isGreaterThan: lastSyncTime).get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> remoteNote = doc.data() as Map<String, dynamic>;
        String firebaseId = doc.id;

        // ពិនិត្យមើលថាតើ Note នេះមានក្នុង SQLite រួចហើយឬនៅ
        final List<Map<String, dynamic>> localExist = await db.query(
          'notes',
          where: 'firebase_id = ?',
          whereArgs: [firebaseId],
        );

        if (localExist.isEmpty) {
          // ករណីគ្មានសោះ៖ បង្កើតថ្មីចូល SQLite (បើលើ cloud ដៅថាលុបហើយ មិនបាច់ insert ទេ)
          if (remoteNote['is_deleted'] == 1) continue;

          Map<String, dynamic> insertData = Map.from(remoteNote);
          insertData['is_synced'] = 1; // ដៅចំណាំថាវា sync រួចរាល់

          await db.insert('notes', insertData);
        } else {
          // ករណីមានរួចហើយ៖ ត្រូវធានាថាទិន្នន័យមកពី Cloud ថ្មីជាងទើបព្រម Overwrite (Conflict Resolution)
          String? localUpdatedAt = localExist.first['updated_at'];
          String? remoteUpdatedAt = remoteNote['updated_at'];

          if (remoteUpdatedAt != null && (localUpdatedAt == null || remoteUpdatedAt.compareTo(localUpdatedAt) > 0)) {
            // បើលើ Cloud ថ្មីជាង ហើយនៅលើ Cloud ជាប្រភេទ Soft Delete
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

  /// 3. HARD DELETE LOGIC: លុប Document នោះចេញពី Firebase Direct តែម្តង
  Future<void> deleteNoteFromFirebase(String userId, String firebaseId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('notes').doc(firebaseId).delete();
      debugPrint("🔥 Permanently deleted doc $firebaseId from Firebase.");
    } catch (e) {
      debugPrint("❌ Error deleting doc from Firebase: $e");
    }
  }
}
