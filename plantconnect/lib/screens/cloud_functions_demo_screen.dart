import 'package:flutter/material.dart';
import 'package:plantconnect/services/cloud_functions_service.dart';

/// Demo screen for showcasing Firebase Cloud Functions integration
/// 
/// This screen demonstrates:
/// 1. Callable Cloud Functions (sayHello, processPlantData)
/// 2. Event-triggered Cloud Functions (Firestore triggers)
/// 3. Firestore integration to trigger serverless functions
class CloudFunctionsDemoScreen extends StatefulWidget {
  const CloudFunctionsDemoScreen({Key? key}) : super(key: key);

  @override
  State<CloudFunctionsDemoScreen> createState() =>
      _CloudFunctionsDemoScreenState();
}

class _CloudFunctionsDemoScreenState extends State<CloudFunctionsDemoScreen> {
  final CloudFunctionsService _functionsService = CloudFunctionsService();
  
  // Text controllers for input
  late TextEditingController _nameController;
  late TextEditingController _plantNameController;
  late TextEditingController _waterFrequencyController;
  late TextEditingController _sunlightController;

  // State variables
  String _responseMessage = '';
  String _plantResponseMessage = '';
  bool _isLoading = false;
  bool _isCallableLoading = false;
  bool _isPlantLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Flutter Developer');
    _plantNameController = TextEditingController(text: 'Monstera');
    _waterFrequencyController = TextEditingController(text: 'weekly');
    _sunlightController = TextEditingController(text: 'partial shade');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plantNameController.dispose();
    _waterFrequencyController.dispose();
    _sunlightController.dispose();
    super.dispose();
  }

  /// Call the sayHello Cloud Function
  Future<void> _callSayHello() async {
    setState(() {
      _isCallableLoading = true;
      _responseMessage = '';
    });

    try {
      final message = await _functionsService.callSayHello(
        name: _nameController.text.isEmpty
            ? 'Flutter Developer'
            : _nameController.text,
      );

      setState(() {
        _responseMessage = message;
      });

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cloud Function executed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _responseMessage = '❌ Error: ${e.toString()}';
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isCallableLoading = false;
      });
    }
  }

  /// Call the processPlantData Cloud Function
  Future<void> _processPlantData() async {
    setState(() {
      _isPlantLoading = true;
      _plantResponseMessage = '';
    });

    try {
      final result = await _functionsService.processPlantData(
        plantName: _plantNameController.text.isEmpty
            ? 'Unknown Plant'
            : _plantNameController.text,
        waterFrequency: _waterFrequencyController.text.isEmpty
            ? 'weekly'
            : _waterFrequencyController.text,
        sunlight: _sunlightController.text.isEmpty
            ? 'partial shade'
            : _sunlightController.text,
      );

      String responseText = '''
Plant Care Analysis:
━━━━━━━━━━━━━━━━━━━━━━
Plant: ${result['plantName']}
Care Level: ${result['careLevel']}
Growth Time: ${result['estimatedGrowthTime']}

📋 Care Tips:
''';

      if (result['tips'] is List) {
        for (int i = 0; i < result['tips'].length; i++) {
          responseText += '${i + 1}. ${result['tips'][i]}\n';
        }
      }

      setState(() {
        _plantResponseMessage = responseText;
      });

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Plant data processed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _plantResponseMessage = '❌ Error: ${e.toString()}';
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isPlantLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Functions Demo 🚀'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📱 Firebase Cloud Functions Integration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This demo shows how to call serverless Cloud Functions directly from Flutter. '
                      'Cloud Functions reduce backend overhead by automatically scaling.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Callable Cloud Function - sayHello
            _buildSection(
              title: '1️⃣ Callable Cloud Function: sayHello',
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isCallableLoading ? null : _callSayHello,
                    icon: _isCallableLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cloud),
                    label: Text(
                      _isCallableLoading ? 'Calling Function...' : 'Call Function',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_responseMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _responseMessage,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Section 2: Callable Cloud Function - processPlantData
            _buildSection(
              title: '2️⃣ Callable Cloud Function: processPlantData',
              children: [
                TextField(
                  controller: _plantNameController,
                  decoration: InputDecoration(
                    labelText: 'Plant name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.eco),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _waterFrequencyController,
                  decoration: InputDecoration(
                    labelText: 'Water frequency (e.g., daily, weekly)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.water_drop),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sunlightController,
                  decoration: InputDecoration(
                    labelText: 'Sunlight requirement',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.wb_sunny),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPlantLoading ? null : _processPlantData,
                    icon: _isPlantLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.analytics),
                    label: Text(
                      _isPlantLoading
                          ? 'Processing...'
                          : 'Process Plant Data',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_plantResponseMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _plantResponseMessage,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Section 3: Event-Based Cloud Functions Info
            _buildSection(
              title: '3️⃣ Event-Based Cloud Functions (Firestore Triggers)',
              children: [
                const Text(
                  '🔄 Automatic Triggers:\n\n'
                  '• newUserCreated: Automatically initializes data when a new user is created\n'
                  '  - Sets creation timestamp\n'
                  '  - Initializes user level as "beginner"\n'
                  '  - Creates welcome guide subcollection\n\n'
                  '• onPlantAdded: Automatically updates stats when a plant is added\n'
                  '  - Increments total plant count\n'
                  '  - Tracks last plant added time\n'
                  '  - Sets health status to "healthy"\n\n'
                  '✨ These functions run automatically without explicit calls!',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Benefits Card
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚡ Why Serverless Functions?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ Automatic Scaling: Handle traffic spikes without manual intervention\n'
                      '✅ Cost Efficient: Pay only for execution time\n'
                      '✅ No Server Management: Focus on code, not infrastructure\n'
                      '✅ Real-time Triggers: React immediately to database changes\n'
                      '✅ Secure Backend Logic: Hide sensitive operations from client',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build a consistent section
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
