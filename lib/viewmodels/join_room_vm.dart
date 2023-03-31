import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:yayscribbl/viewmodels/room_data_provider.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

class JoinRoomVM extends ChangeNotifier {
  final RoomData roomData;
  final SocketRepository socketRepository;
  JoinRoomVM(this.roomData, this.socketRepository);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  String? maxRounds;
  String? roomSize;
  // bool showProgressBar = false;
  final StreamController<bool> showProgressBarController =
      StreamController.broadcast();

  void joinRoom(Function updateRoomUI) {
    if (nameController.text.isNotEmpty && roomController.text.isNotEmpty) {
      // showProgressBar = true;
      showProgressBarController.sink.add(true);

      notifyListeners();
      socketRepository.joinGame({
        "nick_name": nameController.text,
        "room_name": roomController.text,
        "screen_from": 'join_room_screen',
      });
      socketRepository.updateRoomListener(updateRoomUI);
    }
  }
}
