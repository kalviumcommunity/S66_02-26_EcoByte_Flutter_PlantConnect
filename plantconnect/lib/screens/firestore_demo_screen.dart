import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class FirestoreDemoScreen extends StatefulWidget {
  const FirestoreDemoScreen({super.key});

  @override
  State<FirestoreDemoScreen> createState() => _FirestoreDemoScreenState();
}

class _FirestoreDemoScreenState extends State<FirestoreDemoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _documentIdController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _editingDocId;
  bool _isLoading = false;
  
  // Query filter state
  String _selectedQueryType = 'all'; // all, equality, comparison, array, sorted, limited, complex
  
  // Security: Rate limiting to prevent write spam
  DateTime? _lastWriteTime;
  static const Duration _minTimeBetweenWrites = Duration(seconds: 1);
  
  // Security: Field length constraints
  static const int _maxTitleLength = 100;
  static const int _maxDescriptionLength = 500;
  static const int _minTitleLength = 1;
  static const int _minDescriptionLength = 1;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore Query Demo'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Write Data'),
              Tab(text: 'Stream Data'),
              Tab(text: 'Single Doc'),
              Tab(text: 'Query Examples'),
              Tab(text: 'Advanced Filters'),
              Tab(text: 'Sorting & Limit'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Write Operations (Create, Update, Delete)
            _buildWriteOperationsTab(),
            // Tab 2: Real-Time Stream (StreamBuilder)
            _buildStreamDataTab(),
            // Tab 3: Single Document (FutureBuilder)
            _buildSingleDocumentTab(),
            // Tab 4: Query Examples
            _buildQueryExamplesTab(),
            // Tab 5: Advanced Filters
            _buildAdvancedFiltersTab(),
            // Tab 6: Sorting and Limiting
            _buildSortingAndLimitTab(),
          ],
        ),
      ),
    );
  }

  // ================================================
  // TAB 1: Write Operations (Create, Update, Delete)
  // ================================================
  Widget _buildWriteOperationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Write Operations Demo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• CREATE: Add new task\n• UPDATE: Edit existing task\n• DELETE: Remove task',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form Section
          _buildTaskForm(),
          const SizedBox(height: 24),

          // Task List Section
          const Text(
            'Current Tasks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTaskList(),
        ],
      ),
    );
  }

  // Task Form Widget
  Widget _buildTaskForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingDocId == null ? 'Add New Task' : 'Edit Task',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),

            // Description Field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter task description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // Submit Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSubmit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_editingDocId == null ? Icons.add : Icons.check),
                    label: Text(_editingDocId == null ? 'Add Task' : 'Update Task'),
                  ),
                ),
                const SizedBox(width: 12),

                // Cancel Button (Show only when editing)
                if (_editingDocId != null)
                  ElevatedButton.icon(
                    onPressed: _cancelEdit,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Task List Widget
  Widget _buildTaskList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getCollectionStream('tasks'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No tasks yet. Create your first task!'),
              ],
            ),
          );
        }

        final tasks = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final data = task.data() as Map<String, dynamic>;
            final createdAt = data['createdAt'] as Timestamp?;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.task_alt, color: Colors.green),
                title: Text(data['title'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(data['description'] ?? 'No description'),
                    if (createdAt != null)
                      Text(
                        'Created: ${_formatDate(createdAt.toDate())}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _startEdit(task.id, data);
                    } else if (value == 'delete') {
                      _confirmDelete(task.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // SECURE WRITE OPERATION: Validates and safely creates/updates tasks
  Future<void> _handleSubmit() async {
    // SECURITY: Sanitize input (trim whitespace)
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // SECURITY: Validate required fields
    final validationError = _validateTaskInput(title, description);
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    // SECURITY: Rate limiting to prevent write spam
    if (!_checkRateLimit()) {
      _showErrorSnackBar('Wait a moment before the next action');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_editingDocId == null) {
        // CREATE: Add new task with auto-generated ID
        await _firestoreService.addDocument('tasks', {
          'title': title,
          'description': description,
          'isCompleted': false,
          // SECURITY: Server timestamp ensures consistency
          // No client-side timestamp manipulation possible
        });

        _showSuccessSnackBar('✓ Task created successfully!');
      } else {
        // UPDATE: Modify specific fields only (preserve other data)
        await _firestoreService.updateDocument('tasks', _editingDocId!, {
          'title': title,
          'description': description,
          // Note: createdAt timestamp is preserved, not overwritten
        });

        _showSuccessSnackBar('✓ Task updated successfully!');
      }

      _clearForm();
    } on FirebaseException catch (e) {
      // SECURITY: Handle Firebase-specific errors securely
      _handleFirebaseError(e);
    } catch (e) {
      // SECURITY: Log errors securely without exposing sensitive data
      print('Unexpected error: $e');
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // SECURITY: Validate task input before Firestore write
  String? _validateTaskInput(String title, String description) {
    // Check if fields are empty
    if (title.isEmpty) {
      return 'Task title cannot be empty';
    }
    if (description.isEmpty) {
      return 'Task description cannot be empty';
    }

    // SECURITY: Enforce field length constraints (prevents DoS via large documents)
    if (title.length > _maxTitleLength) {
      return 'Title must be ${_maxTitleLength} characters or less (${title.length}/${_maxTitleLength})';
    }
    if (description.length > _maxDescriptionLength) {
      return 'Description must be ${_maxDescriptionLength} characters or less (${description.length}/${_maxDescriptionLength})';
    }

    // SECURITY: Enforce minimum length (prevents spam/junk data)
    if (title.length < _minTitleLength) {
      return 'Title must be at least $_minTitleLength character';
    }
    if (description.length < _minDescriptionLength) {
      return 'Description must be at least $_minDescriptionLength character';
    }

    // SECURITY: Check for malformed content (optional - add custom rules)
    if (_containsOnlyWhitespace(title)) {
      return 'Title cannot contain only spaces';
    }
    if (_containsOnlyWhitespace(description)) {
      return 'Description cannot contain only spaces';
    }

    // SECURITY: Detect injection attempts or malicious patterns
    if (_containsSuspiciousPatterns(title) || _containsSuspiciousPatterns(description)) {
      return 'Input contains invalid characters or patterns. Please use standard text only.';
    }

    return null; // Validation passed
  }

  // SECURITY: Detect suspicious patterns that might indicate injection attempts
  bool _containsSuspiciousPatterns(String text) {
    // Pattern checks for common injection/xss attempts:
    final suspiciousPatterns = [
      RegExp(r'(?i)script|iframe|onclick|onerror|eval|javascript'),
      RegExp(r'[<>{}|\[\]\\^`]'), // Limited special characters
    ];

    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  // SECURITY: Rate limiting to prevent write spam and DoS attacks
  bool _checkRateLimit() {
    if (_lastWriteTime == null) {
      _lastWriteTime = DateTime.now();
      return true;
    }

    final now = DateTime.now();
    final timeSinceLastWrite = now.difference(_lastWriteTime!);

    if (timeSinceLastWrite < _minTimeBetweenWrites) {
      return false; // Too soon, operation blocked
    }

    _lastWriteTime = now;
    return true;
  }

  // SECURITY: Helper to detect whitespace-only strings
  bool _containsOnlyWhitespace(String text) {
    return text.trim().isEmpty;
  }

  // SECURITY: Handle Firebase errors securely
  void _handleFirebaseError(FirebaseException e) {
    String message;

    switch (e.code) {
      case 'permission-denied':
        message = 'You do not have permission to perform this action';
        break;
      case 'not-found':
        message = 'The document you are trying to update does not exist';
        break;
      case 'aborted':
        message = 'The operation was aborted. Please try again';
        break;
      case 'unauthenticated':
        message = 'You must be logged in to perform this action';
        break;
      case 'failed-precondition':
        message = 'Operation failed. please check your input and try again';
        break;
      default:
        // SECURITY: Don't expose internal error codes to users
        message = 'An error occurred while saving your task. Please try again';
        print('Firebase error code: ${e.code}');
    }

    _showErrorSnackBar(message);
  }

  // UI Helper: Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // UI Helper: Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startEdit(String docId, Map<String, dynamic> data) {
    setState(() {
      _editingDocId = docId;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Now editing task...')),
    );
  }

  void _cancelEdit() {
    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _editingDocId = null;
    });
  }

  Future<void> _confirmDelete(String docId) async {
    // SECURITY: Always require user confirmation for destructive operations
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force user to make explicit choice
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'This action is permanent and cannot be undone. '
          'Are you sure you want to delete this task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteTask(docId);
    }
  }

  // SECURE DELETE OPERATION: Safely removes data with proper error handling
  Future<void> _deleteTask(String docId) async {
    try {
      // SECURITY: Rate limiting applies to delete operations too
      if (!_checkRateLimit()) {
        _showErrorSnackBar('Wait before performing another action');
        return;
      }

      // SECURITY: Validate document ID format (prevent injection)
      if (!_isValidDocumentId(docId)) {
        _showErrorSnackBar('Invalid document ID');
        return;
      }

      await _firestoreService.deleteDocument('tasks', docId);
      _showSuccessSnackBar('✓ Task deleted successfully!');
    } on FirebaseException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      print('Delete error: $e');
      _showErrorSnackBar('Failed to delete task. Please try again.');
    }
  }

  // SECURITY: Validate document ID to prevent injection attacks
  bool _isValidDocumentId(String docId) {
    // Firestore document IDs can contain alphanumeric, hyphens, underscores
    return docId.isNotEmpty && 
           docId.length <= 1024 && // Firestore limit
           !docId.contains(RegExp(r'[^a-zA-Z0-9_-]'));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  // ============================================
  // TAB 2: Real-Time Stream using StreamBuilder
  // ============================================
  Widget _buildStreamDataTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Real-Time Data Stream',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This uses StreamBuilder to listen to Firestore changes in real-time.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'Code: FirebaseFirestore.instance.collection("items").snapshots()',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getCollectionStream('items'),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // No data state
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text('No data available'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addSampleData,
                        child: const Text('Add Sample Data'),
                      ),
                    ],
                  ),
                );
              }

              // Data available
              final items = snapshot.data!.docs;

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final data = item.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.eco, color: Colors.green),
                      title: Text(data['name'] ?? 'Unknown'),
                      subtitle: Text(data['description'] ?? 'No description'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(item.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ========================================
  // TAB 3: Single Document using FutureBuilder
  // ========================================
  Widget _buildSingleDocumentTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get Single Document',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This uses FutureBuilder for one-time reads (no live updates).',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _documentIdController,
                    decoration: InputDecoration(
                      hintText: 'Enter document ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<DocumentSnapshot>(
            future: _documentIdController.text.isEmpty
                ? Future.value(null as DocumentSnapshot?)
                : FirebaseFirestore.instance
                      .collection('items')
                      .doc(_documentIdController.text)
                      .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_documentIdController.text.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Enter a document ID to fetch'),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('Document not found'));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>?;

              if (data == null) {
                return const Center(child: Text('No data in document'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document: ${_documentIdController.text}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...data.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(entry.value.toString()),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

    // =================================
  // TAB 4: Query Examples
  // =================================
  Widget _buildQueryExamplesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Query Examples',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Basic filtering examples to narrow down documents.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Equality Filter Example
          _buildQueryCard(
            title: 'Equality Filter (.where)',
            description: 'Find all items with status = "available"',
            code: '.where("status", isEqualTo: "available")',
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('status', isEqualTo: 'available')
                .snapshots(),
          ),
          const SizedBox(height: 16),

          // Array Contains Filter Example
          _buildQueryCard(
            title: 'Array Contains Filter',
            description: 'Find all items with "airPurifying" in tags',
            code: '.where("tags", arrayContains: "airPurifying")',
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('tags', arrayContains: 'airPurifying')
                .snapshots(),
          ),
          const SizedBox(height: 16),

          // Boolean Filter Example
          _buildQueryCard(
            title: 'Boolean Filter',
            description: 'Find all items that are in stock',
            code: '.where("inStock", isEqualTo: true)',
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('inStock', isEqualTo: true)
                .snapshots(),
          ),
        ],
      ),
    );
  }

  // =================================
  // TAB 5: Advanced Filters
  // =================================
  Widget _buildAdvancedFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comparison operators for numerical and date fields.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Greater Than Filter
          _buildQueryCard(
            title: 'Greater Than Filter (.isGreaterThan)',
            description: 'Find items with price > 50',
            code: '.where("price", isGreaterThan: 50)',
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('price', isGreaterThan: 50)
                .snapshots(),
          ),
          const SizedBox(height: 16),

          // Less Than Or Equal Filter
          _buildQueryCard(
            title: 'Less Than Or Equal Filter',
            description: 'Find items with price <= 100',
            code: '.where("price", isLessThanOrEqualTo: 100)',
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('price', isLessThanOrEqualTo: 100)
                .snapshots(),
          ),
          const SizedBox(height: 16),

          // Combined Filters (Range Query)
          _buildQueryCard(
            title: 'Price Range (Combined Filters)',
            description: 'Find items with price between 30 and 150',
            code: '.where("price", isGreaterThanOrEqualTo: 30).where("price", isLessThanOrEqualTo: 150)',
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('price', isGreaterThanOrEqualTo: 30)
                .where('price', isLessThanOrEqualTo: 150)
                .snapshots(),
          ),
        ],
      ),
    );
  }

  // =================================
  // TAB 6: Sorting and Limiting
  // =================================
  Widget _buildSortingAndLimitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sorting & Limiting Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'orderBy() for sorting and limit() for pagination.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sort Ascending
          _buildQueryCard(
            title: 'Ascending Sort (.orderBy)',
            description: 'Sort items by price (lowest first)',
            code: '.orderBy("price")',
            stream: FirebaseFirestore.instance
                .collection('items')
                .orderBy('price')
                .snapshots(),
          ),
          const SizedBox(height: 16),

          // Sort Descending
          _buildQueryCard(
            title: 'Descending Sort',
            description: 'Sort items by price (highest first)',
            code: '.orderBy("price", descending: true)',
            stream: FirebaseFirestore.instance
                .collection('items')
                .orderBy('price', descending: true)
                .snapshots(),
          ),
          const SizedBox(height: 16),

          // Limit Results
          _buildQueryCard(
            title: 'Limit Results (.limit)',
            description: 'Show only the first 5 items (sorted by date, newest first)',
            code: '.orderBy("createdAt", descending: true).limit(5)',
            stream: FirebaseFirestore.instance
                .collection('items')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
          ),
          const SizedBox(height: 16),

          // Complex Query: Filter + Sort + Limit
          _buildQueryCard(
            title: 'Complex Query (Filter + Sort + Limit)',
            description: 'In-stock items, sorted by price (lowest first), top 10',
            code: '.where("inStock", isEqualTo: true).orderBy("price").limit(10)',
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('inStock', isEqualTo: true)
                .orderBy('price')
                .limit(10)
                .snapshots(),
          ),
        ],
      ),
    );
  }

  // Helper method to build query result cards
  Widget _buildQueryCard({
    required String title,
    required String description,
    required String code,
    required Stream<QuerySnapshot> stream,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Stream Results
          StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No results found'),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index];
                    final data = item.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (data['price'] != null)
                            Text('Price: \$${data['price']}', style: const TextStyle(fontSize: 12)),
                          if (data['inStock'] != null)
                            Text('In Stock: ${data['inStock']}', style: const TextStyle(fontSize: 12)),
                          if (data['status'] != null)
                            Text('Status: ${data['status']}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =================================
  // TAB 4 (OLD): Query with Filters
  // =================================
  Widget _buildQueryDataTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtered Query Stream',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This shows items where status equals "available" (if set)',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'Code: collection("items").where("status", isEqualTo: "available").snapshots()',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No items available'));
              }

              final items = snapshot.data!.docs;

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final data = item.data() as Map<String, dynamic>;
                  final createdAt = data['createdAt'] as Timestamp?;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.inventory_2,
                        color: Colors.blue,
                      ),
                      title: Text(data['name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['description'] ?? 'No description'),
                          if (createdAt != null)
                            Text(
                              'Created: ${createdAt.toDate()}',
                              style: const TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper functions
  void _addSampleData() async {
    try {
      await _firestoreService.addDocument('items', {
        'name': 'Monstera Deliciosa',
        'description': 'A beautiful indoor plant',
        'status': 'available',
      });

      await _firestoreService.addDocument('items', {
        'name': 'Pothos',
        'description': 'Easy to care for climbing plant',
        'status': 'available',
      });

      await _firestoreService.addDocument('items', {
        'name': 'Snake Plant',
        'description': 'Low maintenance succulent',
        'status': 'available',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample data added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding data: $e')),
      );
    }
  }

  void _deleteItem(String docId) async {
    try {
      await _firestoreService.deleteDocument('items', docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  @override
  void dispose() {
    _documentIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
