import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE: Add user data to Firestore
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data);
    } catch (e) {
      print('Error adding user data: $e');
      rethrow;
    }
  }

  // CREATE: Add a note/document to a collection
  Future<String?> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding document: $e');
      rethrow;
    }
  }

  // READ: Get user data once
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  // READ: Get all documents from a collection as a stream
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    try {
      return _db.collection(collection).orderBy('createdAt', descending: true).snapshots();
    } catch (e) {
      print('Error getting collection stream: $e');
      rethrow;
    }
  }

  // READ: Get user-specific documents from a collection
  Stream<QuerySnapshot> getUserDocumentsStream(String collection, String uid) {
    try {
      return _db
          .collection(collection)
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting user documents stream: $e');
      rethrow;
    }
  }

  // READ: Get a single document as a stream
  Stream<DocumentSnapshot> getDocumentStream(String collection, String docId) {
    try {
      return _db.collection(collection).doc(docId).snapshots();
    } catch (e) {
      print('Error getting document stream: $e');
      rethrow;
    }
  }

  // UPDATE: Update specific fields in a document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  // UPDATE: Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // DELETE: Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  // DELETE: Delete a user document
  Future<void> deleteUserData(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
}
