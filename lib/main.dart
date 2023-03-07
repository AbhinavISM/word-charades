import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:provider/provider.dart';
import 'package:yayscribbl/Screens/create_room_screen.dart';
import 'package:yayscribbl/Screens/home_screen.dart';
import 'package:yayscribbl/Screens/join_room_screen.dart';
import 'package:yayscribbl/Screens/paint_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yayscribbl/create_room_vm.dart';
import 'package:yayscribbl/paint_screen_vm.dart';
import 'package:yayscribbl/room_data_provider.dart';
import 'package:yayscribbl/socket_client.dart';
import 'package:yayscribbl/socket_repository.dart';

import 'join_room_vm.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

final roomDataProvider = ChangeNotifierProvider<RoomData>((ref) {
  return RoomData();
});

final paintScreenVMprovider = ChangeNotifierProvider<PaintScreenVM>((ref) {
  return PaintScreenVM(
      ref.watch(roomDataProvider), ref.watch(socketRepositoryProvider));
});

final socketRepositoryProvider = Provider<SocketRepository>((ref) {
  return SocketRepository();
});

final createRoomVMprovider = Provider<CreateRoomVM>((ref) {
  return CreateRoomVM(
      ref.watch(roomDataProvider), ref.watch(socketRepositoryProvider));
});

final joinRoomVMprovider = Provider<JoinRoomVM>((ref) {
  return JoinRoomVM(
      ref.watch(roomDataProvider), ref.watch(socketRepositoryProvider));
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // primaryColor: const Color.fromARGB(255, 84, 9, 163),
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(),
      routes: {
        '/create_room_screen': (ctx) => CreateRoomScreen(),
        '/join_room_screen': (ctx) => JoinRoomScreen(),
        '/paint_screen': (context) => PaintScreen(),
      },
    );
  }
}
