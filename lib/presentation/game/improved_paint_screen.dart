import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/main.dart';
import 'package:yayscribbl/models/point_model.dart';
import 'package:yayscribbl/presentation/finish_game/final_leader_board.dart';
import 'package:yayscribbl/presentation/game/my_clipper.dart';
import 'package:yayscribbl/presentation/game/my_custom_painter.dart';
import 'package:yayscribbl/presentation/game/paint_screen_vm.dart';
import 'package:yayscribbl/presentation/waiting/waiting_screen.dart';
import 'package:yayscribbl/widgets/side_drawer.dart';

class ImprovedPaintScreen extends ConsumerStatefulWidget {
  const ImprovedPaintScreen({super.key});

  @override
  ConsumerState<ImprovedPaintScreen> createState() =>
      _ImprovedPaintScreenState();
}

class _ImprovedPaintScreenState extends ConsumerState<ImprovedPaintScreen> {
  @override
  void initState() {
    print('init state ran');
    ref.read(paintScreenVMprovider).setupVoiceSDKEngine();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // socket.dispose();
    final paintScreenVM = ref.read(paintScreenVMprovider);
    paintScreenVM.firstBuild = true;
    paintScreenVM.timer.cancel();
    paintScreenVM.roomDataWrap.updateDataOfRoom(null);
    paintScreenVM.leave();
    ref.read(paintScreenVMprovider).dispose();
    super.dispose();
  }

  void onFirstBuild(PaintScreenVM paintScreenVM) {
    //can_join means true means someone is still left to join
    if (paintScreenVM.roomDataWrap.roomData!.canJoin == true) {
      return;
    }
    paintScreenVM
        .renderHiddenTextWidget(paintScreenVM.roomDataWrap.roomData!.word);
    paintScreenVM.startTimer();
    paintScreenVM.firstBuild = false;
  }

