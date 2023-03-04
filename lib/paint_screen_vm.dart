import 'package:flutter/material.dart';
import 'package:yayscribbl/room_data_provider.dart';

class PaintScreenVM extends ChangeNotifier {
  final RoomData roomData;
  PaintScreenVM(this.roomData);
  bool firstBuild = true;
  setFirstBuild(bool b) {
    firstBuild = b;
    notifyListeners();
  }
}
