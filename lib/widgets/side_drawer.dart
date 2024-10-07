import 'package:flutter/material.dart';
import 'package:yayscribbl/models/player_model.dart';

class SideDrawer extends StatelessWidget {
  final List<PlayerModel> playersList;
  const SideDrawer({super.key, required this.playersList});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: SizedBox(
          height: double.maxFinite,
          child: ListView.builder(
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
        ),
      ),
    );
  }
}
