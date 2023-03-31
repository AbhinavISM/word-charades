import 'package:flutter/material.dart';

class RoomData extends ChangeNotifier {
  Map? dataOfRoom;
  void updateDataOfRoom(Map? data) {
    dataOfRoom = data;
    notifyListeners();
  }
}
