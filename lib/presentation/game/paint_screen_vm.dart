import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yayscribbl/models/player_model.dart';
import 'package:yayscribbl/models/point_model.dart';
import 'package:yayscribbl/models/room_data_provider.dart';
import 'package:yayscribbl/models/room_model.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

const String appId = "241714311a2a48569fd152d4411e5a9b";

class PaintScreenVM extends ChangeNotifier {
  final RoomDataWrap roomDataWrap;
  final SocketRepository socketRepository;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  PaintScreenVM(
      this.roomDataWrap, this.socketRepository, this.scaffoldMessengerKey) {
    connect();
    setupDrawingHandler();
  }
  double? canvasWidth;
  double? canvasHeight;
  bool firstBuild = true;
  late String nickName;
  List<Path> paths = [];
  List<Paint> pathPaints = [];
  List<List<PointModel>> pathPoints = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> hiddenTextWidget = [];
  ScrollController scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController controller = TextEditingController();
  int guessedUserCounter = 0;
  int timeLeft = 60;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer timer;
  bool alreadyGuessedByMe = false;
  int winnerPoints = 0;
  String winner = '';
  // bool showFinalLeaderboard = false;
  final StreamController<bool> showFinalLeaderboardController =
      StreamController.broadcast();

  setFirstBuild(bool b) {
    firstBuild = b;
    notifyListeners();
  }

  void connect() {
    socketRepository.updateRoomListener(updateRoomEx);
    socketRepository.pointsToDrawListener(pointsToDrawEx);
    socketRepository.colorChangeListener(updatedColorEx);
    socketRepository.strokeWidthListener(strokeWidthEx);
    socketRepository.eraseAllListener(eraseAllEx);
    socketRepository.msgListener(msgEx);
    socketRepository.changeTurnListener(changeTurnEx);
    socketRepository.closeInputListener(closeInputEx);
    socketRepository.updateScoreListener(updateScoreEx);
    socketRepository.showLeaderBoardListener(showLeaderBoardEx);
    socketRepository.userDisconnectedListener(userDisonnectedEx);
    socketRepository.onDisconnectListener();
    socketRepository.onConnectErrorListener();
  }

  void userDisonnectedEx(RoomModel roomData, PlayerModel disconnectedUser) {
    roomDataWrap.updateDataOfRoom(roomData);
    final disconnectedNickName = disconnectedUser.nickName;
    scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('{$disconnectedNickName} disconnected')));
  }

  late RtcEngine agoraEngine;
  String token = '';
  int uid = 0; // uid of the local user
  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {},
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {},
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {},
      ),
    );
    join();
  }

  void join() async {
    uid = DateTime.now().millisecondsSinceEpoch;
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      channelId: roomDataWrap.roomData!.roomName,
      options: options,
      uid: uid,
      token: token,
    );
  }

  void leave() async {
    await agoraEngine.leaveChannel();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft == 0 && roomDataWrap.roomData!.turn.nickName == nickName) {
        socketRepository.socket
            ?.emit('change_turn', roomDataWrap.roomData!.roomName);
        timer.cancel();
      } else {
        timeLeft--;
      }
      notifyListeners();
    });
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

  final StreamController<PointModel?> _pointController =
      StreamController<PointModel?>();
  Timer? _batchTimer;
  List<PointModel?> _pointBuffer = [];
  List<PointModel?> _processingBuffer = [];
  bool _isProcessing = false;

  void _processPoints() {
    if (_pointBuffer.isEmpty || _isProcessing) return;

    try {
      _isProcessing = true;

      _processingBuffer = _pointBuffer;
      _pointBuffer = [];

      socketRepository.socket?.emit('paint', {
        'details': _processingBuffer.map((p) => p?.toJson()).toList(),
        'room_name': roomDataWrap.roomData!.roomName,
      });

      _processingBuffer.clear();
    } catch (e) {
      print('Error preparing points for sending: $e');
      // Recover points if preparation failed
      _pointBuffer.insertAll(0, _processingBuffer);
    } finally {
      _isProcessing = false;
      // If there are new points that arrived during processing,
      // start a new batch timer
      if (_pointBuffer.isNotEmpty) {
        _startBatchTimer();
      }
    }
  }

  void _startBatchTimer() {
    // Only start a new timer if one isn't already running
    if (_batchTimer == null || !_batchTimer!.isActive) {
      _batchTimer = Timer(const Duration(milliseconds: 16), () {
        _processPoints();
      });
    }
  }

  void setupDrawingHandler() {
    _pointController.stream.listen((PointModel? point) {
      _pointBuffer.add(point);
      _startBatchTimer();
    }, onError: (error) {
      print('Error in point stream: $error');
    });
  }

  void sendPoints(PointModel? point) {
    _pointController.add(point);
    pointsToDrawEx(point);
  }

  @override
  void dispose() {
    super.dispose();
    _batchTimer?.cancel();
    // Process remaining points one last time
    if (_pointBuffer.isNotEmpty) {
      _processPoints();
    }
    _pointController.close();
  }

  void updateRoomEx(RoomModel roomData, PlayerModel player) {
    roomDataWrap.updateDataOfRoom(roomData);
    renderHiddenTextWidget(roomData.word);
    if (roomData.canJoin != true) {
      startTimer();
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

  void pointsToDrawEx(PointModel? point) {
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

  void updatedColorEx(Color updatedColor) {
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
    guessedUserCounter = data['guessedUserCounter'];
    if (roomDataWrap.roomData!.turn.nickName == nickName) {
      if (guessedUserCounter == (roomDataWrap.roomData!.players.length - 1)) {
        socketRepository.socket
            ?.emit('change_turn', roomDataWrap.roomData!.roomName);
      }
    }
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 40,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void changeTurnEx(RoomModel roomData) {
    print('client change turn called');
    print(roomData.toString());
    roomDataWrap.updateDataOfRoom(roomData);
    renderHiddenTextWidget(roomDataWrap.roomData!.word);
    guessedUserCounter = 0;
    timeLeft = 60;
    paths.clear();
    pathPaints.clear();
    pathPoints.clear();
    alreadyGuessedByMe = false;
    timer.cancel();
    startTimer();
    notifyListeners();
  }

  void closeInputEx() {
    socketRepository.socket
        ?.emit('update_score', roomDataWrap.roomData!.roomName);
    alreadyGuessedByMe = true;
    notifyListeners();
  }

  void updateScoreEx(RoomModel roomData) {
    roomDataWrap.updateDataOfRoom(roomData);
    notifyListeners();
  }

  void showLeaderBoardEx(RoomModel roomData) {
    print('told to show leader board');
    for (int i = 0; i < roomData.players.length; i++) {
      if (winnerPoints < roomData.players[i].points) {
        winner = roomData.players[i].nickName;
        winnerPoints = roomData.players[i].points;
      }
    }
    timer.cancel();
    showFinalLeaderboardController.sink.add(true);
    // print('wether to show : ${showFinalLeaderboard}');
    timeLeft = 0;
    notifyListeners();
    roomDataWrap.updateDataOfRoom(roomData);
  }
}
