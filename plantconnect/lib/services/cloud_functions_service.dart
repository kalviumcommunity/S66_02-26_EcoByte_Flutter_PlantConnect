import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Service for interacting with Firebase Cloud Functions
class CloudFunctionsService {
  static final CloudFunctionsService _instance =
      CloudFunctionsService._internal();

  late final FirebaseFunctions _functions;

  CloudFunctionsService._internal() {
    _functions = FirebaseFunctions.instance;
    
    // Use emulator during development if needed
    if (kDebugMode) {
      // Uncomment the line below to use local emulator
      // _functions.useFunctionsEmulator('localhost', 5001);
    }
  }

  factory CloudFunctionsService() {
    return _instance;
  }

  /// Calls the sayHello Cloud Function
  /// 
  /// This is a simple callable function that returns a greeting message.
  /// 
  /// Returns a greeting message based on the provided name.
  /// 
  /// Throws [FirebaseFunctionsException] if the function call fails.
  Future<String> callSayHello({required String name}) async {
    try {
      final callable = _functions.httpsCallable('sayHello');
      final result = await callable.call({'name': name});
      
      // Extract the message from the response
      final message = result.data['message'] as String;
      debugPrint('Cloud Function Response: $message');
      
      return message;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions Error: ${e.code}');
      debugPrint('Error Message: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      rethrow;
    }
  }

  /// Calls the processPlantData Cloud Function
  /// 
  /// This function processes plant care information and returns care recommendations.
  /// 
  /// Parameters:
  ///   - plantName: Name of the plant
  ///   - waterFrequency: How often to water (e.g., 'daily', 'weekly')
  ///   - sunlight: Sunlight requirement (e.g., 'full sun', 'partial shade')
  /// 
  /// Returns a Map containing care level, growth time estimate, and care tips.
  /// 
  /// Throws [FirebaseFunctionsException] if the function call fails.
  Future<Map<String, dynamic>> processPlantData({
    required String plantName,
    required String waterFrequency,
    required String sunlight,
  }) async {
    try {
      final callable = _functions.httpsCallable('processPlantData');
      final result = await callable.call({
        'plantName': plantName,
        'waterFrequency': waterFrequency,
        'sunlight': sunlight,
      });
      
      debugPrint('Plant Data Processed: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions Error: ${e.code}');
      debugPrint('Error Message: ${e.message}');
      
      // Re-throw with a more user-friendly message
      throw Exception('Failed to process plant data: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      rethrow;
    }
  }

  /// Calls the generateCareSchedule HTTP function
  /// 
  /// This function generates a care schedule for multiple plants.
  /// 
  /// Parameters:
  ///   - plants: List of plant Maps containing 'name' and other plant info
  /// 
  /// Returns a Map containing the generated schedule for each plant.
  /// 
  /// Throws [FirebaseFunctionsException] if the function call fails.
  Future<Map<String, dynamic>> generateCareSchedule({
    required List<Map<String, dynamic>> plants,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateCareSchedule');
      final result = await callable.call({'plants': plants});
      
      debugPrint('Care Schedule Generated: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions Error: ${e.code}');
      debugPrint('Error Message: ${e.message}');
      
      throw Exception('Failed to generate care schedule: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      rethrow;
    }
  }
}
