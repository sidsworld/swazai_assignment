import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  TextEditingController weightController = TextEditingController();
  TextEditingController updateWeightController = TextEditingController();

  bool _build = false;
  bool _processing = false;
  List? _documents;

  bool get processing => _processing;
  bool get build => _build;
  List? get documents => _documents;

  set processing(bool value) {
    _processing = value;
    notifyListeners();
  }

  set build(bool value) {
    _build = value;
    notifyListeners();
  }

  set documents(List? value) {
    _documents = value;
    notifyListeners();
  }
}
