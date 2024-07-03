import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/main.dart';

import '../widgets/text_input_widget.dart';

class JoinRoomScreen extends ConsumerWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinRoomVM = ref.watch(joinRoomVMprovider);
    return StreamBuilder(
      stream: joinRoomVM.showProgressBarController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == false) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[300]!, Colors.purple[300]!],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Join Room",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInputWidget(
                        controller: joinRoomVM.nameController,
                        texthint: "Enter your name"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInputWidget(
                        controller: joinRoomVM.roomController,
                        texthint: "Enter room name"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ElevatedButton(
                    onPressed: () => joinRoomVM.joinRoom(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[700],
                      minimumSize: Size(
                        MediaQuery.of(context).size.width / 3,
                        MediaQuery.of(context).size.height * 0.075,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Join!'),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.data == true) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
