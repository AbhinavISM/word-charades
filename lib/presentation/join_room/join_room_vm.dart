import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yayscribbl/models/player_data_provider.dart';
import 'package:yayscribbl/models/room_data_provider.dart';
import 'package:yayscribbl/models/room_model.dart';
import 'package:yayscribbl/models/round_data_provider.dart';
import 'package:yayscribbl/models/round_model.dart';
import 'package:yayscribbl/models/socket_events.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

class JoinRoomVM extends ChangeNotifier {
  final RoomDataWrap roomDataWrap;
  final PlayerDataWrap playerDataWrap;
  final RoundDataWrap roundDataWrap;
  final SocketRepository socketRepository;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  late final StreamSubscription<SocketEvent> _socketSubscription;
  JoinRoomVM(this.roomDataWrap, this.socketRepository, this.navigatorKey,
      this.scaffoldMessengerKey, this.playerDataWrap, this.roundDataWrap) {
    _socketSubscription = socketRepository.eventStream.listen(_handleEvent);
  }

  @override
  void dispose() {
    _socketSubscription.cancel();
    super.dispose();
  }

  void _handleEvent(SocketEvent event) {
    if (event is SyncDataEvent) {
      syncDataEx(event.roomData, event.roundData);
    } else if (event is NotCorrectGameEvent) {
      notCorrectGameEx(event.message);
    }
  }

  String? _playerNameText;
  String? _roomNameText;
  bool showProgressBar = false;

  set playerNameText(String? text) {
    _playerNameText = text;
  }

  set roomNameText(String? text) {
    _roomNameText = text;
  }

  void joinRoom() {
    if ((_playerNameText?.trim().isNotEmpty ?? false) &&
        (_roomNameText?.trim().isNotEmpty ?? false)) {
      showProgressBar = true;

      notifyListeners();
      socketRepository.joinGame({
        "nickName": _playerNameText,
        "roomName": _roomNameText,
      });
    }
  }

  void syncDataEx(RoomModel roomData, RoundModel roundData) {
    showProgressBar = false;

    final targetNick = playerDataWrap.playerModel?.nickName;
    final playerData = roomData.players
        .where((player) => player.nickName == targetNick)
        .firstOrNull;
    roomDataWrap.roomData = roomData;
    playerDataWrap.playerModel = playerData;
    roundDataWrap.roundModel = roundData;
    navigatorKey.currentState?.pushReplacementNamed('/paint_screen');
  }

  void notCorrectGameEx(String errMessage) {
    showProgressBar = false;
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(errMessage)));
  }
}
