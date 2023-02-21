import 'package:flutter/material.dart';
import 'package:yayscribbl/Screens/home_screen.dart';

class FinalLeaderBoard extends StatelessWidget {
  final List players_list;
  const FinalLeaderBoard({super.key, required this.players_list});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(
                    players_list[index]['nick_name'],
                    style: TextStyle(fontSize: 24),
                  ),
                  trailing: Text(
                    players_list[index]['points'].toString(),
                    style: TextStyle(fontSize: 24),
                  ),
                );
              }),
              itemCount: players_list.length,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return MyHomePage();
                  }), (route) => false);
                },
                child: Text('New Game')),
          ],
        ),
      ),
    );
  }
}
