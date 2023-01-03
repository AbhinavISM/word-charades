import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/Screens/final_leader_board.dart';
import 'package:yayscribbl/Screens/waiting_screen.dart';
import 'package:yayscribbl/models/touch_points.dart';

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
  Map dataOfRoom = {};
  bool firstBuild = true;
  late dynamic routeArgs;
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
    connect();
    super.initState();
    // connect();
  }

  @override
  void dispose() {
    socket.dispose();
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
        socket.emit('change_turn', dataOfRoom['room_name']);
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

  void connect() {
    socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();

    socket.onConnect((data) {
      print("connected to socket");
      socket.on('update_room', (roomData) {
        setState(() {
          dataOfRoom = roomData;
          renderHiddenTextWidget(roomData['word']);
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
      });
    });

    socket.on('points_to_draw', (point) {
      if (point['details'] != null) {
        setState(() {
          points.add(TouchPoints(
            paint: Paint()
              ..strokeCap = strokeType
              ..isAntiAlias = true
              ..color = selectedColor.withOpacity(opacity)
              ..strokeWidth = strokeWidth,
            point: Offset(
              (point['details']['dx']),
              (point['details']['dy']),
            ),
          ));
        });
      }
    });

    socket.on('color_change', (colorString) {
      int value = int.parse(colorString, radix: 16);
      Color updatedColor = Color(value);
      setState(() {
        selectedColor = updatedColor;
      });
    });

    socket.on('stroke_width', (value) {
      setState(() {
        strokeWidth = value.toDouble();
      });
    });

    socket.on('erase_all', (_) {
      setState(() {
        points.clear();
      });
    });

    socket.on('msg', (data) {
      setState(() {
        messages.add(data);
        guessedUserCounter = data['guessedUserCounter'];
      });
      if (guessedUserCounter == (dataOfRoom['players'].length - 1)) {
        print('idhar hain main');
        socket.emit('change_turn', dataOfRoom['room_name']);
      }
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 40,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });

    socket.on('change_turn', (data) {
      String oldword = dataOfRoom['word'];
      print('app changed turn called');
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 3), () {
              setState(() {
                dataOfRoom = data;
                renderHiddenTextWidget(data['word']);
                guessedUserCounter = 0;
                timeLeft = 60;
                points.clear();
                alreadyGuessedByMe = false;
              });
              Navigator.of(context).pop();
              timer.cancel();
              startTimer();
            });
            return AlertDialog(
              title: Center(
                child: Text('word was: $oldword'),
              ),
            );
          });
    });

    socket.on('close_input', (_) {
      socket.emit('update_score', dataOfRoom['room_name']);
      setState(() {
        alreadyGuessedByMe = true;
      });
    });

    socket.on('update_score', (data) {
      setState((() {
        dataOfRoom = data;
      }));
    });

    socket.on('show_leader_board', (data) {
      for (int i = 0; i < data['players'].length; i++) {
        if (winnerPoints < data['players'][i]['points']) {
          winner = data['players'][i]['nick_name'];
          winnerPoints = data['players'][i]['points'];
        }
      }
      setState(() {
        dataOfRoom = data;
        timer.cancel();
        showFinalLeaderboard = true;
        timeLeft = 0;
      });
    });

    socket.on('user_disconnected', (data) {
      setState(() {
        dataOfRoom = data;
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
                      'room_name': dataOfRoom['room_name']
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

    ;

    if (firstBuild) {
      routeArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      print(routeArgs.toString());
      if (routeArgs['screen_from'] == 'create_room_screen') {
        socket.emit('create_game', routeArgs);
      } else {
        socket.emit('join_game', routeArgs);
      }
      firstBuild = false;
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: SideDrawer(
        players_list: dataOfRoom['players'],
      ),
      key: scaffoldKey,
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
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
                                onPanUpdate: (details) {
                                  print(details.localPosition.dx);
                                  socket.emit('paint', {
                                    'details': {
                                      'dx': details.localPosition.dx,
                                      'dy': details.localPosition.dy,
                                    },
                                    'room_name': routeArgs['room_name'],
                                  });
                                },
                                onPanStart: (details) {
                                  print(details.localPosition.dx);
                                  socket.emit('paint', {
                                    'details': {
                                      'dx': details.localPosition.dx,
                                      'dy': details.localPosition.dy,
                                    },
                                    'room_name': routeArgs['room_name'],
                                  });
                                },
                                onPanEnd: (details) {
                                  socket.emit('paint', {
                                    'details': null,
                                    'room_name': routeArgs['room_name'],
                                  });
                                },
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
                            Row(
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
                                        'room_name': dataOfRoom['room_name'],
                                      };
                                      socket.emit('stroke_width', map);
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    socket.emit(
                                        'erase_all', dataOfRoom['room_name']);
                                  },
                                  icon: const Icon(Icons.clear_all),
                                )
                              ],
                            ),
                            dataOfRoom['turn']['nick_name'] !=
                                    routeArgs['nick_name']
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: hiddenTextWidget,
                                  )
                                : Center(
                                    child: Text(
                                      dataOfRoom['word'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
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
                        dataOfRoom['turn']['nick_name'] !=
                                routeArgs['nick_name']
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
                                          'sender_name': routeArgs["nick_name"],
                                          'message': value.trim(),
                                          'word': dataOfRoom["word"],
                                          'room_name': dataOfRoom["room_name"],
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
                  : FinalLeaderBoard(players_list: dataOfRoom['players'])
              : WaitingScreen(
                  room_name: dataOfRoom['room_name'],
                  current_room_size: dataOfRoom['players'].length,
                  room_size: dataOfRoom['room_size'],
                  players_list: dataOfRoom['players'],
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
