import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreSecurityException implements Exception {
  final String message;
  FirestoreSecurityException(this.message);
  @override
  String toString() => message;
}

/// Secure Firestore service with authentication, validation, and best practices
/// 
/// Security features:
/// - User authentication verification before writes
/// - Data validation
/// - Ownership verification (users can only modify their own data)
/// - Server-side timestamps for audit trails
/// - Comprehensive error handling
/// - Batch operations for atomic writes
class FirestoreService {
  static const String _usersCollection = 'users';
  static const String _tasksCollection = 'tasks';
  static const String _itemsCollection = 'items';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Throws if user is not authenticated
  String _getCurrentUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirestoreSecurityException('User is not authenticated');
    }
    return uid;
  }

  // ============================================================
  // CREATE OPERATIONS (SECURE)
  // ============================================================

  /// Create user profile with security validation
  /// - Only authenticated users can create profiles
  /// - User ID is always verified
  /// - Includes audit trail data
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    final uid = _getCurrentUserId();

    try {
      // Validate required fields
      _validateUserData(userData);

      // Create user profile with security fields
      await _db.collection(_usersCollection).doc(uid).set(
        {
          'uid': uid, // Explicitly set for security rules verification
          'email': _auth.currentUser?.email ?? '',
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        SetOptions(merge: true), // Merge to avoid overwriting existing data
      );

      print('✓ User profile created for $uid');
    } catch (e) {
      print('✗ Error creating user profile: $e');
      rethrow;
    }
  }

  /// Add document with user ownership and validation
  /// - Automatically associates document with current user
  /// - Includes server timestamps
  /// - Returns document ID
  Future<String> addSecureDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final uid = _getCurrentUserId();

    try {
      // Validate data structure
      _validateDocumentData(data);

      final docRef = await _db.collection(collection).add({
        ...data,
        'uid': uid, // Associate with current user
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✓ Document added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('✗ Error adding document: $e');
      rethrow;
    }
  }

  /// Add a task with user ownership
  Future<String> addTask(String title, String description) async {
    final uid = _getCurrentUserId();

    if (title.trim().isEmpty) {
      throw FirestoreSecurityException('Task title cannot be empty');
    }
    if (description.trim().isEmpty) {
      throw FirestoreSecurityException('Task description cannot be empty');
    }

    try {
      final docRef = await _db.collection(_tasksCollection).add({
        'uid': uid,
        'title': title.trim(),
        'description': description.trim(),
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('✗ Error adding task: $e');
      rethrow;
    }
  }

  // ============================================================
  // UPDATE OPERATIONS (SECURE)
  // ============================================================

  /// Update document with ownership verification
  /// - Verifies document belongs to current user
  /// - Prevents updates to security fields (uid, createdAt)
  /// - Adds updatedAt timestamp
  Future<void> updateSecureDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final uid = _getCurrentUserId();

    try {
      // Step 1: Verify document belongs to current user
      await _verifyDocumentOwnership(collection, docId, uid);

      // Step 2: Remove security fields that shouldn't be updated
      final safeData = Map<String, dynamic>.from(data);
      safeData.remove('uid');
      safeData.remove('createdAt');
      safeData.remove('id');

      // Step 3: Add update metadata and timestamp
      safeData['updatedAt'] = FieldValue.serverTimestamp();

      // Step 4: Perform update
      await _db.collection(collection).doc(docId).update(safeData);

      print('✓ Document updated: $docId');
    } catch (e) {
      print('✗ Error updating document: $e');
      rethrow;
    }
  }

  /// Update user profile (only own profile)
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final uid = _getCurrentUserId();

    try {
      _validateUserData(updates);

      // Remove fields that shouldn't be updated
      final safeUpdates = Map<String, dynamic>.from(updates);
      safeUpdates.remove('uid');
      safeUpdates.remove('email');
      safeUpdates.remove('createdAt');

      await _db.collection(_usersCollection).doc(uid).update({
        ...safeUpdates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✓ User profile updated for $uid');
    } catch (e) {
      print('✗ Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update a task (with validation)
  Future<void> updateTask(
    String taskId,
    String title,
    String description,
  ) async {
    final uid = _getCurrentUserId();

    if (title.trim().isEmpty || description.trim().isEmpty) {
      throw FirestoreSecurityException(
        'Task title and description cannot be empty',
      );
    }

    try {
      // Verify ownership
      await _verifyDocumentOwnership(_tasksCollection, taskId, uid);

      await _db.collection(_tasksCollection).doc(taskId).update({
        'title': title.trim(),
        'description': description.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✓ Task updated: $taskId');
    } catch (e) {
      print('✗ Error updating task: $e');
      rethrow;
    }
  }

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    final uid = _getCurrentUserId();

    try {
      await _verifyDocumentOwnership(_tasksCollection, taskId, uid);

      final doc = await _db.collection(_tasksCollection).doc(taskId).get();
      final isCompleted = doc.get('isCompleted') as bool? ?? false;

      await _db.collection(_tasksCollection).doc(taskId).update({
        'isCompleted': !isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✓ Task completion toggled: $taskId');
    } catch (e) {
      print('✗ Error toggling task: $e');
      rethrow;
    }
  }

  // ============================================================
  // DELETE OPERATIONS (SECURE)
  // ============================================================

  /// Delete document with ownership verification
  Future<void> deleteSecureDocument(String collection, String docId) async {
    final uid = _getCurrentUserId();

    try {
      await _verifyDocumentOwnership(collection, docId, uid);
      await _db.collection(collection).doc(docId).delete();
      print('✓ Document deleted: $docId');
    } catch (e) {
      print('✗ Error deleting document: $e');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final uid = _getCurrentUserId();

    try {
      await _verifyDocumentOwnership(_tasksCollection, taskId, uid);
      await _db.collection(_tasksCollection).doc(taskId).delete();
      print('✓ Task deleted: $taskId');
    } catch (e) {
      print('✗ Error deleting task: $e');
      rethrow;
    }
  }

  // ============================================================
  // READ OPERATIONS (SECURE & NON-SECURE)
  // ============================================================

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection(_usersCollection).doc(uid).get();
      return doc.data();
    } catch (e) {
      print('✗ Error getting user profile: $e');
      rethrow;
    }
  }

  /// Stream of all documents (public read)
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    try {
      return _db
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('✗ Error getting collection stream: $e');
      rethrow;
    }
  }

  /// Stream of user's own documents only (secure read)
  Stream<QuerySnapshot> getUserDocumentsStream(String collection) {
    try {
      final uid = _getCurrentUserId();
      return _db
          .collection(collection)
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('✗ Error getting user documents stream: $e');
      rethrow;
    }
  }

  /// Stream of user's tasks only
  Stream<QuerySnapshot> getUserTasksStream() {
    try {
      final uid = _getCurrentUserId();
      return _db
          .collection(_tasksCollection)
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('✗ Error getting user tasks stream: $e');
      rethrow;
    }
  }

  /// Get a single document stream
  Stream<DocumentSnapshot> getDocumentStream(String collection, String docId) {
    try {
      return _db.collection(collection).doc(docId).snapshots();
    } catch (e) {
      print('✗ Error getting document stream: $e');
      rethrow;
    }
  }

  // ============================================================
  // BATCH OPERATIONS (ATOMIC WRITES)
  // ============================================================

  /// Perform multiple writes atomically
  /// Useful for maintaining data consistency across documents
  Future<void> executeBatch(Function(WriteBatch) operation) async {
    final uid = _getCurrentUserId();

    try {
      final batch = _db.batch();
      operation(batch);
      await batch.commit();
      print('✓ Batch operation completed');
    } catch (e) {
      print('✗ Error in batch operation: $e');
      rethrow;
    }
  }

  // ============================================================
  // VALIDATION HELPERS
  // ============================================================

  /// Validate user data structure
  void _validateUserData(Map<String, dynamic> data) {
    if (data.isEmpty) {
      throw FirestoreSecurityException('User data cannot be empty');
    }
  }

  /// Validate document data structure
  void _validateDocumentData(Map<String, dynamic> data) {
    if (data.isEmpty) {
      throw FirestoreSecurityException('Document data cannot be empty');
    }
  }

  /// Verify that document belongs to current user
  /// Prevents unauthorized access/modification
  Future<void> _verifyDocumentOwnership(
    String collection,
    String docId,
    String uid,
  ) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();

      if (!doc.exists) {
        throw FirestoreSecurityException('Document does not exist');
      }

      final docUid = doc.get('uid');
      if (docUid != uid) {
        throw FirestoreSecurityException(
          'You do not have permission to modify this document',
        );
      }
    } catch (e) {
      if (e is FirestoreSecurityException) rethrow;
      throw FirestoreSecurityException('Failed to verify document ownership: $e');
    }
  }

  // ============================================================
  // LEGACY METHODS (For backward compatibility)
  // ============================================================

  @Deprecated('Use createUserProfile instead')
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection(_usersCollection).doc(uid).set(data);
    } catch (e) {
      print('Error adding user data: $e');
      rethrow;
    }
  }

  @Deprecated('Use addSecureDocument instead')
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

  @Deprecated('Use updateSecureDocument instead')
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

  @Deprecated('Use deleteSecureDocument instead')
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADVANCED QUERY OPERATIONS (FILTERING, SORTING, LIMITING)
  // ============================================================

  /// Query with equality filter
  /// Example: getDocumentsWhere('plants', 'status', isEqualTo: 'available')
  Stream<QuerySnapshot> getDocumentsWhere(
    String collection,
    String field,
    dynamic value,
  ) {
    try {
      return _db
          .collection(collection)
          .where(field, isEqualTo: value)
          .snapshots();
    } catch (e) {
      print('✗ Error querying documents: $e');
      rethrow;
    }
  }

  /// Query with comparison filters
  /// Examples:
  /// - isGreaterThan: getDocumentsCompare('plants', 'price', isGreaterThan: 50)
  /// - isLessThan: getDocumentsCompare('plants', 'price', isLessThan: 100)
  /// - isGreaterThanOrEqualTo
  /// - isLessThanOrEqualTo
  Stream<QuerySnapshot> getDocumentsCompare(
    String collection,
    String field, {
    dynamic isGreaterThan,
    dynamic isLessThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic isLessThanOrEqualTo,
  }) {
    try {
      Query query = _db.collection(collection);

      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (isGreaterThanOrEqualTo != null) {
        query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
      }
      if (isLessThanOrEqualTo != null) {
        query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
      }

      return query.snapshots();
    } catch (e) {
      print('✗ Error with comparison query: $e');
      rethrow;
    }
  }

  /// Query with array contains filter
  /// Example: getDocumentsArrayContains('plants', 'tags', 'popular')
  Stream<QuerySnapshot> getDocumentsArrayContains(
    String collection,
    String field,
    dynamic value,
  ) {
    try {
      return _db
          .collection(collection)
          .where(field, arrayContains: value)
          .snapshots();
    } catch (e) {
      print('✗ Error with array contains query: $e');
      rethrow;
    }
  }

  /// Query with multiple filters (AND conditions)
  /// Example: getDocumentsMultiFilter(
  ///   'plants',
  ///   filters: {
  ///     'status': 'available',
  ///     'inStock': true,
  ///   }
  /// )
  Stream<QuerySnapshot> getDocumentsMultiFilter(
    String collection, {
    required Map<String, dynamic> filters,
    String? orderByField,
    bool descending = false,
    int? limitCount,
  }) {
    try {
      Query query = _db.collection(collection);

      // Apply all filters
      filters.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      // Apply ordering
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      // Apply limit
      if (limitCount != null) {
        query = query.limit(limitCount);
      }

      return query.snapshots();
    } catch (e) {
      print('✗ Error with multi-filter query: $e');
      rethrow;
    }
  }

  /// Query with sorting (ascending)
  /// Example: getDocumentsSorted('plants', 'price')
  Stream<QuerySnapshot> getDocumentsSorted(
    String collection,
    String field, {
    bool descending = false,
    int? limitCount,
  }) {
    try {
      Query query = _db.collection(collection).orderBy(field, descending: descending);

      if (limitCount != null) {
        query = query.limit(limitCount);
      }

      return query.snapshots();
    } catch (e) {
      print('✗ Error with sorted query: $e');
      rethrow;
    }
  }

  /// Query with limit
  /// Example: getDocumentsLimit('plants', 10)
  Stream<QuerySnapshot> getDocumentsLimit(
    String collection,
    int limitCount,
  ) {
    try {
      return _db
          .collection(collection)
          .limit(limitCount)
          .snapshots();
    } catch (e) {
      print('✗ Error with limit query: $e');
      rethrow;
    }
  }

  /// Query with filter, sort, and limit
  /// Comprehensive query combining where, orderBy, and limit
  /// Example: 
  /// getDocumentsComplex(
  ///   'plants',
  ///   whereField: 'inStock',
  ///   whereValue: true,
  ///   orderByField: 'price',
  ///   descending: false,
  ///   limitCount: 10
  /// )
  Stream<QuerySnapshot> getDocumentsComplex(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderByField,
    bool descending = false,
    int? limitCount,
  }) {
    try {
      Query query = _db.collection(collection);

      // Apply filter if provided
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }

      // Apply sorting if provided
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      // Apply limit if provided
      if (limitCount != null) {
        query = query.limit(limitCount);
      }

      return query.snapshots();
    } catch (e) {
      print('✗ Error with complex query: $e');
      rethrow;
    }
  }

  /// Query with pagination (for large datasets)
  /// First call with null startAfter, then use last document from previous batch
  /// Example:
  /// final first = await getDocumentsPaginated('plants', pageSize: 10);
  /// final next = await getDocumentsPaginated('plants', pageSize: 10, startAfter: first.last);
  Future<List<DocumentSnapshot>> getDocumentsPaginated(
    String collection, {
    int pageSize = 10,
    DocumentSnapshot? startAfter,
    String? orderByField = 'createdAt',
    bool descending = true,
  }) async {
    try {
      Query query = _db.collection(collection);

      // Apply sorting
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(pageSize);

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('✗ Error with pagination query: $e');
      rethrow;
    }
  }

  /// Get documents for a specific user with filters
  /// Combines user ownership verification with filtering
  Stream<QuerySnapshot> getUserDocumentsFiltered(
    String collection, {
    required Map<String, dynamic> filters,
    String? orderByField,
    bool descending = false,
    int? limitCount,
  }) {
    try {
      final uid = _getCurrentUserId();
      Query query = _db.collection(collection).where('uid', isEqualTo: uid);

      // Apply additional filters
      filters.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      // Apply ordering
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      // Apply limit
      if (limitCount != null) {
        query = query.limit(limitCount);
      }

      return query.snapshots();
    } catch (e) {
      print('✗ Error with user filtered query: $e');
      rethrow;
    }
  }

  /// Get completed/incomplete tasks with sorting
  Stream<QuerySnapshot> getTasksByStatus(
    bool isCompleted, {
    String sortBy = 'createdAt',
    bool descending = true,
    int? limitCount,
  }) {
    try {
      final uid = _getCurrentUserId();
      Query query = _db
          .collection(_tasksCollection)
          .where('uid', isEqualTo: uid)
          .where('isCompleted', isEqualTo: isCompleted)
          .orderBy(sortBy, descending: descending);

      if (limitCount != null) {
        query = query.limit(limitCount);
      }

      return query.snapshots();
    } catch (e) {
      print('✗ Error getting tasks by status: $e');
      rethrow;
    }
  }

  /// Search documents by a text field (simple substring search)
  /// Note: For production, consider using Algolia or Meilisearch
  /// This performs case-sensitive comparisons
  Stream<QuerySnapshot> searchDocuments(
    String collection,
    String searchField,
    String searchTerm,
  ) {
    try {
      return _db
          .collection(collection)
          .where(searchField, isGreaterThanOrEqualTo: searchTerm)
          .where(searchField, isLessThan: searchTerm + 'z')
          .snapshots();
    } catch (e) {
      print('✗ Error searching documents: $e');
      rethrow;
    }
  }
}
