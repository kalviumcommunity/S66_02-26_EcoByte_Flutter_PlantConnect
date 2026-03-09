import 'package:flutter/material.dart';

/// A plant model used by the favorites provider
class Plant {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const Plant({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });
}

/// Module 3.43 — Example B: Multi-Screen Shared State
///
/// FavoritePlantsProvider demonstrates:
///   - Shared state across multiple screens/widgets
///   - Adding and removing items from a list
///   - notifyListeners() keeping all consumers in sync
class FavoritePlantsProvider extends ChangeNotifier {
  final List<Plant> _favorites = [];

  // Read-only view of the list
  List<Plant> get favorites => List.unmodifiable(_favorites);

  int get count => _favorites.length;

  bool isFavorite(String plantId) =>
      _favorites.any((p) => p.id == plantId);

  void addFavorite(Plant plant) {
    if (!isFavorite(plant.id)) {
      _favorites.add(plant);
      notifyListeners();
    }
  }

  void removeFavorite(String plantId) {
    _favorites.removeWhere((p) => p.id == plantId);
    notifyListeners();
  }

  void toggleFavorite(Plant plant) {
    if (isFavorite(plant.id)) {
      removeFavorite(plant.id);
    } else {
      addFavorite(plant);
    }
  }

  void clearAll() {
    _favorites.clear();
    notifyListeners();
  }
}

/// Sample plant catalogue — used in the browse tab
const List<Plant> kPlantCatalogue = [
  Plant(id: 'p1', name: 'Monstera', emoji: '🌿', description: 'Tropical split-leaf beauty'),
  Plant(id: 'p2', name: 'Peace Lily', emoji: '🌸', description: 'Elegant white blooms'),
  Plant(id: 'p3', name: 'Snake Plant', emoji: '🪴', description: 'Nearly indestructible'),
  Plant(id: 'p4', name: 'Pothos', emoji: '🍃', description: 'Fast-growing vine'),
  Plant(id: 'p5', name: 'ZZ Plant', emoji: '🌱', description: 'Drought-tolerant gem'),
  Plant(id: 'p6', name: 'Fiddle Leaf Fig', emoji: '🌳', description: 'Statement floor plant'),
  Plant(id: 'p7', name: 'Aloe Vera', emoji: '🌵', description: 'Medicinal succulent'),
  Plant(id: 'p8', name: 'Rubber Plant', emoji: '🍂', description: 'Bold glossy leaves'),
];
