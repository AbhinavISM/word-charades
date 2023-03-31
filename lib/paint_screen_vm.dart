import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yayscribbl/room_data_provider.dart';
import 'package:yayscribbl/socket_repository.dart';

import 'models/touch_points.dart';

const String appId = "241714311a2a48569fd152d4411e5a9b";

class PaintScreenVM extends ChangeNotifier {
  final RoomData roomData;
  final SocketRepository socketRepository;
  PaintScreenVM(this.roomData, this.socketRepository) {
    connect();
  }
  bool firstBuild = true;
  late String nickName;
  List<TouchPoints?> points = [];
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
    socketRepository.userDisconnectedLsitener(userDisonnectedEx);
    socketRepository.notCorrectGameListener();
    socketRepository.onDisconnectListener();
    socketRepository.onConnectErrorListener();
  }

  void userDisonnectedEx(Map data) {
    roomData.updateDataOfRoom(data);
  }

  late RtcEngine agoraEngine;
  String token = '';
  int uid = 0; // uid of the local user
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _remoteUid = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          _remoteUid = null;
        },
      ),
    );
    join();
  }

  void join() async {
    // for (int i = 0; i < roomData.dataOfRoom?['players'].length; i++) {
    //   if (roomData.dataOfRoom?['players'][i]['nick_name'] == nickName) {
    //     uid = i;
    //     break;
    //   }
    // }
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
    _isJoined = false;
    _remoteUid = null;
    await agoraEngine.leaveChannel();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
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

  void pointsToDrawEx(Map point) {
    if (point['details'] != null) {
      points.add(TouchPoints(
        paint: Paint()
          ..strokeCap = strokeType
          ..isAntiAlias = true
          ..color = selectedColor.withOpacity(opacity)
          ..strokeWidth = strokeWidth,
        point: Offset(
          (point['details']['dx'] as double),
          (point['details']['dy'] as double),
        ),
      ));
    } else {
      print('null point aaya');
      points.add(null);
    }

    notifyListeners();
  }

  void updatedColorEx(Color updatedColor) {
    selectedColor = updatedColor;
    notifyListeners();
  }

  void strokeWidthEx(double sw) {
    strokeWidth = sw;
    notifyListeners();
  }

  void eraseAllEx() {
    points.clear();
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
    String oldword = roomData.dataOfRoom?['word'];
    print(data.toString());
    roomData.updateDataOfRoom(data);
    renderHiddenTextWidget(roomData.dataOfRoom?['word']);
    guessedUserCounter = 0;
    timeLeft = 60;
    points.clear();
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
