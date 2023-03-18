import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yayscribbl/room_data_provider.dart';
import 'package:yayscribbl/socket_repository.dart';

import 'models/touch_points.dart';

class PaintScreenVM extends ChangeNotifier {
  final RoomData roomData;
  late SocketRepository socketRepository;
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

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
      duration: Duration(milliseconds: 200),
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
