import 'package:flutter/material.dart';

class ScrollableViews extends StatefulWidget {
  const ScrollableViews({super.key});

  @override
  State<ScrollableViews> createState() => _ScrollableViewsState();
}

class _ScrollableViewsState extends State<ScrollableViews> {
  // Sample data for lists
  final List<String> listItems = List.generate(20, (i) => 'Item $i');

  // Sample data for grid
  final List<Map<String, dynamic>> gridItems = [
    {'title': 'Gallery', 'icon': Icons.image, 'color': Colors.red},
    {'title': 'Music', 'icon': Icons.music_note, 'color': Colors.blue},
    {'title': 'Settings', 'icon': Icons.settings, 'color': Colors.green},
    {'title': 'Profile', 'icon': Icons.person, 'color': Colors.purple},
    {'title': 'Messages', 'icon': Icons.message, 'color': Colors.orange},
    {'title': 'Notifications', 'icon': Icons.notifications, 'color': Colors.pink},
    {'title': 'Favorites', 'icon': Icons.favorite, 'color': Colors.cyan},
    {'title': 'Download', 'icon': Icons.download, 'color': Colors.amber},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollable Views Demo'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HORIZONTAL LISTVIEW SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horizontal ListView',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Swipe left to see more cards',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: listItems.length,
                itemBuilder: (context, index) {
                  return _buildHorizontalCard(index);
                },
              ),
            ),

            // DIVIDER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Divider(
                thickness: 2,
                color: Colors.deepPurple.shade100,
              ),
            ),

            // 2. VERTICAL LISTVIEW SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vertical ListView',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Scroll down for more items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: 8,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.deepPurple.shade100,
                ),
                itemBuilder: (context, index) {
                  return _buildVerticalListItem(index);
                },
              ),
            ),

            // DIVIDER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Divider(
                thickness: 2,
                color: Colors.deepPurple.shade100,
              ),
            ),

            // 3. GRIDVIEW SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GridView Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tap any tile to interact',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: gridItems.length,
                itemBuilder: (context, index) {
                  return _buildGridTile(index);
                },
              ),
            ),

            // 4. STAGGERED GRIDVIEW SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Responsive Grid',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Grid adapts to screen width',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _buildResponsiveGrid(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Build horizontal card widget
  Widget _buildHorizontalCard(int index) {
    final colors = [
      Colors.teal,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.red,
      Colors.orange,
      Colors.amber,
    ];

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors[index % colors.length].shade300,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors[index % colors.length].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 40,
            color: colors[index % colors.length].shade800,
          ),
          const SizedBox(height: 12),
          Text(
            'Card ${index + 1}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors[index % colors.length].shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Item $index',
            style: TextStyle(
              fontSize: 11,
              color: colors[index % colors.length].shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Build vertical list item widget
  Widget _buildVerticalListItem(int index) {
    final titles = [
      'Flutter Documentation',
      'Dart Programming',
      'Mobile Development',
      'Widget Learning',
      'State Management',
      'Performance Tips',
      'Best Practices',
      'Advanced Concepts',
    ];

    final icons = [
      Icons.auto_stories,
      Icons.code,
      Icons.phone_android,
      Icons.widgets,
      Icons.storage,
      Icons.speed,
      Icons.checklist,
      Icons.school,
    ];

    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icons[index],
          color: Colors.deepPurple,
          size: 22,
        ),
      ),
      title: Text(
        titles[index],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        'Learn more about ${titles[index].toLowerCase()}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.deepPurple.shade300,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped: ${titles[index]}'),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
    );
  }

  // Build grid tile widget
  Widget _buildGridTile(int index) {
    final item = gridItems[index];

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opened: ${item['title']}'),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: item['color'] as Color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (item['color'] as Color).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item['icon'] as IconData,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              item['title'] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Build responsive grid
  Widget _buildResponsiveGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade300,
                Colors.deepPurple.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Item',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
