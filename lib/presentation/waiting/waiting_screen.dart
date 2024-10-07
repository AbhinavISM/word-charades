import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yayscribbl/models/player_model.dart';

class WaitingScreen extends StatelessWidget {
  final int currentRoomSize;
  final int roomSize;
  final String roomName;
  final List<PlayerModel> playersList;

  const WaitingScreen(
      {super.key,
      required this.currentRoomSize,
      required this.roomSize,
      required this.roomName,
      required this.playersList});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'waiting for ${roomSize - currentRoomSize} players to join',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              readOnly: true,
              onTap: (() {
                Clipboard.setData(
                  ClipboardData(text: roomName),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Copied!')));
              }),
              decoration: InputDecoration(
                hintText: 'tap to copy room name',
                filled: true,
                fillColor: const Color.fromARGB(255, 244, 244, 244),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          const Text(
            'Joined Players: ',
            style: TextStyle(fontSize: 16),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: ((context, index) {
              return ListTile(
                leading: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                title: Text(
                  playersList[index].nickName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            }),
            itemCount: currentRoomSize,
          ),
        ],
      ),
    );
  }
}
