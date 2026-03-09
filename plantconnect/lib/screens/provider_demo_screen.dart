import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../providers/plant_favorites_provider.dart';

/// Module 3.43 — Provider Demo Screen
///
/// Two tabs demonstrating Provider state management:
///   Tab 1: Counter  — basic ChangeNotifier (context.watch / context.read)
///   Tab 2: Browse   — add plants to shared Favorites
///   Tab 3: Favorites — consumes the same FavoritePlantsProvider from another widget
class ProviderDemoScreen extends StatelessWidget {
  const ProviderDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('State Management — Provider'),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.countertops_outlined), text: 'Counter'),
              Tab(icon: Icon(Icons.storefront_outlined), text: 'Browse'),
              Tab(icon: Icon(Icons.favorite_outline), text: 'Favourites'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CounterTab(),
            _BrowseTab(),
            _FavouritesTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: Counter — demonstrates basic Provider (context.watch / context.read)
// ─────────────────────────────────────────────────────────────────────────────
class _CounterTab extends StatelessWidget {
  const _CounterTab();

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this widget whenever CounterProvider notifies
    final counter = context.watch<CounterProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Concept card ──────────────────────────────────────────────────
          _ConceptCard(
            title: 'How Provider Works',
            body: 'CounterProvider extends ChangeNotifier.\n\n'
                '• context.watch<T>() — subscribes & rebuilds on change\n'
                '• context.read<T>() — reads once, no rebuild\n'
                '• notifyListeners() — triggers all watchers',
          ),
          const SizedBox(height: 24),

          // ── Counter display ───────────────────────────────────────────────
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
                Text(
                  'Current Count',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 32),

                // ── Buttons ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      icon: Icons.remove,
                      label: 'Decrement',
                      color: Colors.orange,
                      // context.read — just fires an action, no rebuild needed here
                      onTap: () => context.read<CounterProvider>().decrement(),
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.add,
                      label: 'Increment',
                      color: Colors.green,
                      onTap: () => context.read<CounterProvider>().increment(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => context.read<CounterProvider>().reset(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset to 0'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // ── Code snippet ─────────────────────────────────────────────────
          _CodeCard(
            code: '// Reading state (rebuilds on change)\n'
                'final counter = context.watch<CounterProvider>();\n'
                'Text("\${counter.count}");\n\n'
                '// Updating state\n'
                'context.read<CounterProvider>().increment();',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: Browse — add plants to global favorites from here
// ─────────────────────────────────────────────────────────────────────────────
class _BrowseTab extends StatelessWidget {
  const _BrowseTab();

  @override
  Widget build(BuildContext context) {
    // Watches favorites so the heart icon updates in real time
    final favorites = context.watch<FavoritePlantsProvider>();

    return Column(
      children: [
        _ConceptCard(
          title: 'Multi-Screen Shared State',
          body: 'Tap ♡ to add to Favourites. '
              'State is shared via FavoritePlantsProvider — '
              'changes appear instantly in the Favourites tab.',
          compact: true,
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: kPlantCatalogue.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final plant = kPlantCatalogue[i];
              final isFav = favorites.isFavorite(plant.id);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Text(plant.emoji,
                      style: const TextStyle(fontSize: 32)),
                  title: Text(plant.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(plant.description,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  trailing: IconButton(
                    tooltip: isFav ? 'Remove from Favourites' : 'Add to Favourites',
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                    ),
                    // context.read — action only, no rebuild needed from this line
                    onPressed: () =>
                        context.read<FavoritePlantsProvider>().toggleFavorite(plant),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: Favourites — consumes shared state from a completely different widget
// ─────────────────────────────────────────────────────────────────────────────
class _FavouritesTab extends StatelessWidget {
  const _FavouritesTab();

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritePlantsProvider>();

    if (favorites.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No favourites yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Browse and tap ♡ on any plant',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Count badge — updates whenever provider notifies
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red[400], size: 20),
              const SizedBox(width: 8),
              Text(
                '${favorites.count} plant${favorites.count == 1 ? '' : 's'} saved',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    context.read<FavoritePlantsProvider>().clearAll(),
                child: const Text('Clear all',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: favorites.favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final plant = favorites.favorites[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Text(plant.emoji,
                      style: const TextStyle(fontSize: 32)),
                  title: Text(plant.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(plant.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () =>
                        context.read<FavoritePlantsProvider>().removeFavorite(plant.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ConceptCard extends StatelessWidget {
  final String title;
  final String body;
  final bool compact;

  const _ConceptCard({
    required this.title,
    required this.body,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(compact ? 8 : 16),
      padding: EdgeInsets.all(compact ? 10 : 14),
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
                  fontSize: compact ? 13 : 14)),
          const SizedBox(height: 4),
          Text(body,
              style: TextStyle(
                  color: Colors.green[700],
                  fontSize: compact ? 12 : 13,
                  height: 1.5)),
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
          fontSize: 12,
          color: Color(0xFF89DDFF),
          height: 1.6,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
