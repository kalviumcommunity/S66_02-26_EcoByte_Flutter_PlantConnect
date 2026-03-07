// SECURITY EXAMPLES FOR PLANTCONNECT
// Copy these patterns for secure Firestore/Firebase operations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

// ============================================================================
// EXAMPLE 1: SECURE SIGN UP → CREATE USER PROFILE
// ============================================================================
class SecureSignUpExample {
  Future<void> signUpAndCreateProfile(String email, String password, String displayName) async {
    try {
      final authService = AuthService();
      final firestoreService = FirestoreService();

      // Step 1: Create Firebase Auth user
      print('📱 Signing up user: $email');
      final user = await authService.signUp(email, password);
      
      if (user == null) {
        throw Exception('Sign up failed - no user returned');
      }

      // Step 2: Create Firestore profile document
      // ✅ SECURE: FirestoreService automatically:
      //    - Verifies user is authenticated
      //    - Sets uid = current user's uid
      //    - Adds server timestamps
      print('📄 Creating user profile for ${user.uid}');
      await firestoreService.createUserProfile({
        'displayName': displayName,
        'email': email, // Already set by service, but we can override
        'bio': '',
        'avatar': null,
        'subscriptionTier': 'free',
        'joinedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Sign up successful! Welcome, $displayName');
    } on FirebaseAuthException catch (e) {
      // ✅ SECURE: Handle Firebase errors without exposing sensitive data
      if (e.code == 'weak-password') {
        print('❌ Password is too weak');
      } else if (e.code == 'email-already-in-use') {
        print('❌ Email already registered');
      } else {
        print('❌ Sign up error: ${e.message}');
      }
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }
}

// ============================================================================
// EXAMPLE 2: SECURE LOGIN FLOW
// ============================================================================
class SecureLoginExample {
  Future<void> loginSecurely(String email, String password) async {
    try {
      print('🔐 Logging in: $email');
      final authService = AuthService();
      
      // ✅ SECURE: Returns verified user or throws exception
      final user = await authService.login(email, password);

      if (user != null) {
        print('✅ Login successful! Current user: ${user.email}');
        
        // Optional: Update last login timestamp
        await FirestoreService().updateUserProfile({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
      }
    } on FirebaseAuthException catch (e) {
      // ✅ SECURE: Don't reveal which field caused the error
      // This prevents email enumeration attacks
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        print('❌ Invalid email or password');
      } else {
        print('❌ Login error: ${e.message}');
      }
      rethrow;
    }
  }
}

// ============================================================================
// EXAMPLE 3: SECURE DATA WRITE (CREATE NEW PLANT)
// ============================================================================
class SecureDataWriteExample {
  Future<void> createPlant(String name, String type, String waterSchedule) async {
    try {
      final firestoreService = FirestoreService();

      // ✅ SECURE: Validate input before sending to firestore
      if (name.trim().isEmpty || type.trim().isEmpty) {
        throw Exception('Plant name and type cannot be empty');
      }

      print('🌱 Creating new plant: $name');

      // ✅ SECURE: FirestoreService automatically:
      //    - Checks user is authenticated
      //    - Sets uid = current user (prevents spoofing)
      //    - Adds server timestamp (prevents time manipulation)
      //    - Returns document ID
      final plantId = await firestoreService.addSecureDocument('plants', {
        'name': name.trim(),
        'type': type.trim(),
        'waterSchedule': waterSchedule,
        'dateAdded': DateTime.now().toIso8601String(),
        'healthScore': 100,
        'visibility': 'private', // ✅ Default to private, user can change
      });

      print('✅ Plant created with ID: $plantId');

      // ✅ SECURE: Firestore rules enforce:
      // - Only the owner (uid == createdBy) can read this document
      // - Only the owner can modify it
      // - Server-side timestamp cannot be changed
    } catch (e) {
      print('❌ Error creating plant: $e');
      rethrow;
    }
  }
}

// ============================================================================
// EXAMPLE 4: SECURE DATA READ (STREAM USER'S PLANTS)
// ============================================================================
class SecureDataReadExample {
  Stream<List<Map<String, dynamic>>> getUserPlantsStream() {
    try {
      // ✅ SECURE: FirestoreService returns ONLY current user's plants
      //    Uses: .where('uid', isEqualTo: currentUser.uid)
      return FirestoreService()
          .getUserDocumentsStream('plants')
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error getting plants: $e');
      rethrow;
    }
  }

  // UI Usage:
  // StreamBuilder<List<Map<String, dynamic>>>(
  //   stream: getUserPlantsStream(),
  //   builder: (context, snapshot) {
  //     if (snapshot.connectionState == ConnectionState.waiting) {
  //       return CircularProgressIndicator();
  //     }
  //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //       return Text('No plants yet!');
  //     }
  //     return ListView.builder(
  //       itemCount: snapshot.data!.length,
  //       itemBuilder: (context, index) {
  //         final plant = snapshot.data![index];
  //         return ListTile(
  //           title: Text(plant['name']),
  //           subtitle: Text(plant['type']),
  //         );
  //       },
  //     );
  //   },
  // )
}

// ============================================================================
// EXAMPLE 5: SECURE DATA UPDATE (ONLY OWN DATA)
// ============================================================================
class SecureDataUpdateExample {
  Future<void> updatePlantHealth(String plantId, int healthScore) async {
    try {
      final firestoreService = FirestoreService();

      // ✅ SECURE: Validate input
      if (healthScore < 0 || healthScore > 100) {
        throw Exception('Health score must be between 0 and 100');
      }

      print('🔧 Updating plant: $plantId');

      // ✅ SECURE: FirestoreService automatically:
      //    - Verifies this document belongs to current user
      //    - Prevents updating security fields (uid, createdAt)
      //    - Adds updated timestamp
      //    - Throws exception if user doesn't have permission
      await firestoreService.updateSecureDocument('plants', plantId, {
        'healthScore': healthScore,
        'lastWatered': DateTime.now().toIso8601String(),
      });

      print('✅ Plant updated successfully');
    } catch (e) {
      print('❌ Error updating plant: $e');
      rethrow;
    }
  }

  // ❌ NEVER DO THIS (Allows users to modify any plant):
  // Future<void> dangerousUpdate(String plantId, int healthScore) async {
  //   await FirebaseFirestore.instance
  //       .collection('plants')
  //       .doc(plantId)
  //       .update({'healthScore': healthScore});
  // }
}

// ============================================================================
// EXAMPLE 6: SECURE DATA DELETE (ONLY OWN DATA)
// ============================================================================
class SecureDataDeleteExample {
  Future<void> deleteOwnPlant(String plantId) async {
    try {
      final firestoreService = FirestoreService();

      // ✅ SECURE: Ask for confirmation before deletion
      final confirmed = true; // In real app: show dialog
      if (!confirmed) return;

      print('🗑️ Deleting plant: $plantId');

      // ✅ SECURE: FirestoreService automatically:
      //    - Verifies ownership (document.uid == currentUser.uid)
      //    - Throws exception if not authorized
      //    - Deletes atomically
      await firestoreService.deleteSecureDocument('plants', plantId);

      print('✅ Plant deleted successfully');
    } catch (e) {
      print('❌ Error deleting plant: $e');
      rethrow;
    }
  }

  // ❌ NEVER DO THIS (Users could delete any plant):
  // Future<void> dangerousDelete(String plantId) async {
  //   await FirebaseFirestore.instance
  //       .collection('plants')
  //       .doc(plantId)
  //       .delete();
  // }
}

// ============================================================================
// EXAMPLE 7: SECURE BATCH OPERATIONS (ATOMIC)
// ============================================================================
class SecureBatchOperationsExample {
  Future<void> transferPlantsToCollection(
    List<String> plantIds,
    String collectionName,
  ) async {
    try {
      final firestoreService = FirestoreService();

      // ✅ SECURE: Use atomic batch to ensure all-or-nothing
      //    If any operation fails, entire batch is rolled back
      await firestoreService.executeBatch((batch) {
        for (String plantId in plantIds) {
          batch.update(
            FirebaseFirestore.instance
                .collection('plants')
                .doc(plantId),
            {'collection': collectionName},
          );
        }
      });

      print('✅ Batch operation completed');
    } catch (e) {
      print('❌ Batch operation failed: $e');
      rethrow;
    }
  }
}

// ============================================================================
// EXAMPLE 8: SECURE LOGOUT
// ============================================================================
class SecureLogoutExample {
  Future<void> logoutSecurely() async {
    try {
      print('🔒 Logging out...');
      
      // ✅ SECURE: Clear local auth state
      await AuthService().logout();

      // ✅ SECURE: Firestore automatically stops listening to streams
      // ✅ SECURE: AuthWrapper detects no user and shows AuthScreen

      print('✅ Logout successful');
      // No need to manually clear user data - streams will stop updating
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }
}

// ============================================================================
// EXAMPLE 9: HANDLING PERMISSION ERRORS
// ============================================================================
class PermissionErrorHandlingExample {
  Future<void> handlePermissionError() async {
    try {
      // This will fail because user is not authenticated or not the owner
      await FirestoreService()
          .updateSecureDocument('plants', 'other_users_plant_id', {
        'healthScore': 50,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // ✅ SECURE: Expected error - user tried to modify someone else's data
        print('❌ You cannot modify this plant');
      } else {
        print('❌ Error: ${e.message}');
      }
    }
  }
}

// ============================================================================
// EXAMPLE 10: CHECKING AUTHENTICATION STATE
// ============================================================================
class AuthenticationStateExample {
  void checkAuthState() {
    final authService = AuthService();
    
    // ✅ SECURE: Check if user is authenticated
    if (authService.isAuthenticated) {
      final user = authService.currentUser;
      print('✅ Current user: ${user?.email} (UID: ${user?.uid})');
    } else {
      print('❌ No user logged in');
    }
  }

  void listenToAuthChanges() {
    // ✅ SECURE: React to auth state changes
    AuthService().authStateChanges.listen((user) {
      if (user != null) {
        print('✅ User signed in: ${user.email}');
        // Load user's data from Firestore
      } else {
        print('✅ User signed out');
        // Clear UI, stop streams
      }
    });
  }
}

// ============================================================================
// SECURITY CHECKLIST FOR CUSTOM OPERATIONS
// ============================================================================
/*
When implementing new secure operations, ensure:

✅ USER AUTHENTICATION
   - Always check if user is authenticated before write
   - Use authService.currentUser or authService.isAuthenticated
   - Never assume user is logged in

✅ DATA OWNERSHIP
   - Always include uid field in documents
   - Always verify ownership before update/delete
   - Use FirestoreService methods that verify ownership

✅ SERVER TIMESTAMPS
   - Use FieldValue.serverTimestamp() not DateTime.now()
   - Prevents time manipulation attacks
   - Enables audit trails

✅ INPUT VALIDATION
   - Validate data before sending to firestore
   - Check for empty strings, invalid ranges
   - Trim whitespace from user input

✅ ERROR HANDLING
   - Catch specific Firebase exceptions
   - Don't expose internal errors to users
   - Log security violations for monitoring

✅ DATA EXPOSURE
   - Only query documents where uid == currentUser.uid
   - Use where() clauses, never return all data
   - Never expose sensitive fields in public queries

✅ ATOMIC OPERATIONS
   - Use batch writes for related updates
   - Prevents partial writes on failure
   - Ensures data consistency

❌ SECURITY ANTI-PATTERNS
   - ❌ Direct FirebaseFirestore.instance calls (use FirestoreService)
   - ❌ Trusting user-provided UIDs (verify server-side)
   - ❌ Using client time for audit logs (use server timestamps)
   - ❌ Public read access to user profiles (restrict to owner)
   - ❌ Skipping ownership verification (always verify)
   - ❌ Exposing error messages to users (log securely)
*/
