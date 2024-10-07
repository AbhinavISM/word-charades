import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;
  //just a private constructor, no need to name it internal
  SocketClient._internal() {
    socket = IO.io(
        'https://0d13-2401-4900-73e2-2ba8-f045-fe79-5c38-28e0.ngrok-free.app',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
