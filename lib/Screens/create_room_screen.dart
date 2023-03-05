import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/create_room_vm.dart';
import 'package:yayscribbl/main.dart';
// import 'package:provider/provider.dart';
import 'package:yayscribbl/room_data_provider.dart';
import 'package:yayscribbl/socket_repository.dart';
import 'package:yayscribbl/widgets/text_input_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CreateRoomScreen extends ConsumerStatefulWidget {
  CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  late CreateRoomVM createRoomVM;

  void updateRoomUI(Map dataOfRoom) {
    createRoomVM.showProgressBar = false;
    createRoomVM.roomData.updateDataOfRoom(dataOfRoom);
    // print(Provider.of<RoomData>(context).dataOfRoom.toString());
    Navigator.of(context).pushNamed('/paint_screen',
        arguments: createRoomVM.nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    createRoomVM = ref.watch(createRoomVMprovider);
    return Scaffold(
      body: createRoomVM.showProgressBar
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                        items: <String>['2', '5', '10', '15']
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
                          setState(() {
                            createRoomVM.maxRounds = value;
                          });
                        },
                      ),
                      Text(createRoomVM.maxRounds ?? "please select"),
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
                          setState(() {
                            createRoomVM.roomSize = value;
                          });
                        },
                      ),
                      Text(createRoomVM.roomSize ?? "please select"),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: ElevatedButton(
                      onPressed: () {
                        createRoomVM.createRoom(updateRoomUI);
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          Size(
                            MediaQuery.of(context).size.width / 3,
                            MediaQuery.of(context).size.height * 0.075,
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(111, 0, 244, 1)),
                      ),
                      child: const Text(
                        "Create!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
