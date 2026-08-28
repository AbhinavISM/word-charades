import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  late IO.Socket socket;

  SocketClient() {
    initSocket();
  }

  void initSocket() {
    socket = IO.io(
        'https://cf70-117-250-76-240.ngrok-free.app',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.onDisconnect((data) => print("disconnected"));
    socket.onConnectError((data) => print(data));
    socket.connect();
  }

  // When user manually leaves a game/room (button click)
  // When navigating to another screen in your Flutter app
  // In dispose() method of your widget/controller
  // When user logs out
  void cleanupSocket() {
    print('Cleaning up socket: ${socket.id}');
    socket.disconnect();
    socket.close();
    socket.dispose();
  }
}
