import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yayscribbl/socket_repository.dart';

import '../vm_ps.dart';
import '../widgets/text_input_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _roomController = TextEditingController();

  late IO.Socket socket;
  bool showProgressBar = false;
  late RoomData roomData;
  late SocketRepository socketRepository;

  void joinRoom() {
    if (_nameController.text.isNotEmpty && _roomController.text.isNotEmpty) {
      setState(() {
        showProgressBar = true;
      });
      socketRepository.joinGame({
        "nick_name": _nameController.text,
        "room_name": _roomController.text,
        "screen_from": 'join_room_screen',
      });
      socketRepository.updateRoomListener(updateRoomUI);
    }
  }

  void updateRoomUI(Map dataOfRoom) {
    showProgressBar = false;
    roomData.updateDataOfRoom(dataOfRoom);
    // print(Provider.of<RoomData>(context).dataOfRoom.toString());
    Navigator.of(context)
        .pushNamed('/paint_screen', arguments: _nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    roomData = Provider.of<RoomData>(context);
    socketRepository = Provider.of<SocketRepository>(context);
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
                  controller: _nameController, texthint: "Enter your name"),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextInputWidget(
                  controller: _roomController, texthint: "Enter room name"),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: ElevatedButton(
                onPressed: () {
                  joinRoom();
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
  }
}
