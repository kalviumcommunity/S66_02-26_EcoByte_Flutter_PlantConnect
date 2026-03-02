import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Determine if device is tablet or phone
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout Demo'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            children: [
              // 1. Header Section
              Container(
                width: double.infinity,
                height: isLandscape ? 100 : 150,
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Header Section',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Screen: ${screenWidth.toStringAsFixed(0)}x${screenHeight.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 20 : 15),

              // 2. Two-Column Layout (Responsive)
              isTablet
                  ? _buildTwoColumnLayout(isTablet, isLandscape)
                  : _buildStackedLayout(),

              SizedBox(height: isTablet ? 20 : 15),

              // 3. Info Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Responsive Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Device Type:', isTablet ? 'Tablet' : 'Phone'),
                    _buildInfoRow('Orientation:', isLandscape ? 'Landscape' : 'Portrait'),
                    _buildInfoRow('Width:', '${screenWidth.toStringAsFixed(0)} px'),
                    _buildInfoRow('Height:', '${screenHeight.toStringAsFixed(0)} px'),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 20 : 15),

              // 4. Flexible Grid Example
              _buildResponsiveGrid(isTablet, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  // Two-column layout for tablets
  Widget _buildTwoColumnLayout(bool isTablet, bool isLandscape) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: isLandscape ? 150 : 200,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dashboard_customize,
                  size: 48,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Left Panel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Flexible widget',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            height: isLandscape ? 150 : 200,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assess,
                  size: 48,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Right Panel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Flexible widget',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Stacked layout for phones
  Widget _buildStackedLayout() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_customize,
                size: 48,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 10),
              const Text(
                'Panel 1',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Full width on mobile',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assess,
                size: 48,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 10),
              const Text(
                'Panel 2',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Full width on mobile',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Info row widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Responsive grid
  Widget _buildResponsiveGrid(bool isTablet, double screenWidth) {
    final crossAxisCount = isTablet ? 4 : 2;
    final itemHeight = 120.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Responsive Grid',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            final colors = [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
              Colors.pink,
              Colors.indigo,
            ];

            return Container(
              decoration: BoxDecoration(
                color: colors[index].withOpacity(0.3),
                border: Border.all(color: colors[index], width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: colors[index],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Item ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors[index],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
