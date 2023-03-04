import 'package:flutter/material.dart';
import 'package:yayscribbl/room_data_provider.dart';

class PaintScreenVM extends RoomData {
  bool firstBuild = true;
  setFirstBuild(bool b) {
    firstBuild = b;
    notifyListeners();
  }
}
