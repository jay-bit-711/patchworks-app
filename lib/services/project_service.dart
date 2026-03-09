import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectService {
  ProjectService(this._db);
  final FirebaseFirestore _db;

  Stream<QuerySnapshot<Map<String, dynamic>>> myProjects(String uid) {
    return _db
        .collection('projects')
        .where('member_uids', arrayContains: uid)
        .orderBy('updated_at', descending: true)
        .snapshots();
  }

  Future<void> addEvidence({
    required String projectId,
    required String imageUrl,
    required String stage,
    required String uploaderUid,
  }) async {
    await _db.collection('evidence').add({
      'project_id': projectId,
      'image_url': imageUrl,
      'stage': stage,
      'uploader_uid': uploaderUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
