import 'package:flutter/material.dart';

class AppNavigationViewModel extends ChangeNotifier {
  int tabIndex = 0;

  void goToTab(int index) {
    tabIndex = index;
    notifyListeners();
  }
}
