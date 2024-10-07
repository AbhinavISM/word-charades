import 'package:flutter/material.dart';
import 'package:yayscribbl/models/room_model.dart';

class RoomDataWrap extends ChangeNotifier {
  RoomModel? roomData;
  void updateDataOfRoom(RoomModel? data) {
    roomData = data;
    notifyListeners();
  }
}
