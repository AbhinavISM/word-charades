import 'package:flutter/material.dart';
import 'package:yayscribbl/widgets/text_input_widget.dart';

class CreateRoomScreen extends StatefulWidget {
  CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _roomController = TextEditingController();

  String? _maxRounds;

  String? _roomSize;

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomController.text.isNotEmpty &&
        _maxRounds != null &&
        _roomSize != null) {
      Navigator.of(context).pushNamed('/paint_screen', arguments: {
        "nick_name": _nameController.text,
        "room_name": _roomController.text,
        "room_size": _roomSize,
        "max_rounds": _maxRounds,
        "screen_from": 'create_room_screen',
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
            "Create Room",
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                focusColor: Colors.amber,
                items: <String>['2', '5', '10', '15']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value.toString(),
                        ),
                      ),
                    )
                    .toList(),
                hint: const Text('select Max Rounds'),
                onChanged: (value) {
                  setState(() {
                    _maxRounds = value;
                  });
                },
              ),
              Text(_maxRounds ?? "please select"),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                focusColor: Colors.amber,
                items: <String>['2', '3', '4', '5', '6', '7', '8']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value.toString(),
                        ),
                      ),
                    )
                    .toList(),
                hint: const Text('select Room Size'),
                onChanged: (value) {
                  setState(() {
                    _roomSize = value;
                  });
                },
              ),
              Text(_roomSize ?? "please select"),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ElevatedButton(
            onPressed: () {
              createRoom();
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
              "Create!",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
