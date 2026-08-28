import 'package:yayscribbl/models/player_model.dart';
import 'package:yayscribbl/models/point_model.dart';
import 'package:yayscribbl/models/room_model.dart';
import 'package:yayscribbl/models/round_model.dart';

sealed class SocketEvent {
  const SocketEvent();
}

final class SyncDataEvent extends SocketEvent {
  final RoomModel roomData;
  final RoundModel roundData;
  const SyncDataEvent({required this.roomData, required this.roundData});
}

final class StartTimerEvent extends SocketEvent {
  final int startTime;
  final int duration;
  const StartTimerEvent({required this.startTime, required this.duration});
}

final class PointsToDrawEvent extends SocketEvent {
  final PointModel? pointModel;
  PointsToDrawEvent({required this.pointModel});
}

final class ColorChangeEvent extends SocketEvent {
  final int colorValue;
  ColorChangeEvent({required this.colorValue});
}

final class StrokeWidthChangeEvent extends SocketEvent {
  final double strokeWidth;
  StrokeWidthChangeEvent({required this.strokeWidth});
}

final class EraseAllEvent extends SocketEvent {}

final class MsgEvent extends SocketEvent {
  final Map msg;
  MsgEvent({required this.msg});
}

final class ShowLeaderboardEvent extends SocketEvent {
  final RoomModel roomData;
  ShowLeaderboardEvent({required this.roomData});
}

final class SomeoneDisconnectedEvent extends SocketEvent {
  final RoomModel roomData;
  final PlayerModel disconnectedUser;
  SomeoneDisconnectedEvent(
      {required this.roomData, required this.disconnectedUser});
}

final class SocketConnectedEvent extends SocketEvent {}

final class SocketDisconnectedEvent extends SocketEvent {}

final class NotCorrectGameEvent extends SocketEvent {
  final String message;
  NotCorrectGameEvent(this.message);
}
