import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Module 3.42 — Full CRUD flow combining UI, Firestore, and Auth
///
/// Data path: /users/{uid}/items/{itemId}
/// Each item: { title, description, createdAt }
class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  // ─── Firestore reference scoped to the signed-in user ────────────────────
  CollectionReference<Map<String, dynamic>> get _itemsRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('items');
  }

  // ─── Form controllers ─────────────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── CREATE ───────────────────────────────────────────────────────────────
  Future<void> _createItem() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnack('Please fill in both fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _itemsRef.add({
        'title': title,
        'description': description,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      _titleController.clear();
      _descriptionController.clear();
      if (mounted) Navigator.pop(context);
      _showSnack('✓ Item created!');
    } catch (e) {
      _showSnack('Error creating item: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────
  Future<void> _updateItem(String docId) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnack('Please fill in both fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _itemsRef.doc(docId).update({
        'title': title,
        'description': description,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      _titleController.clear();
      _descriptionController.clear();
      if (mounted) Navigator.pop(context);
      _showSnack('✓ Item updated!');
    } catch (e) {
      _showSnack('Error updating item: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  Future<void> _deleteItem(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('This cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _itemsRef.doc(docId).delete();
      _showSnack('✓ Item deleted!');
    } catch (e) {
      _showSnack('Error deleting item: $e', isError: true);
    }
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────
  void _showCreateDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _showItemDialog(
      title: 'Create New Item',
      actionLabel: 'Create',
      onAction: _createItem,
    );
  }

  void _showEditDialog(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    _titleController.text = doc.data()['title'] ?? '';
    _descriptionController.text = doc.data()['description'] ?? '';
    _showItemDialog(
      title: 'Edit Item',
      actionLabel: 'Update',
      onAction: () => _updateItem(doc.id),
    );
  }

  void _showItemDialog({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_note, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          StatefulBuilder(
            builder: (context, setDialogState) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : onAction,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(actionLabel),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── READ — StreamBuilder list ────────────────────────────────────────────
  Widget _buildItemList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _itemsRef.orderBy('createdAt', descending: true).snapshots(),
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
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Empty state
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No items yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first item',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        // Data state — list of items
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final createdAt = data['createdAt'] as int?;
            final date = createdAt != null
                ? DateTime.fromMillisecondsSinceEpoch(createdAt)
                : null;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.green[700],
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  data['title'] ?? 'Untitled',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      data['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── UPDATE button ──
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: Colors.blue[600]),
                      tooltip: 'Edit',
                      onPressed: () => _showEditDialog(doc),
                    ),
                    // ── DELETE button ──
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () => _deleteItem(doc.id),
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

  // ─── Header info card ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Personal Items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'Authenticated User',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Path: /users/${user?.uid?.substring(0, 8)}…/items',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD — My Items'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildItemList()),
        ],
      ),
      // ── CREATE button ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Item'),
      ),
    );
  }
}
