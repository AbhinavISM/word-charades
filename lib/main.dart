import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/models/room_data_provider.dart';
import 'package:yayscribbl/presentation/create_room/create_room_screen.dart';
import 'package:yayscribbl/presentation/create_room/create_room_vm.dart';
import 'package:yayscribbl/presentation/game/paint_screen.dart';
import 'package:yayscribbl/presentation/game/paint_screen_vm.dart';
import 'package:yayscribbl/presentation/home/home_screen.dart';
import 'package:yayscribbl/presentation/join_room/join_room_screen.dart';
import 'package:yayscribbl/repository/socket_repository.dart';

import 'presentation/join_room/join_room_vm.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final createRoomVMProvider =
    ChangeNotifierProvider.autoDispose<CreateRoomVM>((ref) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  ref.onDispose(() {
    nameController.dispose();
    roomController.dispose();
  });
  return CreateRoomVM(
      ref.read(roomDataProvider),
      ref.read(socketRepositoryProvider),
      ref.read(navigatorKeyProvider),
      ref.read(scaffoldMessengerKeyProvider));
});

final joinRoomVMprovider = Provider.autoDispose<JoinRoomVM>((ref) {
  return JoinRoomVM(
      ref.read(roomDataProvider),
      ref.read(socketRepositoryProvider),
      ref.read(navigatorKeyProvider),
      ref.read(scaffoldMessengerKeyProvider));
});

final roomDataProvider = Provider<RoomData>((ref) {
  return RoomData();
});

final paintScreenVMprovider =
    ChangeNotifierProvider.autoDispose<PaintScreenVM>((ref) {
  return PaintScreenVM(
      ref.read(roomDataProvider),
      ref.read(socketRepositoryProvider),
      ref.read(scaffoldMessengerKeyProvider));
});

final socketRepositoryProvider = Provider<SocketRepository>((ref) {
  return SocketRepository();
});
final scaffoldMessengerKeyProvider =
    Provider((ref) => GlobalKey<ScaffoldMessengerState>());

final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: ref.watch(scaffoldMessengerKeyProvider),
      navigatorKey: ref.watch(navigatorKeyProvider),
      home: const MyHomePage(),
      routes: {
        '/create_room_screen': (ctx) => const CreateRoomScreen(),
        '/join_room_screen': (ctx) => const JoinRoomScreen(),
        '/paint_screen': (context) => const PaintScreen(),
      },
    );
  }
}
