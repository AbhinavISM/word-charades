import 'package:flutter/cupertino.dart';
import 'package:yayscribbl/room_data_provider.dart';
import 'package:yayscribbl/socket_repository.dart';

class JoinRoomVM extends ChangeNotifier {
  final RoomData roomData;
  final SocketRepository socketRepository;
  JoinRoomVM(this.roomData, this.socketRepository);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  String? maxRounds;
  String? roomSize;
  bool showProgressBar = false;

  void joinRoom(Function updateRoomUI) {
    if (nameController.text.isNotEmpty && roomController.text.isNotEmpty) {
      showProgressBar = true;
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
