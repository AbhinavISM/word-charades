import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yayscribbl/room_data_provider.dart';
import 'package:yayscribbl/socket_repository.dart';
import 'package:yayscribbl/widgets/text_input_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

  late IO.Socket socket;

  bool showProgressBar = false;

  late RoomData roomData;

  late SocketRepository socketRepository;

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomController.text.isNotEmpty &&
        _maxRounds != null &&
        _roomSize != null) {
      setState(() {
        showProgressBar = true;
      });
      print('already connected');
      socketRepository.createGame({
        "nick_name": _nameController.text,
        "room_name": _roomController.text,
        "room_size": _roomSize,
        "max_rounds": _maxRounds,
        "screen_from": 'create_room_screen',
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
      body: showProgressBar
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
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
                        controller: _nameController,
                        texthint: "Enter your name"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInputWidget(
                        controller: _roomController,
                        texthint: "Enter room name"),
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
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: ElevatedButton(
                      onPressed: () {
                        createRoom();
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          Size(
                            MediaQuery.of(context).size.width / 3,
                            MediaQuery.of(context).size.height * 0.075,
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(111, 0, 244, 1)),
                      ),
                      child: const Text(
                        "Create!",
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
