import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/main.dart';

import '../../widgets/text_input_widget.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final playerNameController = TextEditingController();
  final roomNameController = TextEditingController();

  @override
  void dispose() {
    playerNameController.dispose();
    roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joinRoomVM = ref.watch(joinRoomVMprovider);
    if (joinRoomVM.showProgressBar) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'wOrD cHaRaDeS!',
            style: TextStyle(
              letterSpacing: 3,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue[700],
          elevation: 4,
        ),
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
                  label: "Enter your name",
                  controller: playerNameController,
                  onChangedCallback: (val) => joinRoomVM.playerNameText = val,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInputWidget(
                  label: "Enter room name",
                  controller: roomNameController,
                  onChangedCallback: (val) => joinRoomVM.roomNameText = val,
                ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
    }
  }
}
