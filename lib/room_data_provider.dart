
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomData extends ChangeNotifier {
  Map? dataOfRoom;
  void updateDataOfRoom(Map? data) {
    dataOfRoom = data;
    notifyListeners();
  }
}
