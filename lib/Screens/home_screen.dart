import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   title: const Center(
      //     child: Text(
      //       "SCRIBBL.iot",
      //       style: TextStyle(letterSpacing: 2),
      //     ),
      //   ),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Create a room to play!",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/create_room_screen'),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width / 3,
                      MediaQuery.of(context).size.height * 0.075,
                    ),
                  ),
                ),
                child: const Text(
                  "Create room",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/join_room_screen'),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width / 3,
                      MediaQuery.of(context).size.height * 0.075,
                    ),
                  ),
                ),
                child: const Text(
                  "Join room",
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
