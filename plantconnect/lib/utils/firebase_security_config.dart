// Firebase Security Configuration & Constants
// Location: lib/utils/firebase_security_config.dart
// Purpose: Centralized security settings and validation rules

/// Firebase Firestore Collection Names
class FirestoreCollections {
  static const String users = 'users';
  static const String tasks = 'tasks';
  static const String items = 'items';
  static const String plants = 'plants';
  static const String notifications = 'notifications';
  static const String publicPlants = 'publicPlants';
  static const String plantGuides = 'plantGuides';
}

/// Firebase Authentication Errors - User-Friendly Messages
class AuthErrorMessages {
  static const Map<String, String> errorMessages = {
    'weak-password': 'Password is too weak. Use at least 6 characters with uppercase, lowercase, and numbers.',
    'email-already-in-use': 'This email is already registered. Try logging in instead.',
    'user-not-found': 'Invalid email or password.',
    'wrong-password': 'Invalid email or password.',
    'invalid-email': 'Please enter a valid email address.',
    'too-many-requests': 'Too many login attempts. Please try again later.',
    'user-disabled': 'This account has been disabled. Contact support.',
    'operation-not-allowed': 'Email/password login is not enabled.',
  };

  static String getErrorMessage(String errorCode) {
    return errorMessages[errorCode] ?? 'Authentication error. Please try again.';
  }
}

/// Firebase Firestore Errors - User-Friendly Messages
class FirestoreErrorMessages {
  static const Map<String, String> errorMessages = {
    'permission-denied': 'You do not have permission to access this data.',
    'not-found': 'The requested item was not found.',
    'already-exists': 'This item already exists.',
    'invalid-argument': 'Invalid data format. Please check your input.',
    'resource-exhausted': 'Too many requests. Please wait before trying again.',
    'unauthenticated': 'You must be logged in to perform this action.',
    'unavailable': 'Service temporarily unavailable. Please try again.',
    'internal': 'Internal error occurred. Please try again.',
  };

  static String getErrorMessage(String errorCode) {
    return errorMessages[errorCode] ?? 'Database error. Please try again.';
  }
}

/// Validation Rules for User Data
class ValidationRules {
  // User Profile Validation
  static const int minPasswordLength = 6;
  static const int maxDisplayNameLength = 50;
  static const int maxBioLength = 500;

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }

  static bool isValidDisplayName(String name) {
    return name.isNotEmpty && name.length <= maxDisplayNameLength;
  }

  static bool isValidBio(String bio) {
    return bio.length <= maxBioLength;
  }

  // Plant/Task Data Validation
  static bool isValidPlantName(String name) {
    return name.trim().isNotEmpty && name.length <= 100;
  }

  static bool isValidPlantType(String type) {
    return type.trim().isNotEmpty && type.length <= 100;
  }

  static bool isValidTaskTitle(String title) {
    return title.trim().isNotEmpty && title.length <= 200;
  }

  static bool isValidTaskDescription(String description) {
    return description.trim().isNotEmpty && description.length <= 2000;
  }
}

/// Security Headers & Timestamps
class SecurityMetadata {
  /// Standard fields added to all documents for security & audit trail
  static const List<String> requiredSecurityFields = [
    'uid', // User ID - used in rules to verify ownership
    'createdAt', // Server timestamp - prevents tampering
    'updatedAt', // Last modification timestamp
  ];

  /// Fields that should NOT be user-updatable
  static const List<String> immutableFields = [
    'uid',
    'createdAt',
    'email',
    'id',
  ];

  /// Fields that should be protected in queries (not exposed publicly)
  static const List<String> sensitiveFields = [
    'email',
    'password',
    'apiKeys',
    'internalNotes',
  ];
}

/// Rate Limiting & Quota Configuration
class RateLimitConfig {
  // Login attempts
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);

  // Document operations
  static const int maxDocumentsPerBatch = 500;
  static const int maxDocumentsPerQuery = 1000;

  // File uploads
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const int maxUploadRetries = 3;
}

/// Audit Logging Configuration
class AuditLogConfig {
  // Actions to log for security audit
  static const List<String> auditableActions = [
    'user_signup',
    'user_login',
    'user_logout',
    'data_create',
    'data_update',
    'data_delete',
    'permission_denied',
    'unusual_access',
  ];

  // Log retention (optional)
  static const Duration logRetentionDuration = Duration(days: 90);
}

/// Security Best Practices Documentation
class SecurityBestPractices {
  static const String documentation = '''
FIREBASE SECURITY BEST PRACTICES FOR PLANTCONNECT

1. AUTHENTICATION (Required Before Any Operation)
   ✅ Always call FirestoreService._getCurrentUserId()
   ✅ Never assume user is authenticated
   ❌ Never use hardcoded user IDs

2. SERVER TIMESTAMPS (Prevent Time Manipulation)
   ✅ Use FieldValue.serverTimestamp()
   ❌ Never use DateTime.now() in Firestore documents

3. OWNERSHIP VERIFICATION (Before Modifications)
   ✅ Call _verifyDocumentOwnership() before update/delete
   ✅ Check request.auth.uid == resource.data.uid in rules
   ❌ Never skip ownership checks

4. INPUT VALIDATION (Prevent Malformed Data)
   ✅ Validate using ValidationRules class
   ✅ Trim whitespace from user input
   ❌ Never trust user input directly

5. ERROR HANDLING (Don't Expose Internal Details)
   ✅ Use user-friendly messages from ErrorMessages classes
   ✅ Log security violations server-side
   ❌ Never expose stack traces to users

6. DATA ACCESS (Implement Least Privilege)
   ✅ Query only user's own documents: .where('uid', isEqualTo: uid)
   ✅ Expose minimum required fields in responses
   ❌ Never return all sensitive data in queries

7. BATCH OPERATIONS (Ensure Consistency)
   ✅ Use executeBatch() for related updates
   ✅ Transaction ensures all-or-nothing behavior
   ❌ Never modify documents one-by-one in loops

8. FIRESTORE RULES (Server-Side Enforcement)
   ✅ Rules should mirror app logic
   ✅ Test all scenarios in Rules Playground
   ❌ Never rely only on client-side validation

9. DEPLOYMENT CHECKLIST
   ✅ Deploy firestore.rules to Firebase
   ✅ Switch Firestore from Test Mode to Production Mode
   ✅ Monitor security metrics & error rates
   ✅ Review Firebase Console logs regularly
   
10. TESTING SECURITY
    ✅ Test unauthenticated access (should fail)
    ✅ Test cross-user data access (should fail)
    ✅ Test ownership verification (should work)
    ✅ Test permission errors handling (should show user-friendly message)
''';
}
