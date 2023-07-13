import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginPageStateProvider =
    ChangeNotifierProvider((ref) => LoginPageState());

class LoginPageState extends ChangeNotifier {
  bool _isLoading = false;
  set setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  bool get getIsLoading {
    return _isLoading;
  }
}
