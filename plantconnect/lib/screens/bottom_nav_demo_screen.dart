import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../providers/plant_favorites_provider.dart';

/// Module 3.45 — Designing App Navigation Flow Using BottomNavigationBar
///
/// Demonstrates:
///   - BottomNavigationBar with currentIndex state
///   - IndexedStack for STATE PRESERVATION (screens never rebuild on tab switch)
///   - PageView + PageController for swipe navigation
///   - Custom selected/unselected colors and labels
///   - 4 meaningful tabs
class BottomNavDemoScreen extends StatefulWidget {
  const BottomNavDemoScreen({super.key});

  @override
  State<BottomNavDemoScreen> createState() => _BottomNavDemoScreenState();
}

class _BottomNavDemoScreenState extends State<BottomNavDemoScreen> {
  int _currentIndex = 0;

  // Using PageController so we can also demonstrate swipe + animate
  final PageController _pageController = PageController();

  // Define screens OUTSIDE build() to avoid recreation on every rebuild
  static const List<_TabConfig> _tabs = [
    _TabConfig(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _TabConfig(
      icon: Icons.eco_outlined,
      activeIcon: Icons.eco,
      label: 'Plants',
    ),
    _TabConfig(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favourites',
    ),
    _TabConfig(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─── Tap handler — animates PageView AND updates index ───────────────────
  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Each page rendered exactly once; IndexedStack keeps state alive ──
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          _HomeTab(),
          _PlantsTab(),
          _FavouritesTab(),
          _ProfileTab(),
        ],
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // needed for 4+ items
        elevation: 12,
        items: _tabs
            .map(
              (t) => BottomNavigationBarItem(
                icon: Icon(t.icon),
                activeIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper to avoid magic constants in the item list
// ─────────────────────────────────────────────────────────────────────────────
class _TabConfig {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabConfig({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Home: shows counter + state-preservation proof
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TabHeader(
              emoji: '🏠',
              title: 'Home',
              subtitle: 'Module 3.45 — BottomNavigationBar demo',
            ),
            const SizedBox(height: 20),

            // ── State preservation demo ─────────────────────────────────
            _ConceptCard(
              title: '✅  State is Preserved',
              body: 'Switch to another tab and come back — the counter below '
                  'keeps its value. This works because PageView keeps all '
                  'children alive (vs rebuilding them each time).',
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Text(
                    '${counter.count}',
                    style: TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text('Counter (persists on tab switch)',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SmallBtn(
                        icon: Icons.remove,
                        color: Colors.orange,
                        onTap: () => context.read<CounterProvider>().decrement(),
                      ),
                      const SizedBox(width: 16),
                      _SmallBtn(
                        icon: Icons.add,
                        color: Colors.green,
                        onTap: () => context.read<CounterProvider>().increment(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        context.read<CounterProvider>().reset(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Architecture note ───────────────────────────────────────
            _CodeCard(
              code: '// PageView keeps all children alive\n'
                  'PageView(\n'
                  '  controller: _pageController,\n'
                  '  children: const [\n'
                  '    _HomeTab(),   // stays alive\n'
                  '    _PlantsTab(), // stays alive\n'
                  '    ...\n'
                  '  ],\n'
                  ');\n\n'
                  '// BottomNavigationBar drives the index\n'
                  'onTap: (i) => _pageController.animateToPage(i, ...)',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Plants: browse catalogue, toggle favourites
// ─────────────────────────────────────────────────────────────────────────────
class _PlantsTab extends StatelessWidget {
  const _PlantsTab();

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritePlantsProvider>();

    return SafeArea(
      child: Column(
        children: [
          _TabHeader(
            emoji: '🌿',
            title: 'Plants',
            subtitle: 'Tap ♡ to save to Favourites tab',
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: kPlantCatalogue.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final plant = kPlantCatalogue[i];
                final isFav = favs.isFavorite(plant.id);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Text(plant.emoji,
                        style: const TextStyle(fontSize: 30)),
                    title: Text(plant.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(plant.description,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12)),
                    trailing: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                      onPressed: () =>
                          context
                              .read<FavoritePlantsProvider>()
                              .toggleFavorite(plant),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — Favourites: read from shared provider
// ─────────────────────────────────────────────────────────────────────────────
class _FavouritesTab extends StatelessWidget {
  const _FavouritesTab();

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritePlantsProvider>();

    return SafeArea(
      child: Column(
        children: [
          _TabHeader(
            emoji: '❤️',
            title: 'Favourites',
            subtitle:
                '${favs.count} plant${favs.count == 1 ? '' : 's'} saved',
          ),
          if (favs.favorites.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 72, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('No favourites yet',
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Go to Plants tab and tap ♡',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: favs.favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final plant = favs.favorites[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Text(plant.emoji,
                          style: const TextStyle(fontSize: 30)),
                      title: Text(plant.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(plant.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () =>
                            context
                                .read<FavoritePlantsProvider>()
                                .removeFavorite(plant.id),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4 — Profile
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<FavoritePlantsProvider>().count;
    final counterVal = context.watch<CounterProvider>().count;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _TabHeader(
              emoji: '👤',
              title: 'Profile',
              subtitle: 'Summary of your activity',
            ),
            const SizedBox(height: 24),

            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.green[100],
              child: Icon(Icons.person, size: 56, color: Colors.green[700]),
            ),
            const SizedBox(height: 12),
            Text(
              'PlantConnect User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 24),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Favourites',
                    value: '$favCount',
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Counter',
                    value: '$counterVal',
                    icon: Icons.countertops,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _ConceptCard(
              title: '💡  UX Best Practices',
              body: '• 3–5 tabs recommended\n'
                  '• Keep labels short ("Home", "Plants")\n'
                  '• Use consistent icons\n'
                  '• Never put destructive actions in nav\n'
                  '• Preserve tab state with PageView/IndexedStack',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TabHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _TabHeader({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final String title;
  final String body;

  const _ConceptCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                  fontSize: 13)),
          const SizedBox(height: 6),
          Text(body,
              style: TextStyle(
                  color: Colors.green[700], fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String code;
  const _CodeCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: Color(0xFF89DDFF),
          height: 1.6,
        ),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(60, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Icon(icon),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
