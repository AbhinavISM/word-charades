import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yayscribbl/models/room_data_provider.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

class CreateRoomVM extends ChangeNotifier {
  final RoomData roomData;
  final SocketRepository socketRepository;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  CreateRoomVM(this.roomData, this.socketRepository, this.navigatorKey,
      this.scaffoldMessengerKey) {
    socketRepository.notCorrectGameListener(notCorrectGameEx);
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  String? _maxRounds;
  String? _roomSize;
  get getMaxRounds => _maxRounds;
  get getRoomSize => _roomSize;
  set setMaxRounds(String? maxRounds) {
    _maxRounds = maxRounds;
    notifyListeners();
  }

  set setRoomSize(String? roomSize) {
    _roomSize = roomSize;
    notifyListeners();
  }

  // bool showProgressBar = false;
  final StreamController<bool> showProgressBarController =
      StreamController.broadcast();

  void createRoom() {
    if (nameController.text.isNotEmpty &&
        roomController.text.isNotEmpty &&
        _maxRounds != null &&
        _roomSize != null) {
      // showProgressBar = true;
      showProgressBarController.sink.add(true);
      notifyListeners();
      print('already connected');
      socketRepository.createGame({
        "nick_name": nameController.text,
        "room_name": roomController.text,
        "room_size": _roomSize,
        "max_rounds": _maxRounds,
        "screen_from": 'create_room_screen',
      });
      socketRepository.updateRoomListener(updateRoomUI);
    }
  }

  void updateRoomUI(Map roomAndPlayer) {
    // createRoomVM.showProgressBar = false;
    showProgressBarController.sink.add(false);
    roomData.updateDataOfRoom(roomAndPlayer['dataOfRoom']);
    // print(Provider.of<RoomData>(context).dataOfRoom.toString());
    // Navigator.of(context).pushNamed('/paint_screen',
    //     arguments: createRoomVM.nameController.text);
    navigatorKey.currentState?.pushNamed('/paint_screen',
        arguments: roomAndPlayer['thisPlayer']['nick_name']);
  }

  void notCorrectGameEx(String errMessage) {
    showProgressBarController.sink.add(false);
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(errMessage)));
  }
}
