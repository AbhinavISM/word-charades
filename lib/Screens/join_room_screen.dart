import 'package:flutter/material.dart';

import '../widgets/text_input_widget.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _roomController = TextEditingController();

  void joinRoom() {
    if (_nameController.text.isNotEmpty && _roomController.text.isNotEmpty) {
      Navigator.of(context).pushNamed('/paint_screen', arguments: {
        "nick_name": _nameController.text,
        "room_name": _roomController.text,
        "screen_from": 'join_room_screen',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          ElevatedButton(
            onPressed: () {
              joinRoom();
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(
                Size(
                  MediaQuery.of(context).size.width / 3,
                  MediaQuery.of(context).size.height * 0.05,
                ),
              ),
            ),
            child: const Text(
              "Join!",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
