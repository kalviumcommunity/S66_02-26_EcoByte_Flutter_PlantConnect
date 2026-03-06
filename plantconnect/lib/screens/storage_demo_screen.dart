import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantconnect/services/storage_service.dart';

/// Demo screen showcasing Firebase Storage operations
/// Includes: Image selection, upload, display, and deletion
class StorageDemoScreen extends StatefulWidget {
  const StorageDemoScreen({Key? key}) : super(key: key);

  @override
  State<StorageDemoScreen> createState() => _StorageDemoScreenState();
}

class _StorageDemoScreenState extends State<StorageDemoScreen> {
  XFile? _selectedImage;
  String? _downloadUrl;
  bool _isUploading = false;
  String _uploadProgress = '';
  List<String> _uploadedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Demo'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Image Selection
            _buildSectionTitle('1. Select Image'),
            const SizedBox(height: 8),
            _buildImageSelectionButtons(),
            const SizedBox(height: 24),

            // Section: Preview Selected Image
            if (_selectedImage != null) ...[
              _buildSectionTitle('2. Selected Image Preview'),
              const SizedBox(height: 8),
              _buildImagePreview(),
              const SizedBox(height: 24),
            ],

            // Section: Upload Controls
            _buildSectionTitle('3. Upload to Firebase Storage'),
            const SizedBox(height: 8),
            _buildUploadButton(),
            if (_isUploading) ...[
              const SizedBox(height: 16),
              _buildUploadProgressIndicator(),
            ],
            const SizedBox(height: 24),

            // Section: Downloaded Image Display
            if (_downloadUrl != null) ...[
              _buildSectionTitle('4. Downloaded Image from URL'),
              const SizedBox(height: 8),
              _buildDownloadedImageDisplay(),
              const SizedBox(height: 16),
              _buildDownloadUrlDisplay(),
              const SizedBox(height: 16),
              _buildDeleteButton(),
              const SizedBox(height: 24),
            ],

            // Section: Upload History
            if (_uploadedImages.isNotEmpty) ...[
              _buildSectionTitle('5. Upload History'),
              const SizedBox(height: 8),
              _buildUploadHistory(),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds section title widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  /// Builds image selection buttons for gallery and camera
  Widget _buildImageSelectionButtons() {
    return Row(
      gap: 12,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.image),
            label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Picks image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final image = await StorageService.pickImage(ImageSource.gallery);
      setState(() {
        _selectedImage = image;
        _uploadProgress = '';
      });
      if (image != null) {
        _showSnackBar('Image selected: ${image.name}');
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  /// Picks image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final image = await StorageService.pickImage(ImageSource.camera);
      setState(() {
        _selectedImage = image;
        _uploadProgress = '';
      });
      if (image != null) {
        _showSnackBar('Photo captured: ${image.name}');
      }
    } catch (e) {
      _showErrorSnackBar('Error capturing image: $e');
    }
  }

  /// Displays preview of selected image
  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(_selectedImage!.path),
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Builds upload button
  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: _selectedImage == null || _isUploading ? null : _uploadImage,
      icon: _isUploading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.cloud_upload),
      label: Text(_isUploading ? 'Uploading...' : 'Upload to Storage'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
      ),
    );
  }

  /// Uploads the selected image
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 'Uploading...';
    });

    try {
      final downloadUrl = await StorageService.uploadImage(_selectedImage!);

      setState(() {
        _isUploading = false;
        _downloadUrl = downloadUrl;
        _uploadProgress = 'Upload successful!';
        _uploadedImages.insert(0, downloadUrl);
      });

      _showSnackBar('Image uploaded successfully!');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 'Upload failed!';
      });
      _showErrorSnackBar('Upload failed: $e');
    }
  }

  /// Builds upload progress indicator
  Widget _buildUploadProgressIndicator() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(
          _uploadProgress,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Displays the downloaded image from Firebase Storage URL
  Widget _buildDownloadedImageDisplay() {
    if (_downloadUrl == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          _downloadUrl!,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 300,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              color: Colors.red[100],
              child: const Center(
                child: Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Displays the download URL
  Widget _buildDownloadUrlDisplay() {
    if (_downloadUrl == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Download URL:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _downloadUrl!,
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            _copyToClipboard(_downloadUrl!);
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy URL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Builds delete button for uploaded image
  Widget _buildDeleteButton() {
    return ElevatedButton.icon(
      onPressed: _deleteImage,
      icon: const Icon(Icons.delete),
      label: const Text('Delete from Storage'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Deletes the uploaded image
  Future<void> _deleteImage() async {
    if (_downloadUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await StorageService.deleteFileByUrl(_downloadUrl!);

                setState(() {
                  _uploadedImages.remove(_downloadUrl);
                  _downloadUrl = null;
                  _selectedImage = null;
                });

                _showSnackBar('Image deleted successfully!');
              } catch (e) {
                _showErrorSnackBar('Delete failed: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Displays upload history/gallery
  Widget _buildUploadHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Uploads: ${_uploadedImages.length}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _uploadedImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                _showImageOptions(context, _uploadedImages[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    _uploadedImages[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Shows options for uploaded image
  void _showImageOptions(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy URL'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(imageUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await StorageService.deleteFileByUrl(imageUrl);
                  setState(() {
                    _uploadedImages.remove(imageUrl);
                    if (_downloadUrl == imageUrl) {
                      _downloadUrl = null;
                    }
                  });
                  _showSnackBar('Image deleted successfully!');
                } catch (e) {
                  _showErrorSnackBar('Delete failed: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Copies text to clipboard
  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Shows snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
