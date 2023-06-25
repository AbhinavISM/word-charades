import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  final List players_list;
  const SideDrawer({super.key, required this.players_list});

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
                  players_list[index]['nick_name'],
                  style: const TextStyle(fontSize: 24),
                ),
                trailing: Text(
                  players_list[index]['points'].toString(),
                  style: const TextStyle(fontSize: 24),
                ),
              );
            }),
            itemCount: players_list.length,
          ),
        ),
      ),
    );
  }
}
