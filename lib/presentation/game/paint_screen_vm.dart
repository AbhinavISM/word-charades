import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yayscribbl/models/batch_processing_events.dart';
import 'package:yayscribbl/models/paint_screen_ui_commands.dart';
import 'package:yayscribbl/models/player_data_provider.dart';
import 'package:yayscribbl/models/player_model.dart';
import 'package:yayscribbl/models/point_model.dart';
import 'package:yayscribbl/models/room_data_provider.dart';
import 'package:yayscribbl/models/room_model.dart';
import 'package:yayscribbl/models/round_data_provider.dart';
import 'package:yayscribbl/models/round_model.dart';
import 'package:yayscribbl/models/socket_events.dart';
import 'package:yayscribbl/utils/point_throttler.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

class PaintScreenVM extends ChangeNotifier {
  final RoomDataWrap roomDataWrap;
  final PlayerDataWrap playerDataWrap;
  final RoundDataWrap roundDataWrap;
  final SocketRepository socketRepository;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final PointThrottler pointThrottler;

  late final StreamSubscription<SocketEvent> _socketSubscription;
  late final StreamSubscription<BatchProcessingEvents>
      _batchProcessingStreamSub;

  PaintScreenVM(
      this.roomDataWrap,
      this.socketRepository,
      this.scaffoldMessengerKey,
      this.playerDataWrap,
      this.roundDataWrap,
      this.pointThrottler) {
    _socketSubscription =
        socketRepository.eventStream.listen(_handleSocketEvent);
    _batchProcessingStreamSub = pointThrottler.batchProcessingEventStream
        .listen(handleBatchProcessingEvents);
  }

  void handleBatchProcessingEvents(BatchProcessingEvents event) {
    switch (event) {
      case BatchTimerFinished():
        _sendPoints(event.processedPoints);
    }
  }

  void _sendPoints(List<PointModel?> points) {
    socketRepository.socket.emit('paint', {
      'details': points.map((p) => p?.toJson()).toList(),
      'roomName': roomDataWrap.roomData!.roomName,
    });
  }

  //drawing state
  double? canvasWidth;
  double? canvasHeight;
  List<Path> paths = [];
  List<Paint> pathPaints = [];
  List<List<PointModel>> pathPoints = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;

  //game state
  List<Widget> hiddenTextWidget = [];
  List<Map> messages = [];

  int winnerPoints = 0;
  String winner = '';

  int secondsRemaining = 0;
  bool isRunning = false;
  Timer? _ticker;
  DateTime? _endTime;

  //misc
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final _paintScreenUIEventStreamController =
      StreamController<PaintScreenUiCommands>();
  Stream<PaintScreenUiCommands> get paintScreenUIEventStream =>
      _paintScreenUIEventStreamController.stream;
  Sink<PaintScreenUiCommands> get _paintScreenUIEventSink =>
      _paintScreenUIEventStreamController.sink;

  bool showFinalLeaderboard = false;

  void _handleSocketEvent(SocketEvent event) {
    switch (event) {
      case SyncDataEvent():
        syncDataEx(roomData: event.roomData, roundData: event.roundData);
        break;
      case StartTimerEvent():
        startTimerEx(event.startTime, event.duration);
        break;
      case PointsToDrawEvent():
        pointsToDrawEx(point: event.pointModel);
        break;
      case ColorChangeEvent():
        updatedColorEx(event.colorValue);
        break;
      case StrokeWidthChangeEvent():
        strokeWidthEx(event.strokeWidth);
        break;
      case EraseAllEvent():
        eraseAllEx();
        break;
      case MsgEvent():
        msgEx(event.msg);
        break;
      case ShowLeaderboardEvent():
        showLeaderBoardEx(event.roomData);
      case SomeoneDisconnectedEvent():
        someoneDisonnectedEx(event.roomData, event.disconnectedUser);
        break;
      case SocketConnectedEvent():
        print('socket connected');
      case SocketDisconnectedEvent():
        print('socket disconnected');
      case _:
        break;
    }
  }

  void startTimerEx(int serverStartTimeMillis, int durationSeconds) {
    final serverStartTime =
        DateTime.fromMillisecondsSinceEpoch(serverStartTimeMillis);
    _endTime = serverStartTime.add(Duration(seconds: durationSeconds));
    _startLocalLoop();
  }

