import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/main.dart';
import 'package:yayscribbl/widgets/text_input_widget.dart';

class CreateRoomScreen extends ConsumerWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createRoomVM = ref.watch(createRoomVMProvider);
    return StreamBuilder<bool>(
      stream: createRoomVM.showProgressBarController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == false) {
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
                    "Create Room",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInputWidget(
                        controller: createRoomVM.nameController,
                        texthint: "Enter your name"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInputWidget(
                        controller: createRoomVM.roomController,
                        texthint: "Enter room name"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        focusColor: Colors.amber,
                        items: <String>['1', '2', '5', '10', '15']
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value.toString(),
                                ),
                              ),
                            )
                            .toList(),
                        hint: const Text('select Max Rounds'),
                        onChanged: (value) {
                          createRoomVM.setMaxRounds = value;
                        },
                      ),
                      Text(createRoomVM.getMaxRounds ?? "please select"),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        focusColor: Colors.amber,
                        items: <String>['2', '3', '4', '5', '6', '7', '8']
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value.toString(),
                                ),
                              ),
                            )
                            .toList(),
                        hint: const Text('select Room Size'),
                        onChanged: (value) {
                          createRoomVM.setRoomSize = value;
                        },
                      ),
                      Text(createRoomVM.getRoomSize ?? "please select"),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ElevatedButton(
                    onPressed: () => createRoomVM.createRoom(),
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
                    child: const Text('Create!'),
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
