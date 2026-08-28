import 'package:flutter/material.dart';
import 'package:yayscribbl/models/round_model.dart';

class RoundDataWrap extends ChangeNotifier {
  RoundModel? _roundModel;

  RoundModel? get roundModel => _roundModel;

  set roundModel(RoundModel? newData) {
    _roundModel = newData;
    notifyListeners();
  }
}
