import 'package:flutter/material.dart';

class RefreshNotifier extends ChangeNotifier {
  static final RefreshNotifier _instance = RefreshNotifier._internal();
  factory RefreshNotifier() => _instance;
  RefreshNotifier._internal();

  void notifyFavoritesChanged() {
    notifyListeners();
  }

  void notifyHistoryChanged() {
    notifyListeners();
  }
}