  void _startLocalLoop() {
    _ticker?.cancel();

    // We tick fast (e.g., every 100ms) to ensure the UI feels responsive
    // and we don't miss the moment it hits 0.
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final now = DateTime.now();

      // Calculate remaining difference
      final difference = _endTime!.difference(now);
      final secondsLeft = difference.inSeconds;

      if (secondsLeft <= 0) {
        stopTimer();
      } else {
        if (secondsRemaining != secondsLeft) {
          secondsRemaining = secondsLeft;
          isRunning = true;
        }
      }
    });
  }

  void stopTimer() {
    _ticker?.cancel();
    secondsRemaining = 0;
    isRunning = false;
  }

  void renderHiddenTextWidget(String text) {
    hiddenTextWidget.clear();
    for (int i = 0; i < text.length; i++) {
      hiddenTextWidget.add(const Text(
        '_',
        style: TextStyle(fontSize: 16),
      ));
    }
    notifyListeners();
  }

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void sendPoints(PaintScreenVM paintScreenVM, double? dx, double? dy,
      double canvasWidth, double canvasHeight) {
    print('emitdx : $dx , emitdy : $dy\n');
    PointModel? point;
    if (dx != null && dy != null) {
      point = PointModel(
        dx: dx.toDouble(),
        dy: dy.toDouble(),
        sourceDrawingWidth: canvasWidth.toDouble(),
        sourceDrawingHeight: canvasHeight.toDouble(),
      );
    }
    pointThrottler.addPoint(point);
    pointsToDrawEx(point: point);
  }

  void changeColor(Color color) {
    String colorString = color.toString();
    String valueString = colorString.split('(0x')[1].split(')')[0];
    Map map = {
      'color': valueString,
      'roomName': roomDataWrap.roomData!.roomName
    };
    socketRepository.socket.emit('color_change', map);
  }

  void changeStrokeWidth(double value) {
    Map map = {
      'value': value,
      'roomName': roomDataWrap.roomData!.roomName,
    };
    socketRepository.socket.emit('stroke_width', map);
  }

  void sendMsg(String value) {
    if (value.trim().isNotEmpty) {
      Map msgMap = {
        'senderName': playerDataWrap.playerModel!.nickName,
        'message': value.trim(),
        'roomName': roomDataWrap.roomData!.roomName,
      };
      socketRepository.socket.emit('msg', msgMap);
      _paintScreenUIEventSink.add(ClearMsgEvent());
    }
  }

  void eraseAll() {
    socketRepository.socket.emit('erase_all', roomDataWrap.roomData!.roomName);
  }

  @override
  void dispose() {
    pointThrottler.cancel();
    _socketSubscription.cancel();
    _batchProcessingStreamSub.cancel();
    super.dispose();
  }

  (double, double) normalizeCoordinates(PointModel point) {
    double dx = point.dx;
    double dy = point.dy;
    double drawingUserScreenWidth = point.sourceDrawingWidth;
    double drawingUserScreenHeight = point.sourceDrawingHeight;

    double widthRatio = canvasWidth! / drawingUserScreenWidth;
    double heightRatio = canvasHeight! / drawingUserScreenHeight;
    double scaleFactor = min(widthRatio, heightRatio);

    double scaledX = dx * scaleFactor;
    double scaledY = dy * scaleFactor;

    double xOffset = (canvasWidth! - drawingUserScreenWidth * scaleFactor) / 2;
    double yOffset =
        (canvasHeight! - drawingUserScreenHeight * scaleFactor) / 2;

    double finalX = scaledX + xOffset;
    double finalY = scaledY + yOffset;
    return (finalX, finalY);
  }

  //do you remember how this worked??
  void resizeDrawing() {
    paths = [];
    for (List<PointModel> points in pathPoints) {
      paths.add(Path());
      for (int i = 0; i < points.length; i++) {
        PointModel point = points[i];
        final (finalX, finalY) = normalizeCoordinates(point);
        if (i == 0) {
          paths.last.moveTo(finalX, finalY);
        } else {
          paths.last.lineTo(finalX, finalY);
        }
      }
    }
    notifyListeners();
  }

  Paint createPaint() {
    return Paint()
      ..strokeCap = strokeType
      ..isAntiAlias = true
      ..color = selectedColor.withOpacity(opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.bevel;
  }

  void pointsToDrawEx({PointModel? point}) {
    if (point != null) {
      final (finalX, finalY) = normalizeCoordinates(point);
      if (paths.isEmpty) {
        paths.add(Path());
        pathPaints.add(createPaint());
        pathPoints.add([]);
      }
      if (paths.last.getBounds().isEmpty) {
        paths.last.moveTo(finalX, finalY);
        pathPoints.last.add(point);
      } else {
        paths.last.lineTo(finalX, finalY);
        pathPoints.last.add(point);
      }
    } else {
      paths.add(Path());
      pathPaints.add(createPaint());
      pathPoints.add([]);
    }

    notifyListeners();
  }

  void syncDataEx(
      {required RoomModel roomData, required RoundModel roundData}) {
    roomDataWrap.roomData = (roomData);
    PlayerModel? playerData;
    for (PlayerModel player in roomData.players) {
      if (player.nickName == playerDataWrap.playerModel?.nickName) {
        playerData = player;
      }
    }
    playerDataWrap.playerModel = (playerData);
    roundDataWrap.roundModel = (roundData);
    renderHiddenTextWidget(roomData.word);
    notifyListeners();
  }

  void updatedColorEx(int value) {
    Color updatedColor = Color(value);
    selectedColor = updatedColor;
    if (paths.isEmpty || !paths.last.getBounds().isEmpty) {
      paths.add(Path());
      pathPaints.add(createPaint());
      pathPoints.add([]);
    } else {
      pathPaints.last = createPaint();
    }
    notifyListeners();
  }

  void strokeWidthEx(double sw) {
    strokeWidth = sw;
    if (paths.isEmpty || !paths.last.getBounds().isEmpty) {
      paths.add(Path());
      pathPaints.add(createPaint());
      pathPoints.add([]);
    } else {
      pathPaints.last = createPaint();
    }
    notifyListeners();
  }

  void eraseAllEx() {
    paths.clear();
    pathPaints.clear();
    pathPoints.clear();
    notifyListeners();
  }

  void msgEx(Map data) {
    messages.add(data);
    _paintScreenUIEventSink.add(ScrollEvent());
    notifyListeners();
  }

  void showLeaderBoardEx(RoomModel roomData) {
    for (int i = 0; i < roomData.players.length; i++) {
      if (winnerPoints < roomData.players[i].points) {
        winner = roomData.players[i].nickName;
        winnerPoints = roomData.players[i].points;
      }
    }
    showFinalLeaderboard = true;
    notifyListeners();
    roomDataWrap.roomData = (roomData);
  }

  void someoneDisonnectedEx(RoomModel roomData, PlayerModel disconnectedUser) {
    roomDataWrap.roomData = (roomData);
    final disconnectedNickName = disconnectedUser.nickName;
    scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('{$disconnectedNickName} disconnected')));
  }
}
