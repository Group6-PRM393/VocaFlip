import 'package:flutter/foundation.dart';

class DataRefreshNotifier extends ChangeNotifier {
  int _version = 0;

  int get version => _version;

  void bump() {
    _version++;
    notifyListeners();
  }
}

final dataRefreshNotifier = DataRefreshNotifier();
