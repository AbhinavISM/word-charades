import 'dart:ui';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:yayscribbl/models/player_model.dart';
import 'package:yayscribbl/models/point_model.dart';
import 'package:yayscribbl/models/room_model.dart';
import 'package:yayscribbl/repository/socket_client.dart';

class SocketRepository {
  final socket = SocketClient.instance.socket;

  void createGame(Map data) {
    socket?.emit('create_game', data);
  }

  void joinGame(Map data) {
    socket?.emit('join_game', data);
  }

  void updateRoomListener(Function fun) {
    socket?.off('update_room');
    socket?.on('update_room', (roomAndPlayer) {
      print(roomAndPlayer);
      RoomModel roomData = RoomModel.fromMap(roomAndPlayer['roomData']);
      PlayerModel player = PlayerModel.fromMap(roomAndPlayer['thisPlayer']);
      fun(roomData, player);
    });
  }

  void pointsToDrawListener(Function fun) {
    socket?.off('points_to_draw');
    socket?.on('points_to_draw', (points) {
      for (var point in points) {
        if (point != null) {
          fun(PointModel.fromJson(point));
        } else {
          fun(null);
        }
      }
    });
  }

  void colorChangeListener(Function fun) {
    socket?.off('color_change');
    socket?.on('color_change', (colorString) {
      int value = int.parse(colorString, radix: 16);
      Color updatedColor = Color(value);
      fun(updatedColor);
    });
  }

  void strokeWidthListener(Function fun) {
    socket?.off('stroke_width');
    socket?.on('stroke_width', (value) {
      fun(value.toDouble());
    });
  }

  void eraseAllListener(Function fun) {
    socket?.off('erase_all');
    socket?.on('erase_all', (_) {
      fun();
    });
  }

  void msgListener(Function fun) {
    socket?.off('msg');
    socket?.on('msg', (data) {
      fun(data);
    });
  }

  void changeTurnListener(Function fun) {
    socket?.off('change_turn');
    socket?.on('change_turn', (data) {
      RoomModel roomData = RoomModel.fromMap(data);
      fun(roomData);
    });
  }

  void closeInputListener(Function fun) {
    socket?.off('close_input');
    socket?.on('close_input', (_) {
      fun();
    });
  }

  void updateScoreListener(Function fun) {
    socket?.off('update_score');
    socket?.on('update_score', (data) {
      RoomModel roomData = RoomModel.fromMap(data);
      fun(roomData);
    });
  }

  void showLeaderBoardListener(Function fun) {
    socket?.off('show_leader_board');
    socket?.on('show_leader_board', (data) {
      RoomModel roomData = RoomModel.fromMap(data);
      fun(roomData);
    });
  }

  void userDisconnectedListener(Function fun) {
    socket?.off('user_disconnected');
    socket?.on('user_disconnected', (roomAndWhoDisconnected) {
      RoomModel roomData =
          RoomModel.fromMap(roomAndWhoDisconnected['roomData']);
      PlayerModel player =
          PlayerModel.fromMap(roomAndWhoDisconnected['playerWhoDisconnected']);
      fun(roomData, player);
    });
  }

  void notCorrectGameListener(Function fun) {
    socket?.on('notCorrectGame', (err) {
      fun(err);
    });
  }

  void onDisconnectListener() {
    socket?.onDisconnect((data) => print("disconnected"));
  }

  void onConnectErrorListener() {
    socket?.onConnectError((data) => print(data));
  }
}
