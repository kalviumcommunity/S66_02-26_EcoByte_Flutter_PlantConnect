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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore Read Operations Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stream Data'),
              Tab(text: 'Single Document'),
              Tab(text: 'Query Data'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Real-Time Stream (StreamBuilder)
            _buildStreamDataTab(),
            // Tab 2: Single Document (FutureBuilder)
            _buildSingleDocumentTab(),
            // Tab 3: Query with Filters
            _buildQueryDataTab(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // TAB 1: Real-Time Stream using StreamBuilder
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
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
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
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                      const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
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
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.leaf, color: Colors.green),
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
  // TAB 2: Single Document using FutureBuilder
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
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
  // TAB 3: Query with Filters
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
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
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
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2, color: Colors.blue),
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
    super.dispose();
  }
}
