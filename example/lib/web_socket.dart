import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:protoo_client/protoo_client.dart' as ProtooClient;

class WebSocket {
  final String peerId;
  final String roomId;
  final String url;
  ProtooClient.Peer _protoo;
  Function() onOpen;
  Function() onFail;
  Function() onDisconnected;
  Function() onClose;
  Function(dynamic data) onRequest; // request, accept, reject
  Function(dynamic notification) onNotification;

  ProtooClient.Peer get socket => _protoo;

  WebSocket({this.peerId, this.roomId, this.url}) {
    if (url != null) {
      _protoo = ProtooClient.Peer(
          ProtooClient.WebTransport('$url/?roomId=$roomId&peerId=$peerId'));
    }
    _protoo.on('open', () => this?.onOpen());
    _protoo.on('failed', () => this?.onFail());
    _protoo.on('disconnected', () => this?.onClose());
    _protoo.on('close', () => this?.onClose());
    _protoo.on(
        'request', (request, accept, reject) => this?.onRequest(request));
    _protoo.on('notification',
        (request, accept, reject) => this?.onNotification(request));
  }

  void close() {
    if (!kIsWeb && Platform.isIOS) {
      _protoo.close();
    } else
      _protoo.close();
  }
}
