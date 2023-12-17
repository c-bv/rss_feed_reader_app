import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setScreenIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
