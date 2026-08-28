import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/main.dart';
import 'package:yayscribbl/models/paint_screen_ui_commands.dart';
import 'package:yayscribbl/presentation/finish_game/final_leader_board.dart';
import 'package:yayscribbl/presentation/game/paint_screen_vm.dart';
import 'package:yayscribbl/presentation/waiting/waiting_screen.dart';
import 'package:yayscribbl/utils/my_clipper.dart';
import 'package:yayscribbl/utils/my_custom_painter.dart';
import 'package:yayscribbl/widgets/side_drawer.dart';

class ImprovedPaintScreen extends ConsumerStatefulWidget {
  const ImprovedPaintScreen({super.key});

  @override
  ConsumerState<ImprovedPaintScreen> createState() =>
      _ImprovedPaintScreenState();
}

class _ImprovedPaintScreenState extends ConsumerState<ImprovedPaintScreen> {
  final msgController = TextEditingController();
  final scrollController = ScrollController();
  late final StreamSubscription<PaintScreenUiCommands>
      paintScreenUiCommandsSubscription;

  @override
  void initState() {
    print('init state ran');
    // ref.read(paintScreenVMprovider).setupVoiceSDKEngine();
    paintScreenUiCommandsSubscription = ref
        .read(paintScreenVMprovider)
        .paintScreenUIEventStream
        .listen(handleUICommands);
    super.initState();
  }

  void handleUICommands(PaintScreenUiCommands event) {
    switch (event) {
      case ClearMsgEvent():
        msgController.clear();
        break;
      case ScrollEvent():
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 40,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    msgController.dispose();
    scrollController.dispose();
    paintScreenUiCommandsSubscription.cancel();
    // paintScreenVM.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paintScreenVM = ref.watch(paintScreenVMprovider);
    print('vmid : ${identityHashCode(paintScreenVM)}');

    return Scaffold(
      drawer: _buildDrawer(paintScreenVM),
      floatingActionButton: _timerFloatingActionButton(paintScreenVM),
      key: paintScreenVM.scaffoldKey,
      body: paintScreenVM.roomDataWrap.roomData!.canJoin != true
          ? _buildGame(paintScreenVM)
          : WaitingScreen(
              roomName: paintScreenVM.roomDataWrap.roomData!.roomName,
              currentRoomSize:
                  paintScreenVM.roomDataWrap.roomData!.players.length,
              roomSize: paintScreenVM.roomDataWrap.roomData!.roomSize,
              playersList: paintScreenVM.roomDataWrap.roomData!.players,
            ),
    );
  }

  Widget _buildGame(PaintScreenVM paintScreenVM) {
    if (paintScreenVM.showFinalLeaderboard) {
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
      return FinalLeaderBoard(
          playersList: paintScreenVM.roomDataWrap.roomData!.players);
    }
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
          '${paintScreenVM.secondsRemaining}',
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
            onPressed: () => paintScreenVM.openDrawer(),
          ),
        ],
      ),
    );
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
              if (paintScreenVM
                      .roomDataWrap
                      .roomData!
                      .players[
                          paintScreenVM.roundDataWrap.roundModel!.turnIndex]
                      .nickName ==
                  paintScreenVM.playerDataWrap.playerModel!.nickName) {
                paintScreenVM.sendPoints(
                    paintScreenVM,
                    details.localPosition.dx,
                    details.localPosition.dy,
                    constraints.maxWidth,
                    constraints.maxHeight);
              }
            },
            onPanStart: (details) {
              if (paintScreenVM
                      .roomDataWrap
                      .roomData!
                      .players[
                          paintScreenVM.roundDataWrap.roundModel!.turnIndex]
                      .nickName ==
                  paintScreenVM.playerDataWrap.playerModel!.nickName) {
                paintScreenVM.sendPoints(
                    paintScreenVM,
                    details.localPosition.dx,
                    details.localPosition.dy,
                    constraints.maxWidth,
                    constraints.maxHeight);
              }
            },
            onPanEnd: (details) {
              if (paintScreenVM
                      .roomDataWrap
                      .roomData!
                      .players[
                          paintScreenVM.roundDataWrap.roundModel!.turnIndex]
                      .nickName ==
                  paintScreenVM.playerDataWrap.playerModel!.nickName) {
                paintScreenVM.sendPoints(paintScreenVM, null, null,
                    constraints.maxWidth, constraints.maxHeight);
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
                onColorChanged: paintScreenVM.changeColor,
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
        paintScreenVM
                    .roomDataWrap
                    .roomData!
                    .players[paintScreenVM.roundDataWrap.roundModel!.turnIndex]
                    .nickName ==
                paintScreenVM.playerDataWrap.playerModel!.nickName
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
                      onChanged: paintScreenVM.changeStrokeWidth,
                    ),
                  ),
                  IconButton(
                    onPressed: paintScreenVM.eraseAll,
                    icon: const Icon(Icons.clear_all),
                  )
                ],
              )
            : Center(
                child: Text(
                  "${paintScreenVM.roomDataWrap.roomData!.players[paintScreenVM.roundDataWrap.roundModel!.turnIndex].nickName} is drawing..",
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
        paintScreenVM
                    .roomDataWrap
                    .roomData!
                    .players[paintScreenVM.roundDataWrap.roundModel!.turnIndex]
                    .nickName !=
                paintScreenVM.playerDataWrap.playerModel!.nickName
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
            paintScreenVM.messages[index]["senderName"],
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
      controller: scrollController,
      shrinkWrap: true,
      itemCount: paintScreenVM.messages.length,
      itemBuilder: (context, index) {
        return _buildChatMessage(paintScreenVM, index);
      },
    );
  }

  Widget _buildInputArea(PaintScreenVM paintScreenVM) {
    return paintScreenVM.playerDataWrap.playerModel!.canMsg
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: paintScreenVM.playerDataWrap.playerModel!.guessed,
                    controller: msgController,
                    onSubmitted: paintScreenVM.sendMsg,
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
                      paintScreenVM.sendMsg(msgController.text);
                    },
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
