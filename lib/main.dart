import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yayscribbl/models/player_data_provider.dart';
import 'package:yayscribbl/models/room_data_provider.dart';
import 'package:yayscribbl/models/round_data_provider.dart';
import 'package:yayscribbl/presentation/create_room/create_room_screen.dart';
import 'package:yayscribbl/presentation/create_room/create_room_vm.dart';
import 'package:yayscribbl/presentation/game/improved_paint_screen.dart';
import 'package:yayscribbl/presentation/game/paint_screen_vm.dart';
import 'package:yayscribbl/presentation/home/home_screen.dart';
import 'package:yayscribbl/presentation/join_room/join_room_screen.dart';
import 'package:yayscribbl/repository/socket_client.dart';
import 'package:yayscribbl/repository/socket_repository.dart';
import 'package:yayscribbl/utils/point_throttler.dart';

import 'presentation/join_room/join_room_vm.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final createRoomVMProvider =
    ChangeNotifierProvider.autoDispose<CreateRoomVM>((ref) {
  return CreateRoomVM(
      ref.read(roomDataProvider),
      ref.read(socketRepositoryProvider),
      ref.read(navigatorKeyProvider),
      ref.read(scaffoldMessengerKeyProvider),
      ref.read(playerDataProvider),
      ref.read(roundDataProvider));
});

final joinRoomVMprovider = Provider.autoDispose<JoinRoomVM>((ref) {
  return JoinRoomVM(
      ref.read(roomDataProvider),
      ref.read(socketRepositoryProvider),
      ref.read(navigatorKeyProvider),
      ref.read(scaffoldMessengerKeyProvider),
      ref.read(playerDataProvider),
      ref.read(roundDataProvider));
});

final roomDataProvider = Provider<RoomDataWrap>((ref) {
  return RoomDataWrap();
});

final playerDataProvider = Provider<PlayerDataWrap>((ref) {
  return PlayerDataWrap();
});

final roundDataProvider = Provider<RoundDataWrap>((ref) {
  return RoundDataWrap();
});

final pointThrottlerProvider = Provider<PointThrottler>((ref) {
  return PointThrottler();
});

final paintScreenVMprovider =
    ChangeNotifierProvider.autoDispose<PaintScreenVM>((ref) {
  return PaintScreenVM(
      ref.read(roomDataProvider),
      ref.read(socketRepositoryProvider),
      ref.read(scaffoldMessengerKeyProvider),
      ref.read(playerDataProvider),
      ref.read(roundDataProvider),
      ref.read(pointThrottlerProvider));
});

final socketClientProvider = Provider<SocketClient>((ref) {
  return SocketClient();
});

final socketRepositoryProvider = Provider<SocketRepository>((ref) {
  return SocketRepository(socket: ref.read(socketClientProvider).socket);
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
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: ref.watch(scaffoldMessengerKeyProvider),
      navigatorKey: ref.watch(navigatorKeyProvider),
      home: const MyHomePage(),
      routes: {
        '/create_room_screen': (ctx) => const CreateRoomScreen(),
        '/join_room_screen': (ctx) => const JoinRoomScreen(),
        '/paint_screen': (context) => const ImprovedPaintScreen(),
      },
    );
  }
}

//TODO : combine the round start event with the first sync data event of the round.
//TODO : Separate waiting screen
//TODO : send the selected word for the round to only one client!
//TODO : Move all socket emit tasks from paintScreenVM to repository layer
//TODO : scroll the message by correct amount by calculating the correct number of pixels to scroll
//TODO : add a isturn parameter to playerModel which is managed by the server, that makes a lot of code shorter.
//TODO : Keep provider.roomdatawrap.roomdata and all once in each screen instead of writing it over and over again
//TODO : stop using navigator keys and scaffold messenger keys, instead pass stream events to the UI
//TODO : make sure viewmodels are pure dart code
//TODO : make sure you handle when someone disconnects and maybe tries to join again? (maybe only give the join again option to people already having an account)
//TODO : make sure socket connections are properly disposed of in socket_client or repository. Also check if establishing a socket connection is async or sync.
//TODO : currently the whole VM including its local state like UI event streams is rebuilt whenever something in the room/player/roundDataProvider calls notifyListener. i think this can be fixed by seperating the local state object for each VM.
//TODO : send only relevant data instead of all models on each event from the server.
//TODO : configure riverpod to rebuild widgets only when the specific properties affecting it have changed. (to achieve this, maybe we have to let the screen directly access room/player/roundDataProvider.
