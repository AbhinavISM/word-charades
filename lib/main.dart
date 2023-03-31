import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/Screens/create_room_screen.dart';
import 'package:yayscribbl/Screens/home_screen.dart';
import 'package:yayscribbl/Screens/join_room_screen.dart';
import 'package:yayscribbl/Screens/paint_screen.dart';
import 'package:yayscribbl/viewmodels/create_room_vm.dart';
import 'package:yayscribbl/viewmodels/paint_screen_vm.dart';
import 'package:yayscribbl/viewmodels/room_data_provider.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

import 'viewmodels/join_room_vm.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

final createRoomVMProvider =
    ChangeNotifierProvider.autoDispose<CreateRoomVM>((ref) {
  return CreateRoomVM(
      ref.read(roomDataProvider), ref.read(socketRepositoryProvider), ref.watch(navigatorKeyProvider));
});

final joinRoomVMprovider = Provider.autoDispose<JoinRoomVM>((ref) {
  return JoinRoomVM(
      ref.read(roomDataProvider), ref.read(socketRepositoryProvider), ref.watch(navigatorKeyProvider));
});

final roomDataProvider = Provider<RoomData>((ref) {
  return RoomData();
});

final paintScreenVMprovider =
    ChangeNotifierProvider.autoDispose<PaintScreenVM>((ref) {
  return PaintScreenVM(
      ref.read(roomDataProvider), ref.read(socketRepositoryProvider));
});

final socketRepositoryProvider = Provider<SocketRepository>((ref) {
  return SocketRepository();
});

final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref
      ) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // primaryColor: const Color.fromARGB(255, 84, 9, 163),
        primarySwatch: Colors.deepOrange,
      ),
      navigatorKey: ref.watch(navigatorKeyProvider),
      home: const MyHomePage(),
      routes: {
        '/create_room_screen': (ctx) => CreateRoomScreen(),
        '/join_room_screen': (ctx) => JoinRoomScreen(),
        '/paint_screen': (context) => PaintScreen(),
      },
    );
  }
}
