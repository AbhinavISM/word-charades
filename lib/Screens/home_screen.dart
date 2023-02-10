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
      body: Container(
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
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/create_room_screen'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(111, 0, 244, 1)),
                      minimumSize: MaterialStateProperty.all(
                        Size(
                          MediaQuery.of(context).size.width / 3,
                          MediaQuery.of(context).size.height * 0.075,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Create game",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/join_room_screen'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(111, 0, 244, 1)),
                      minimumSize: MaterialStateProperty.all(
                        Size(
                          MediaQuery.of(context).size.width / 3,
                          MediaQuery.of(context).size.height * 0.075,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Join game",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
