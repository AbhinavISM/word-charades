import 'package:flutter/material.dart';
import 'package:yayscribbl/models/room_model.dart';

class RoomDataWrap extends ChangeNotifier {
  RoomModel? _roomData;

  RoomModel? get roomData => _roomData;

  set roomData(RoomModel? newData) {
    _roomData = newData;
    notifyListeners();
  }
}
