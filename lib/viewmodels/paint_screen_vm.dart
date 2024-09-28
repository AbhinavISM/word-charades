import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yayscribbl/repository/socket_repository.dart';
import 'package:yayscribbl/viewmodels/room_data_provider.dart';

const String appId = "241714311a2a48569fd152d4411e5a9b";

class PaintScreenVM extends ChangeNotifier {
  final RoomData roomData;
  final SocketRepository socketRepository;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  PaintScreenVM(
      this.roomData, this.socketRepository, this.scaffoldMessengerKey) {
    connect();
  }
  bool firstBuild = true;
  late String nickName;
  List<Path> paths = [];
  List<Paint> pathPaints = [];
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
    socketRepository.showLeaderBoardListener(showLeaderBoardEx);
    socketRepository.userDisconnectedListener(userDisonnectedEx);
    socketRepository.onDisconnectListener();
    socketRepository.onConnectErrorListener();
  }

  void userDisonnectedEx(Map dataOfRoom, Map disconnectedUser) {
    roomData.updateDataOfRoom(dataOfRoom);
    final disconnectedNickName = disconnectedUser['nick_name'];
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
      channelId: roomData.dataOfRoom?['room_name'],
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
      if (timeLeft == 0 &&
          roomData.dataOfRoom?['turn']['nick_name'] == nickName) {
        socketRepository.socket
            ?.emit('change_turn', roomData.dataOfRoom?['room_name']);
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

  void updateRoomEx(Map data) {
    roomData.updateDataOfRoom(data);
    renderHiddenTextWidget(data['word']);
    if (data['isJoin'] != true) {
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

  void pointsToDrawEx(Map point) {
    if (point['details'] != null) {
      if (paths.isEmpty) {
        paths.add(Path());
        pathPaints.add(createPaint());
      }
      if (paths.last.getBounds().isEmpty) {
        paths.last.moveTo(point['details']['dx'], point['details']['dy']);
      } else {
        paths.last.lineTo(point['details']['dx'], point['details']['dy']);
      }
    } else {
      paths.add(Path());
      pathPaints.add(createPaint());
      print('null point aaya');
    }

    notifyListeners();
  }

  void updatedColorEx(Color updatedColor) {
    selectedColor = updatedColor;
    if (paths.isEmpty || !paths.last.getBounds().isEmpty) {
      paths.add(Path());
      pathPaints.add(createPaint());
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
    } else {
      pathPaints.last = createPaint();
    }
    notifyListeners();
  }

  void eraseAllEx() {
    paths.clear();
    pathPaints.clear();
    notifyListeners();
  }

  void msgEx(Map data) {
    messages.add(data);
    guessedUserCounter = data['guessedUserCounter'];
    if (roomData.dataOfRoom?['turn']['nick_name'] == nickName) {
      if (guessedUserCounter == (roomData.dataOfRoom?['players'].length - 1)) {
        socketRepository.socket
            ?.emit('change_turn', roomData.dataOfRoom?['room_name']);
      }
    }
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 40,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void changeTurnEx(Map data) {
    print('client change turn called');
    print(data.toString());
    roomData.updateDataOfRoom(data);
    renderHiddenTextWidget(roomData.dataOfRoom?['word']);
    guessedUserCounter = 0;
    timeLeft = 60;
    paths.clear();
    pathPaints.clear();
    alreadyGuessedByMe = false;
    timer.cancel();
    startTimer();
    notifyListeners();
  }

  void closeInputEx() {
    socketRepository.socket
        ?.emit('update_score', roomData.dataOfRoom?['room_name']);
    alreadyGuessedByMe = true;
    notifyListeners();
  }

  void updateScoreEx(Map data) {
    roomData.updateDataOfRoom(data);
    notifyListeners();
  }

  void showLeaderBoardEx(Map data) {
    print('told to show leader board');
    for (int i = 0; i < data['players'].length; i++) {
      if (winnerPoints < data['players'][i]['points']) {
        winner = data['players'][i]['nick_name'];
        winnerPoints = data['players'][i]['points'];
      }
    }
    timer.cancel();
    showFinalLeaderboardController.sink.add(true);
    // print('wether to show : ${showFinalLeaderboard}');
    timeLeft = 0;
    notifyListeners();
    roomData.updateDataOfRoom(data);
  }
}
