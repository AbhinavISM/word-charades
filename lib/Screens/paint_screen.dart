import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/models/touch_points.dart';

import '../models/my_custom_painter.dart';

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

  @override
  void initState() {
    connect();
    super.initState();
    // connect();
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
        });
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
        body: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: height * 0.6,
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
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: MyCustomPainter(pointsList: points),
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
                    socket.emit('erase_all', dataOfRoom['room_name']);
                  },
                  icon: const Icon(Icons.clear_all),
                )
              ],
            ),
          ],
        )
      ],
    ));
  }
}
