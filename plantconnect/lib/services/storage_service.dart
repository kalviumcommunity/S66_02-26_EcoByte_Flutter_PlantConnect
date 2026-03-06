import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service class for handling Firebase Storage operations
/// Manages file uploads, downloads, and deletions
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _uploadsFolder = 'uploads';
  static const String _profilesFolder = 'user_profiles';

  /// Uploads an image from XFile and returns the download URL
  /// [file] - The image file selected from device
  /// [folder] - Optional folder path (default: 'uploads')
  /// Returns the download URL of the uploaded file
  static Future<String> uploadImage(
    XFile file, {
    String folder = _uploadsFolder,
  }) async {
    try {
      // Generate unique filename using timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      // Create reference to storage location
      final Reference ref =
          _storage.ref().child('$folder/$fileName');

      // Upload file
      final UploadTask uploadTask = ref.putFile(File(file.path));

      // Wait for upload to complete
      await uploadTask.whenComplete(() {});

      // Get and return download URL
      final String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Uploads a file from device path and returns the download URL
  /// [filePath] - The absolute path to the file
  /// [folder] - Optional folder path (default: 'uploads')
  /// Returns the download URL of the uploaded file
  static Future<String> uploadFile(
    String filePath, {
    String folder = _uploadsFolder,
  }) async {
    try {
      final File file = File(filePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final Reference ref =
          _storage.ref().child('$folder/$fileName');

      final UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() {});

      final String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  /// Uploads a profile image and returns the download URL
  /// [file] - The image file for user profile
  /// Returns the download URL
  static Future<String> uploadProfileImage(XFile file) async {
    return uploadImage(file, folder: _profilesFolder);
  }

  /// Deletes a file from Firebase Storage by reference path
  /// [storagePath] - The path to the file in storage (e.g., 'uploads/filename')
  static Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  /// Deletes a file using its download URL by extracting the path
  /// [downloadUrl] - The public download URL of the file
  static Future<void> deleteFileByUrl(String downloadUrl) async {
    try {
      // Decode URL and extract file path
      final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  /// Gets the download URL for an existing file
  /// [storagePath] - The path to the file in storage
  /// Returns the download URL
  static Future<String> getDownloadUrl(String storagePath) async {
    try {
      final url = await _storage.ref(storagePath).getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting download URL: $e');
    }
  }

  /// Gets file metadata (size, creation time, etc.)
  /// [storagePath] - The path to the file in storage
  static Future<FullMetadata> getFileMetadata(String storagePath) async {
    try {
      final metadata = await _storage.ref(storagePath).getMetadata();
      return metadata;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting metadata: $e');
    }
  }

  /// Lists all files in a folder
  /// [folder] - The folder path to list files from
  static Future<List<Reference>> listFiles(String folder) async {
    try {
      final result = await _storage.ref(folder).listAll();
      return result.items;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Error listing files: $e');
    }
  }

  /// Picks an image from gallery or camera
  /// [source] - ImageSource.camera or ImageSource.gallery
  /// Returns the selected XFile or null if cancelled
  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      return image;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }

  /// Picks multiple images from gallery
  /// Returns a list of selected XFile objects
  static Future<List<XFile>> pickMultipleImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      return images;
    } catch (e) {
      throw Exception('Error picking images: $e');
    }
  }

  /// Picks a video from gallery or camera
  /// [source] - ImageSource.camera or ImageSource.gallery
  /// Returns the selected XFile or null if cancelled
  static Future<XFile?> pickVideo(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: source);
      return video;
    } catch (e) {
      throw Exception('Error picking video: $e');
    }
  }
}
