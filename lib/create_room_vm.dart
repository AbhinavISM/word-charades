import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/socket_repository.dart';
import 'package:yayscribbl/room_data_provider.dart';

class CreateRoomVM extends ChangeNotifier {
  final RoomData roomData;
  final SocketRepository socketRepository;
  CreateRoomVM(this.roomData, this.socketRepository);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  String? maxRounds;
  String? roomSize;
  bool showProgressBar = false;

  void createRoom(Function updateRoomUI) {
    if (nameController.text.isNotEmpty &&
        roomController.text.isNotEmpty &&
        maxRounds != null &&
        roomSize != null) {
      showProgressBar = true;
      notifyListeners();
      print('already connected');
      socketRepository.createGame({
        "nick_name": nameController.text,
        "room_name": roomController.text,
        "room_size": roomSize,
        "max_rounds": maxRounds,
        "screen_from": 'create_room_screen',
      });
      socketRepository.updateRoomListener(updateRoomUI);
    }
  }
}
