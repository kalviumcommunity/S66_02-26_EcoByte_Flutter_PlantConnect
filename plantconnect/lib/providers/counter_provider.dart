import 'package:flutter/material.dart';

/// Module 3.43 — Example A: Counter State
///
/// A simple ChangeNotifier demonstrating:
///   - Mutable shared state (count)
///   - notifyListeners() to trigger UI rebuilds
///   - increment / decrement / reset operations
class CounterProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    if (_count > 0) _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}
