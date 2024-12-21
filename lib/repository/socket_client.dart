import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;
  //just a private constructor, no need to name it internal
  SocketClient._internal() {
    socket = IO.io(
        'https://ddcf-2401-4900-710c-ea48-3dac-bb49-5bea-5f02.ngrok-free.app',
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
