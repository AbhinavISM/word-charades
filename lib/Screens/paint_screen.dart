import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/Screens/final_leader_board.dart';
import 'package:yayscribbl/Screens/waiting_screen.dart';
import 'package:yayscribbl/main.dart';
import 'package:yayscribbl/viewmodels/paint_screen_vm.dart';

import '../models/my_custom_painter.dart';
import '../widgets/my_clipper.dart';
import '../widgets/side_drawer.dart';

class PaintScreen extends ConsumerStatefulWidget {
  const PaintScreen({super.key});

  @override
  ConsumerState<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends ConsumerState<PaintScreen> {
  @override
  void initState() {
    // firstBuild = true;
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
    paintScreenVM.roomData.updateDataOfRoom(null);
    // paintScreenVM.leave();
    ref.read(paintScreenVMprovider).dispose();
    super.dispose();
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
                    'room_name': paintScreenVM.roomData.dataOfRoom?['room_name']
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

  void onFirstBuild(PaintScreenVM paintScreenVM) {
    paintScreenVM
        .renderHiddenTextWidget(paintScreenVM.roomData.dataOfRoom?['word']);
    if (paintScreenVM.roomData.dataOfRoom?['isJoin'] != true) {
      paintScreenVM.startTimer();
    }
    paintScreenVM.firstBuild = false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
      drawer: paintScreenVM.roomData.dataOfRoom != null
          ? SideDrawer(
              players_list: paintScreenVM.roomData.dataOfRoom?['players'],
            )
          : Container(),
      key: paintScreenVM.scaffoldKey,
      body: paintScreenVM.roomData.dataOfRoom != null
          ? paintScreenVM.roomData.dataOfRoom!['isJoin'] != true
              ? StreamBuilder(
                  stream: paintScreenVM.showFinalLeaderboardController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == false) {
                      print(
                          'databystream : ${snapshot.data ?? ' still waiting'}');
                      return Stack(
                        children: [
                          // Text(paintScreenVM.showFinalLeaderboard.toString()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: width,
                                height: height * 0.5,
                                child: GestureDetector(
                                  onPanUpdate: paintScreenVM
                                                  .roomData.dataOfRoom?['turn']
                                              ['nick_name'] ==
                                          paintScreenVM.nickName
                                      ? (details) {
                                          print(details.localPosition.dx);
                                          paintScreenVM.socketRepository.socket
                                              ?.emit('paint', {
                                            'details': {
                                              'dx': details.localPosition.dx,
                                              'dy': details.localPosition.dy,
                                            },
                                            'room_name': paintScreenVM.roomData
                                                .dataOfRoom?['room_name'],
                                          });
                                        }
                                      : (details) {},
                                  onPanStart: paintScreenVM
                                                  .roomData.dataOfRoom?['turn']
                                              ['nick_name'] ==
                                          paintScreenVM.nickName
                                      ? (details) {
                                          print(details.localPosition.dx);
                                          paintScreenVM.socketRepository.socket
                                              ?.emit('paint', {
                                            'details': {
                                              'dx': details.localPosition.dx,
                                              'dy': details.localPosition.dy,
                                            },
                                            'room_name': paintScreenVM.roomData
                                                .dataOfRoom?['room_name'],
                                          });
                                        }
                                      : (details) {},
                                  onPanEnd: paintScreenVM
                                                  .roomData.dataOfRoom?['turn']
                                              ['nick_name'] ==
                                          paintScreenVM.nickName
                                      ? (details) {
                                          paintScreenVM.socketRepository.socket
                                              ?.emit('paint', {
                                            'details': null,
                                            'room_name': paintScreenVM.roomData
                                                .dataOfRoom?['room_name'],
                                          });
                                        }
                                      : (details) {},
                                  child: SizedBox.expand(
                                    child: RepaintBoundary(
                                      child: ClipRect(
                                        clipper: MyClipper(
                                            height: height * 0.55,
                                            width: width),
                                        child: CustomPaint(
                                          size: Size.infinite,
                                          painter: MyCustomPainter(
                                              pointsList: paintScreenVM.points),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              paintScreenVM.roomData.dataOfRoom?['turn']
                                          ['nick_name'] ==
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
                                            label:
                                                'Strokewidth $paintScreenVM.strokeWidth',
                                            value: paintScreenVM.strokeWidth,
                                            activeColor:
                                                paintScreenVM.selectedColor,
                                            onChanged: (double value) {
                                              Map map = {
                                                'value': value,
                                                'room_name': paintScreenVM
                                                    .roomData
                                                    .dataOfRoom?['room_name'],
                                              };
                                              paintScreenVM
                                                  .socketRepository.socket
                                                  ?.emit('stroke_width', map);
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            paintScreenVM
                                                .socketRepository.socket
                                                ?.emit(
                                                    'erase_all',
                                                    paintScreenVM.roomData
                                                            .dataOfRoom?[
                                                        'room_name']);
                                          },
                                          icon: const Icon(Icons.clear_all),
                                        )
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        "${paintScreenVM.roomData.dataOfRoom?["turn"]["nick_name"]} is drawing..",
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              paintScreenVM.roomData.dataOfRoom?['turn']
                                          ['nick_name'] !=
                                      paintScreenVM.nickName
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: paintScreenVM.hiddenTextWidget,
                                    )
                                  : Center(
                                      child: Text(
                                        paintScreenVM
                                            .roomData.dataOfRoom?['word'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      // ignore: prefer_const_constructors
                                      title: Text(
                                        paintScreenVM.messages[index]
                                            ["sender_name"],
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        paintScreenVM.messages[index]
                                            ["message"],
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    );
                                  },
                                  controller: paintScreenVM.scrollController,
                                  shrinkWrap: true,
                                  itemCount: paintScreenVM.messages.length,
                                ),
                              ),
                            ],
                          ),
                          paintScreenVM.roomData.dataOfRoom?['turn']
                                      ['nick_name'] !=
                                  paintScreenVM.nickName
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: TextField(
                                      readOnly:
                                          paintScreenVM.alreadyGuessedByMe,
                                      controller: paintScreenVM.controller,
                                      onSubmitted: ((value) {
                                        if (value.trim().isNotEmpty) {
                                          Map msgMap = {
                                            'sender_name':
                                                paintScreenVM.nickName,
                                            'message': value.trim(),
                                            'word': paintScreenVM
                                                .roomData.dataOfRoom?["word"],
                                            'room_name': paintScreenVM.roomData
                                                .dataOfRoom?["room_name"],
                                            'guessedUserCounter': paintScreenVM
                                                .guessedUserCounter,
                                            'total_time': 60,
                                            'time_taken':
                                                60 - paintScreenVM.timeLeft,
                                          };
                                          paintScreenVM.socketRepository.socket
                                              ?.emit('msg', msgMap);
                                          paintScreenVM.controller.clear();
                                        }
                                      }),
                                      autocorrect: false,
                                      decoration: InputDecoration(
                                        labelText: "guess the word!",
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                            255, 244, 244, 244),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                              icon: const Icon(Icons.menu),
                              onPressed: () => paintScreenVM
                                  .scaffoldKey.currentState!
                                  .openDrawer(),
                            ),
                          ),
                        ],
                      );
                    } else {
                      print(
                          'databystream : ${snapshot.data ?? ' still waiting'}');

                      return FinalLeaderBoard(
                          players_list:
                              paintScreenVM.roomData.dataOfRoom?['players']);
                    }
                  },
                )
              : WaitingScreen(
                  room_name: paintScreenVM.roomData.dataOfRoom?['room_name'],
                  current_room_size:
                      paintScreenVM.roomData.dataOfRoom?['players'].length,
                  room_size: paintScreenVM.roomData.dataOfRoom?['room_size'],
                  players_list: paintScreenVM.roomData.dataOfRoom?['players'],
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
            '${paintScreenVM.timeLeft}',
            style: const TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
