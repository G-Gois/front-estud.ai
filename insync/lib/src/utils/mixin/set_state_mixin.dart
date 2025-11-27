import 'package:flutter/foundation.dart';

mixin SetStateMixin on ChangeNotifier {
  void setState(VoidCallback update) {
    update();
    notifyListeners();
  }
}
