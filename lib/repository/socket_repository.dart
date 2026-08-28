import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/models/player_model.dart';
import 'package:yayscribbl/models/point_model.dart';
import 'package:yayscribbl/models/room_model.dart';
import 'package:yayscribbl/models/round_model.dart';
import 'package:yayscribbl/models/socket_events.dart';

class SocketRepository {
  final IO.Socket socket;

  SocketRepository({required this.socket}) {
    _initializeListeners();
  }
  // The Single Source of Truth
  final _eventController = StreamController<SocketEvent>.broadcast();

  // Public getter
  Stream<SocketEvent> get eventStream => _eventController.stream;

  void _initializeListeners() {
    socket.on('update_room', (roomAndPlayer) {
      print('Update room event received: ${roomAndPlayer.toString()}');
      RoomModel roomData = RoomModel.fromMap(roomAndPlayer['roomData']);
      RoundModel round = RoundModel.fromMap(roomAndPlayer['round']);
      _eventController.add(SyncDataEvent(roomData: roomData, roundData: round));
    });

    socket.on('start_timer', (data) {
      final startTime = data['startTime'];
      final duration = data['duration'];

      _eventController
          .add(StartTimerEvent(startTime: startTime, duration: duration));
    });

    socket.on('points_to_draw', (points) {
      for (var point in points) {
        if (point != null) {
          _eventController
              .add(PointsToDrawEvent(pointModel: PointModel.fromJson(point)));
        } else {
          _eventController.add(PointsToDrawEvent(pointModel: null));
        }
      }
    });

    socket.on('color_change', (colorString) {
      _eventController
          .add(ColorChangeEvent(colorValue: int.parse(colorString, radix: 16)));
    });

    socket.on('stroke_width', (value) {
      _eventController
          .add(StrokeWidthChangeEvent(strokeWidth: value.toDouble()));
    });

    socket.on('erase_all', (_) {
      _eventController.add(EraseAllEvent());
    });

    socket.on('msg', (data) {
      _eventController.add(MsgEvent(msg: data));
    });

    socket.on('show_leader_board', (data) {
      RoomModel roomData = RoomModel.fromMap(data);
      _eventController.add(ShowLeaderboardEvent(roomData: roomData));
    });

    socket.on('user_disconnected', (roomAndWhoDisconnected) {
      RoomModel roomData =
          RoomModel.fromMap(roomAndWhoDisconnected['roomData']);
      PlayerModel player =
          PlayerModel.fromMap(roomAndWhoDisconnected['playerWhoDisconnected']);
      _eventController.add(SomeoneDisconnectedEvent(
          roomData: roomData, disconnectedUser: player));
    });

    socket.on('notCorrectGame', (err) {
      _eventController.add(NotCorrectGameEvent(err));
    });
  }

  void createGame(Map data) {
    socket.emit('create_game', data);
  }

  void joinGame(Map data) {
    socket.emit('join_game', data);
  }

  void dispose() {
    _eventController.close();
    socket.off('update_room');
    socket.off('sync_timer');
    socket.off('points_to_draw');
    socket.off('color_change');
    socket.off('stroke_width');
    socket.off('erase_all');
    socket.off('msg');
    socket.off('show_leader_board');
    socket.off('user_disconnected');
    socket.off('notCorrectGame');
  }
}
