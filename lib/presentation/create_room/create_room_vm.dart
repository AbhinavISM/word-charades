import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yayscribbl/models/player_data_provider.dart';
import 'package:yayscribbl/models/room_data_provider.dart';
import 'package:yayscribbl/models/room_model.dart';
import 'package:yayscribbl/models/round_data_provider.dart';
import 'package:yayscribbl/models/round_model.dart';
import 'package:yayscribbl/models/socket_events.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

class CreateRoomVM extends ChangeNotifier {
  final RoomDataWrap roomDataWrap;
  final PlayerDataWrap playerDataWrap;
  final RoundDataWrap roundDataWrap;
  final SocketRepository socketRepository;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  late final StreamSubscription<SocketEvent> _socketSubscription;
  CreateRoomVM(this.roomDataWrap, this.socketRepository, this.navigatorKey,
      this.scaffoldMessengerKey, this.playerDataWrap, this.roundDataWrap) {
    _socketSubscription = socketRepository.eventStream.listen(_handleEvent);
  }

  @override
  void dispose() {
    _socketSubscription.cancel();
    super.dispose();
  }

  String? _playerNameText;
  String? _roomNameText;
  String? _maxRounds;
  String? _roomSize;

  String? get getMaxRounds => _maxRounds;
  String? get getRoomSize => _roomSize;

  set maxRounds(String? maxRounds) {
    _maxRounds = maxRounds;
    notifyListeners();
  }

  set roomSize(String? roomSize) {
    _roomSize = roomSize;
    notifyListeners();
  }

  set playerNameText(String? text) {
    _playerNameText = text;
  }

  set roomNameText(String? text) {
    _roomNameText = text;
  }

  bool showProgressBar = false;

  void _handleEvent(SocketEvent event) {
    if (event is SyncDataEvent) {
      syncDataEx(event.roomData, event.roundData);
    } else if (event is NotCorrectGameEvent) {
      notCorrectGameEx(event.message);
    }
  }

  void createRoom() {
    if ((_playerNameText?.trim().isNotEmpty ?? false) &&
        (_roomNameText?.trim().isNotEmpty ?? false) &&
        _maxRounds != null &&
        _roomSize != null) {
      showProgressBar = true;
      notifyListeners();
      print('already connected');
      socketRepository.createGame({
        "nickName": _playerNameText,
        "roomName": _roomNameText,
        "roomSize": _roomSize,
        "maxRounds": _maxRounds,
        "screenFrom": 'create_room_screen',
      });
    }
  }

  void syncDataEx(RoomModel roomData, RoundModel roundData) {
    showProgressBar = false;

    final targetNick = playerDataWrap.playerModel?.nickName;
    final playerData = roomData.players
        .where((player) => player.nickName == targetNick)
        .firstOrNull;
    roomDataWrap.roomData = (roomData);
    playerDataWrap.playerModel = (playerData);
    roundDataWrap.roundModel = (roundData);
    navigatorKey.currentState?.pushReplacementNamed('/paint_screen');
  }

  void notCorrectGameEx(String errMessage) {
    showProgressBar = false;
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(errMessage)));
  }
}
