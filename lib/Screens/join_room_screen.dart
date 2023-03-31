import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/viewmodels/join_room_vm.dart';
import 'package:yayscribbl/main.dart';

import '../widgets/text_input_widget.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  late JoinRoomVM joinRoomVM;

  void updateRoomUI(Map dataOfRoom) {
    // joinRoomVM.showProgressBar = false;
    joinRoomVM.showProgressBarController.sink.add(false);
    joinRoomVM.roomData.updateDataOfRoom(dataOfRoom);
    // print(Provider.of<RoomData>(context).dataOfRoom.toString());
    Navigator.of(context)
        .pushNamed('/paint_screen', arguments: joinRoomVM.nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    joinRoomVM = ref.watch(joinRoomVMprovider);
    return StreamBuilder(
      stream: joinRoomVM.showProgressBarController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == false) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(41, 30, 83, 1),
                      Color.fromRGBO(143, 34, 210, 1)
                    ]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Join Room",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInputWidget(
                        controller: joinRoomVM.nameController,
                        texthint: "Enter your name"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInputWidget(
                        controller: joinRoomVM.roomController,
                        texthint: "Enter room name"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: ElevatedButton(
                      onPressed: () {
                        joinRoomVM.joinRoom(updateRoomUI);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(111, 0, 244, 1)),
                        minimumSize: MaterialStateProperty.all(
                          Size(
                            MediaQuery.of(context).size.width / 3,
                            MediaQuery.of(context).size.height * 0.075,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Join!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.data == true) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
