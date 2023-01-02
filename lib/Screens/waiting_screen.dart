import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaitingScreen extends StatelessWidget {
  final current_room_size;
  final room_size;
  final room_name;
  final players_list;

  const WaitingScreen(
      {super.key,
      required this.current_room_size,
      required this.room_size,
      required this.room_name,
      required this.players_list});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'waiting for ${room_size - current_room_size} players to join',
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
                  ClipboardData(text: room_name),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Copied!')));
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
                  players_list[index]['nick_name'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            }),
            itemCount: current_room_size,
          ),
        ],
      ),
    );
  }
}
