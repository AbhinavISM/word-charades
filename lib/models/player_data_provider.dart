import 'package:flutter/material.dart';
import 'package:yayscribbl/models/player_model.dart';

class PlayerDataWrap extends ChangeNotifier {
  PlayerModel? _playerModel;

  PlayerModel? get playerModel => _playerModel;

  set playerModel(PlayerModel? newData) {
    _playerModel = newData;
    notifyListeners();
  }
}
