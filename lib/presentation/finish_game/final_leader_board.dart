import 'package:flutter/material.dart';
import 'package:yayscribbl/models/player_model.dart';
import 'package:yayscribbl/presentation/home/home_screen.dart';

class FinalLeaderBoard extends StatelessWidget {
  final List<PlayerModel> playersList;
  const FinalLeaderBoard({super.key, required this.playersList});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(
                    playersList[index].nickName,
                    style: const TextStyle(fontSize: 24),
                  ),
                  trailing: Text(
                    playersList[index].points.toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              }),
              itemCount: playersList.length,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const MyHomePage();
                  }), (route) => false);
                },
                child: const Text('New Game')),
          ],
        ),
      ),
    );
  }
}
