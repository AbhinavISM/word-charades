import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/socket_repository.dart';
import 'package:yayscribbl/room_data_provider.dart';

class CreateRoomVM extends ChangeNotifier {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _roomController = TextEditingController();

  String? _maxRounds;

  String? _roomSize;

  late IO.Socket socket;

  bool showProgressBar = false;

  late Map roomData;

  late SocketRepository socketRepository;
}