  @override
  Widget build(BuildContext context) {
    final paintScreenVM = ref.watch(paintScreenVMprovider);
    paintScreenVM.nickName =
        ModalRoute.of(context)?.settings.arguments as String;
    print('vmid : ${identityHashCode(paintScreenVM)}');
    if (paintScreenVM.firstBuild) {
      print('first build just ran');
      Future.delayed(Duration.zero)
          .then((value) => {onFirstBuild(paintScreenVM)});
    }

    return Scaffold(
      drawer: _buildDrawer(paintScreenVM),
      floatingActionButton: _timerFloatingActionButton(paintScreenVM),
      key: paintScreenVM.scaffoldKey,
      body: paintScreenVM.roomDataWrap.roomData != null
          ? paintScreenVM.roomDataWrap.roomData!.canJoin != true
              ? _buildGame(paintScreenVM)
              : WaitingScreen(
                  roomName: paintScreenVM.roomDataWrap.roomData!.roomName,
                  currentRoomSize:
                      paintScreenVM.roomDataWrap.roomData!.players.length,
                  roomSize: paintScreenVM.roomDataWrap.roomData!.roomSize,
                  playersList: paintScreenVM.roomDataWrap.roomData!.players,
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildGame(PaintScreenVM paintScreenVM) {
    return StreamBuilder(
      stream: paintScreenVM.showFinalLeaderboardController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == false) {
          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(paintScreenVM),
                Expanded(
                  flex: 3,
                  child: _buildDrawingArea(paintScreenVM),
                ),
                _buildSlider(paintScreenVM),
                Expanded(
                  flex: 2,
                  child: _buildChatArea(paintScreenVM),
                ),
                _buildInputArea(paintScreenVM),
              ],
            ),
          );
        } else {
          print('databystream : ${snapshot.data ?? ' still waiting'}');
          return FinalLeaderBoard(
              playersList: paintScreenVM.roomDataWrap.roomData!.players);
        }
      },
    );
  }

  Widget _buildDrawer(PaintScreenVM paintScreenVM) {
    return paintScreenVM.roomDataWrap.roomData != null
        ? SideDrawer(
            playersList: paintScreenVM.roomDataWrap.roomData!.players,
          )
        : Container();
  }

  Widget _timerFloatingActionButton(PaintScreenVM paintScreenVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: FloatingActionButton(
        onPressed: () {},
        elevation: 7,
        backgroundColor: Colors.white,
        child: Text(
          '${paintScreenVM.timeLeft}',
          style: const TextStyle(color: Colors.black, fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildAppBar(PaintScreenVM paintScreenVM) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () =>
                paintScreenVM.scaffoldKey.currentState!.openDrawer(),
          ),
        ],
      ),
    );
  }

  void _emitPoints(PaintScreenVM paintScreenVM, double? dx, double? dy,
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
    paintScreenVM.sendPoints(point);
  }

  Widget _buildDrawingArea(PaintScreenVM paintScreenVM) {
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (paintScreenVM.canvasWidth != constraints.maxWidth ||
              paintScreenVM.canvasHeight != constraints.maxHeight) {
            Future.delayed(Duration.zero, () => paintScreenVM.resizeDrawing());
          }
          paintScreenVM.canvasWidth = constraints.maxWidth;
          paintScreenVM.canvasHeight = constraints.maxHeight;
          return GestureDetector(
            onPanUpdate: (details) {
              if (paintScreenVM.roomDataWrap.roomData!.turn.nickName ==
                  paintScreenVM.nickName) {
                _emitPoints(
                    paintScreenVM,
                    details.localPosition.dx,
                    details.localPosition.dy,
                    constraints.maxWidth,
                    constraints.maxHeight);
              }
            },
            onPanStart: (details) {
              if (paintScreenVM.roomDataWrap.roomData!.turn.nickName ==
                  paintScreenVM.nickName) {
                _emitPoints(
                    paintScreenVM,
                    details.localPosition.dx,
                    details.localPosition.dy,
                    constraints.maxWidth,
                    constraints.maxHeight);
              }
            },
            onPanEnd: (details) {
              if (paintScreenVM.roomDataWrap.roomData!.turn.nickName ==
                  paintScreenVM.nickName) {
                _emitPoints(paintScreenVM, null, null, constraints.maxWidth,
                    constraints.maxHeight);
              }
            },
            child: RepaintBoundary(
              child: ClipRect(
                clipper: MyClipper(
                    height: constraints.maxHeight, width: constraints.maxWidth),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: MyCustomPainter(
                    paths: paintScreenVM.paths,
                    pathPaints: paintScreenVM.pathPaints,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void selectColor(PaintScreenVM paintScreenVM) {
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text('Choose Color'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: paintScreenVM.selectedColor,
                onColorChanged: ((color) {
                  String colorString = color.toString();
                  String valueString =
                      colorString.split('(0x')[1].split(')')[0];
                  Map map = {
                    'color': valueString,
                    'room_name': paintScreenVM.roomDataWrap.roomData!.roomName
                  };
                  paintScreenVM.socketRepository.socket
                      ?.emit('color_change', map);
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

  Widget _buildSlider(PaintScreenVM paintScreenVM) {
    return Column(
      children: [
        paintScreenVM.roomDataWrap.roomData!.turn.nickName ==
                paintScreenVM.nickName
            ? Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.color_lens,
                      color: paintScreenVM.selectedColor,
                    ),
                    onPressed: () {
                      selectColor(paintScreenVM);
                    },
                  ),
                  Expanded(
                    child: Slider(
                      min: 1.0,
                      max: 10.0,
                      label: 'Strokewidth $paintScreenVM.strokeWidth',
                      value: paintScreenVM.strokeWidth,
                      activeColor: paintScreenVM.selectedColor,
                      onChanged: (double value) {
                        Map map = {
                          'value': value,
                          'room_name':
                              paintScreenVM.roomDataWrap.roomData!.roomName,
                        };
                        paintScreenVM.socketRepository.socket
                            ?.emit('stroke_width', map);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      paintScreenVM.socketRepository.socket?.emit('erase_all',
                          paintScreenVM.roomDataWrap.roomData!.roomName);
                    },
                    icon: const Icon(Icons.clear_all),
                  )
                ],
              )
            : Center(
                child: Text(
                  "${paintScreenVM.roomDataWrap.roomData!.turn.nickName} is drawing..",
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
        paintScreenVM.roomDataWrap.roomData!.turn.nickName !=
                paintScreenVM.nickName
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: paintScreenVM.hiddenTextWidget,
              )
            : Center(
                child: Text(
                  paintScreenVM.roomDataWrap.roomData!.word,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChatMessage(PaintScreenVM paintScreenVM, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paintScreenVM.messages[index]["sender_name"],
            style: const TextStyle(
              color: Colors.pink,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            paintScreenVM.messages[index]["message"],
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(PaintScreenVM paintScreenVM) {
    return ListView.builder(
      controller: paintScreenVM.scrollController,
      shrinkWrap: true,
      itemCount: paintScreenVM.messages.length,
      itemBuilder: (context, index) {
        return _buildChatMessage(paintScreenVM, index);
      },
    );
  }

  Widget _buildInputArea(PaintScreenVM paintScreenVM) {
    return paintScreenVM.roomDataWrap.roomData!.turn.nickName !=
            paintScreenVM.nickName
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: paintScreenVM.alreadyGuessedByMe,
                    controller: paintScreenVM.controller,
                    onSubmitted: ((value) {
                      if (value.trim().isNotEmpty) {
                        Map msgMap = {
                          'sender_name': paintScreenVM.nickName,
                          'message': value.trim(),
                          'word': paintScreenVM.roomDataWrap.roomData!.word,
                          'room_name':
                              paintScreenVM.roomDataWrap.roomData!.roomName,
                          'guessedUserCounter':
                              paintScreenVM.guessedUserCounter,
                          'total_time': 60,
                          'time_taken': 60 - paintScreenVM.timeLeft,
                        };
                        paintScreenVM.socketRepository.socket
                            ?.emit('msg', msgMap);
                        paintScreenVM.controller.clear();
                      }
                    }),
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      String value = paintScreenVM.controller.text;
                      if (value.trim().isNotEmpty) {
                        Map msgMap = {
                          'sender_name': paintScreenVM.nickName,
                          'message': value.trim(),
                          'word': paintScreenVM.roomDataWrap.roomData!.word,
                          'room_name':
                              paintScreenVM.roomDataWrap.roomData!.roomName,
                          'guessedUserCounter':
                              paintScreenVM.guessedUserCounter,
                          'total_time': 60,
                          'time_taken': 60 - paintScreenVM.timeLeft,
                        };
                        paintScreenVM.socketRepository.socket
                            ?.emit('msg', msgMap);
                        paintScreenVM.controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
