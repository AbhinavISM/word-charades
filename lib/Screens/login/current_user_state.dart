import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/models/user.dart';


final currentUserStateProvider =
    ChangeNotifierProvider((ref) => CurrentUserState());

class CurrentUserState extends ChangeNotifier {
  late User _employeeModel;
  set setCurrentUser(User employeeModel) {
    _employeeModel = employeeModel;
    notifyListeners();
  }

  User get getCurrentUser {
    return _employeeModel;
  }
}
