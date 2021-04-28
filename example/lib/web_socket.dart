import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class Web_Socket {
  final String peerId;
  final String roomId;
  final String url;
  IO.Socket _socket;
  Function() onOpen;
  Function() onFail;
  Function() onDisconnected;
  Function() onClose;
  Function(dynamic data) onRequest; // request, accept, reject
  Function(dynamic notification) onNotification;

  IO.Socket get socket => _socket;

  Web_Socket({this.peerId, this.roomId, this.url}) {
    if (url != null) {
      _socket = IO.io(
          '$url/?roomId=$roomId&peerId=$peerId',
          OptionBuilder()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .disableAutoConnect() // disable auto-connection
              .build(),
      );
    } else {
      _socket = IO.io(
        'https://v3demo.mediasoup.org/?roomId=$roomId',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build(),
      );
    }

    _socket.onConnect((data) => this?.onOpen());
    _socket.onConnectError((data) => this?.onFail());
    _socket.onError((data) => this?.onFail());
    _socket.onDisconnect((data) => this?.onClose());
    _socket.on('request', (data) => this?.onRequest(data));
    _socket.on('notification', (notification) => this?.onNotification(notification));
  }

  void close() {
    if (!kIsWeb && Platform.isIOS) {
      _socket.dispose();
    } else _socket.close();
  }

  void open() {
    _socket.connect();
  }

  Future<dynamic> sendRequestWithResponse(dynamic data) async {
    Completer promise = Completer();
    
    _socket.emitWithAck('request', data, ack: (response) {
      promise.complete(response);
    });

    return promise.future;
  }

  Future<dynamic> sendRequest(dynamic data) {
    _socket.emit('request', data);
  }
}
