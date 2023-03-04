import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/socket_repository.dart';
import 'package:yayscribbl/room_data_provider.dart';

class CreateRoomVM extends ChangeNotifier {
  final RoomData roomData;
  CreateRoomVM(this.roomData);
}
