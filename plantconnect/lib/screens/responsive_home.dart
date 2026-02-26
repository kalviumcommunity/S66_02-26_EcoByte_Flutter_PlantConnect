import 'package:flutter/material.dart';

/// ResponsiveHome demonstrates a fully responsive Flutter layout that adapts
/// to different screen sizes and orientations using MediaQuery, LayoutBuilder,
/// and responsive widgets like Expanded, Flexible, and GridView.
class ResponsiveHome extends StatefulWidget {
  const ResponsiveHome({super.key});

  @override
  State<ResponsiveHome> createState() => _ResponsiveHomeState();
}

class _ResponsiveHomeState extends State<ResponsiveHome> {
  int _selectedIndex = 0;
  final List<PlantItem> plants = [
    PlantItem(
      name: 'Monstera Deliciosa',
      image: '🌿',
      waterFrequency: 'Every 2 weeks',
      sunlight: 'Bright Indirect Light',
      difficulty: 'Easy',
    ),
    PlantItem(
      name: 'Snake Plant',
      image: '🌱',
      waterFrequency: 'Monthly',
      sunlight: 'Low to Bright Light',
      difficulty: 'Very Easy',
    ),
    PlantItem(
      name: 'Pothos',
      image: '🍃',
      waterFrequency: 'Weekly',
      sunlight: 'Low to Medium Light',
      difficulty: 'Easy',
    ),
    PlantItem(
      name: 'Fiddle Leaf Fig',
      image: '🌳',
      waterFrequency: 'Weekly',
      sunlight: 'Bright Indirect Light',
      difficulty: 'Moderate',
    ),
    PlantItem(
      name: 'Rubber Plant',
      image: '🌿',
      waterFrequency: 'Every 2 weeks',
      sunlight: 'Bright Light',
      difficulty: 'Moderate',
    ),
    PlantItem(
      name: 'Spider Plant',
      image: '🌱',
      waterFrequency: 'Weekly',
      sunlight: 'Medium to Bright Light',
      difficulty: 'Very Easy',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isTablet = screenWidth > 600;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      appBar: _buildResponsiveAppBar(screenWidth),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with responsive padding
            _buildHeaderSection(screenWidth, isTablet),

            // Main Content Area - Changes layout based on device size
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24.0 : 16.0,
                vertical: isTablet ? 20.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title with responsive text size
                  Text(
                    'Featured Plants',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),

                  // Responsive Grid/List of Plants
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine grid columns based on screen width
                      int gridColumns;
                      if (screenWidth < 600) {
                        gridColumns = 1;
                      } else if (screenWidth < 900) {
                        gridColumns = 2;
                      } else {
                        gridColumns = 3;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          childAspectRatio: isLandscape ? 1.2 : 1,
                          crossAxisSpacing: isTablet ? 20 : 12,
                          mainAxisSpacing: isTablet ? 20 : 12,
                        ),
                        itemCount: plants.length,
                        itemBuilder: (context, index) {
                          return _buildPlantCard(
                            plants[index],
                            screenWidth,
                            isTablet,
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: isTablet ? 30 : 24),

                  // Info Section with responsive layout
                  _buildInfoSection(screenWidth, isTablet),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildResponsiveBottomNav(),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(double screenWidth) {
    return AppBar(
      title: Text(
        'PlantConnect',
        style: TextStyle(
          fontSize: screenWidth > 600 ? 24 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.green[600],
      centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.all(screenWidth > 600 ? 16 : 12),
          child: Icon(
            Icons.notifications,
            size: screenWidth > 600 ? 28 : 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(double screenWidth, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to PlantConnect',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 32 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Your smart companion for healthy plant care',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isTablet ? 18 : 14,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          _buildResponsiveButton(
            'Get Started',
            screenWidth,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Welcome to PlantConnect!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(PlantItem plant, double screenWidth, bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped: ${plant.name}')),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Image Placeholder
              Container(
                width: double.infinity,
                height: screenWidth > 600 ? 150 : 120,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                alignment: Alignment.center,
                child: Text(
                  plant.image,
                  style: TextStyle(fontSize: screenWidth > 600 ? 64 : 48),
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),

              // Plant Name
              Text(
                plant.name,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 8 : 4),

              // Difficulty Badge
              Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                      vertical: isTablet ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(plant.difficulty),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plant.difficulty,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 10 : 6),

              // Plant Details with Icons
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.water_drop,
                      plant.waterFrequency,
                      screenWidth,
                      isTablet,
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    _buildDetailRow(
                      Icons.light_mode,
                      plant.sunlight,
                      screenWidth,
                      isTablet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text,
    double screenWidth,
    bool isTablet,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? 16 : 12,
          color: Colors.green[600],
        ),
        SizedBox(width: isTablet ? 6 : 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(double screenWidth, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = screenWidth < 600;

        // Create a responsive grid for info cards
        return Column(
          children: [
            Text(
              'Why PlantConnect?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: isTablet ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: isTablet ? 20 : 16),
            isMobile
                ? Column(
                    children: [
                      _buildInfoCard(
                        '📱',
                        'Quick Tips',
                        'Get instant plant care advice',
                        screenWidth,
                        isTablet,
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildInfoCard(
                        '📅',
                        'Smart Reminders',
                        'Never forget watering schedules',
                        screenWidth,
                        isTablet,
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildInfoCard(
                        '🌍',
                        'Community',
                        'Connect with plant enthusiasts',
                        screenWidth,
                        isTablet,
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: (constraints.maxWidth - 32) / 2,
                        child: _buildInfoCard(
                          '📱',
                          'Quick Tips',
                          'Get instant plant care advice',
                          screenWidth,
                          isTablet,
                        ),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth - 32) / 2,
                        child: _buildInfoCard(
                          '📅',
                          'Smart Reminders',
                          'Never forget watering schedules',
                          screenWidth,
                          isTablet,
                        ),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth - 32) / 2,
                        child: _buildInfoCard(
                          '🌍',
                          'Community',
                          'Connect with plant enthusiasts',
                          screenWidth,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(
    String emoji,
    String title,
    String description,
    double screenWidth,
    bool isTablet,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isTablet ? 32 : 28),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(
              description,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveButton(
    String label,
    double screenWidth, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: screenWidth > 600 ? 200 : 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: screenWidth > 600 ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.green[600],
            fontSize: screenWidth > 600 ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'very easy':
        return Colors.green;
      case 'easy':
        return Colors.lightGreen;
      case 'moderate':
        return Colors.orange;
      case 'difficult':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Model class for plant items
class PlantItem {
  final String name;
  final String image;
  final String waterFrequency;
  final String sunlight;
  final String difficulty;

  PlantItem({
    required this.name,
    required this.image,
    required this.waterFrequency,
    required this.sunlight,
    required this.difficulty,
  });
}
