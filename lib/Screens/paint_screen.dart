import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/Screens/final_leader_board.dart';
import 'package:yayscribbl/Screens/waiting_screen.dart';
import 'package:yayscribbl/models/touch_points.dart';
import 'package:yayscribbl/vm_ps.dart';
import 'package:yayscribbl/socket_client.dart';
import 'package:yayscribbl/socket_repository.dart';

import '../models/my_custom_painter.dart';
import '../widgets/my_clipper.dart';
import '../widgets/side_drawer.dart';

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket socket;
  late SocketRepository socketRepository;
  // late Map dataOfRoom;
  late RoomData vmPs;
  late bool firstBuild;
  // late final dynamic routeArgs;
  late String nickName;
  List<TouchPoints> points = [];
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
  bool showFinalLeaderboard = false;

  @override
  void initState() {
    firstBuild = true;
    print('init state ran');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    socketRepository = Provider.of<SocketRepository>(context);
    socket = socketRepository.socket!;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    socket.dispose();
    timer.cancel();
    vmPs.updateDataOfRoom(null);
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
        socket.emit('change_turn', vmPs.dataOfRoom?['room_name']);
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          timeLeft--;
        });
      }
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
  }

  void updateRoomEx(Map roomData) {
    setState(() {
      vmPs.updateDataOfRoom(roomData);
      renderHiddenTextWidget(roomData['word']);
    });
    if (roomData['isJoin'] != true) {
      startTimer();
    }
  }

  void pointsToDrawEx(Map point) {
    setState(() {
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
    });
  }

  void updatedColorEx(Color updatedColor) {
    setState(() {
      selectedColor = updatedColor;
    });
  }

  void strokeWidthEx(double sw) {
    setState(() {
      strokeWidth = sw;
    });
  }

  void eraseAllEx() {
    setState(() {
      points.clear();
    });
  }

  void msgEx(Map data) {
    setState(() {
      messages.add(data);
      guessedUserCounter = data['guessedUserCounter'];
    });
    if (vmPs.dataOfRoom?['turn']['nick_name'] == nickName) {
      if (guessedUserCounter == (vmPs.dataOfRoom?['players'].length - 1)) {
        socket.emit('change_turn', vmPs.dataOfRoom?['room_name']);
      }
    }
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 40,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void changeTurnEx(Map data) {
    print('client change turn called');
    String oldword = vmPs.dataOfRoom?['word'];
    print(data.toString());
    setState(() {
      vmPs.updateDataOfRoom(data);
      renderHiddenTextWidget(vmPs.dataOfRoom?['word']);
      guessedUserCounter = 0;
      timeLeft = 60;
      points.clear();
      alreadyGuessedByMe = false;
      timer.cancel();
      startTimer();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Word was : $oldword')));
  }

  void closeInputEx() {
    socket.emit('update_score', vmPs.dataOfRoom?['room_name']);
    setState(() {
      alreadyGuessedByMe = true;
    });
  }

  void updateScoreEx(Map data) {
    setState((() {
      vmPs.updateDataOfRoom(data);
    }));
  }

  void showLeaderBoardEx(Map data) {
    for (int i = 0; i < data['players'].length; i++) {
      if (winnerPoints < data['players'][i]['points']) {
        winner = data['players'][i]['nick_name'];
        winnerPoints = data['players'][i]['points'];
      }
    }
    setState(() {
      vmPs.updateDataOfRoom(data);
      timer.cancel();
      showFinalLeaderboard = true;
      timeLeft = 0;
    });
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

    socket.on('user_disconnected', (data) {
      setState(() {
        vmPs.updateDataOfRoom(data);
      });
    });

    socket.on('notCorrectGame', (err) {
      print(err.toString());
    });

    socket.onDisconnect((data) => print("disconnected"));

    socket.onConnectError((data) => print(data.toString()));
  }

  @override
  Widget build(BuildContext context) {
    void selectColor() {
      showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Choose Color'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: ((color) {
                    String colorString = color.toString();
                    String valueString =
                        colorString.split('(0x')[1].split(')')[0];
                    Map map = {
                      'color': valueString,
                      'room_name': vmPs.dataOfRoom?['room_name']
                    };
                    socket.emit('color_change', map);
                  }),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                )
              ],
            )),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    vmPs = Provider.of<RoomData>(context);

    if (firstBuild) {
      print('first build jsut ran');
      connect();
      setState(() {
        // dataOfRoom = Provider.of<RoomData>(context).dataOfRoom as Map;
        nickName = ModalRoute.of(context)?.settings.arguments as String;
        renderHiddenTextWidget(vmPs.dataOfRoom?['word']);
      });
      if (vmPs.dataOfRoom?['isJoin'] != true) {
        startTimer();
      }
      firstBuild = false;
    }
    return Scaffold(
      drawer: vmPs.dataOfRoom != null
          ? SideDrawer(
              players_list: vmPs.dataOfRoom?['players'],
            )
          : Container(),
      key: scaffoldKey,
      body: vmPs.dataOfRoom != null
          ? vmPs.dataOfRoom!['isJoin'] != true
              ? !showFinalLeaderboard
                  ? Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: width,
                              height: height * 0.5,
                              child: GestureDetector(
                                onPanUpdate: vmPs.dataOfRoom?['turn']
                                            ['nick_name'] ==
                                        nickName
                                    ? (details) {
                                        print(details.localPosition.dx);
                                        socket.emit('paint', {
                                          'details': {
                                            'dx': details.localPosition.dx,
                                            'dy': details.localPosition.dy,
                                          },
                                          'room_name':
                                              vmPs.dataOfRoom?['room_name'],
                                        });
                                      }
                                    : (details) {},
                                onPanStart: vmPs.dataOfRoom?['turn']
                                            ['nick_name'] ==
                                        nickName
                                    ? (details) {
                                        print(details.localPosition.dx);
                                        socket.emit('paint', {
                                          'details': {
                                            'dx': details.localPosition.dx,
                                            'dy': details.localPosition.dy,
                                          },
                                          'room_name':
                                              vmPs.dataOfRoom?['room_name'],
                                        });
                                      }
                                    : (details) {},
                                onPanEnd: vmPs.dataOfRoom?['turn']
                                            ['nick_name'] ==
                                        nickName
                                    ? (details) {
                                        socket.emit('paint', {
                                          'details': null,
                                          'room_name':
                                              vmPs.dataOfRoom?['room_name'],
                                        });
                                      }
                                    : (details) {},
                                child: SizedBox.expand(
                                  child: RepaintBoundary(
                                    child: ClipRect(
                                      clipper: MyClipper(
                                          height: height * 0.55, width: width),
                                      child: CustomPaint(
                                        size: Size.infinite,
                                        painter:
                                            MyCustomPainter(pointsList: points),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            vmPs.dataOfRoom?['turn']['nick_name'] == nickName
                                ? Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.color_lens,
                                          color: selectedColor,
                                        ),
                                        onPressed: () {
                                          selectColor();
                                        },
                                      ),
                                      Expanded(
                                        child: Slider(
                                          min: 1.0,
                                          max: 10.0,
                                          label: 'Strokewidth $strokeWidth',
                                          value: strokeWidth,
                                          activeColor: selectedColor,
                                          onChanged: (double value) {
                                            Map map = {
                                              'value': value,
                                              'room_name':
                                                  vmPs.dataOfRoom?['room_name'],
                                            };
                                            socket.emit('stroke_width', map);
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          socket.emit('erase_all',
                                              vmPs.dataOfRoom?['room_name']);
                                        },
                                        icon: const Icon(Icons.clear_all),
                                      )
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      "${vmPs.dataOfRoom?["turn"]["nick_name"]} is drawing..",
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            vmPs.dataOfRoom?['turn']['nick_name'] != nickName
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: hiddenTextWidget,
                                  )
                                : Center(
                                    child: Text(
                                      vmPs.dataOfRoom?['word'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    // ignore: prefer_const_constructors
                                    title: Text(
                                      messages[index]["sender_name"],
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      messages[index]["message"],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  );
                                },
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: messages.length,
                              ),
                            ),
                          ],
                        ),
                        vmPs.dataOfRoom?['turn']['nick_name'] != nickName
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextField(
                                    readOnly: alreadyGuessedByMe,
                                    controller: controller,
                                    onSubmitted: ((value) {
                                      if (value.trim().isNotEmpty) {
                                        Map msgMap = {
                                          'sender_name': nickName,
                                          'message': value.trim(),
                                          'word': vmPs.dataOfRoom?["word"],
                                          'room_name':
                                              vmPs.dataOfRoom?["room_name"],
                                          'guessedUserCounter':
                                              guessedUserCounter,
                                          'total_time': 60,
                                          'time_taken': 60 - timeLeft,
                                        };
                                        socket.emit('msg', msgMap);
                                        controller.clear();
                                      }
                                    }),
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                      labelText: "guess the word!",
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          255, 244, 244, 244),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                    ),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              )
                            : Container(),
                        SafeArea(
                          child: IconButton(
                            icon: Icon(Icons.menu),
                            onPressed: () =>
                                scaffoldKey.currentState!.openDrawer(),
                          ),
                        ),
                      ],
                    )
                  : FinalLeaderBoard(players_list: vmPs.dataOfRoom?['players'])
              : WaitingScreen(
                  room_name: vmPs.dataOfRoom?['room_name'],
                  current_room_size: vmPs.dataOfRoom?['players'].length,
                  room_size: vmPs.dataOfRoom?['room_size'],
                  players_list: vmPs.dataOfRoom?['players'],
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            '$timeLeft',
            style: const TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
