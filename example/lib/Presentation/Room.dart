import 'dart:math' show Random;

import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';
import 'package:example/room_client.dart';
import 'package:flutter/material.dart';
import 'package:random_words/random_words.dart' show nouns;
import 'package:random_string/random_string.dart' show randomAlpha;

class Room extends StatefulWidget {
  static const String RoutePath = '/room';
  final String url;

  const Room({Key key, this.url}) : super(key: key);

  @override
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  RoomClient roomClient;

  List<RTCVideoRenderer> remoteRenderers = [];
  RTCVideoRenderer localRenderer;
  List<Consumer> consumers = [];
  List<Producer> producers = [];

  void addConsumer(Consumer consumer) async {
    consumers.add(consumer);
    if (consumer.kind != 'audio') {
      final renderer = RTCVideoRenderer();
      await renderer.initialize().then((_) {
        renderer.srcObject = consumer.stream;
        remoteRenderers.add(renderer);
      }).then((_) => setState(() {}));
    }
  }

  void onProducer(Producer producer) async {
    producers.add(producer);
    if (producer.kind != 'audio') {
      localRenderer = RTCVideoRenderer();
      await localRenderer.initialize();
      localRenderer.srcObject = producer.stream;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.url != null && widget.url.isNotEmpty) {
      Uri uri = Uri.parse(widget.url);
      roomClient = RoomClient(
        displayName: nouns[Random.secure().nextInt(2500)],
        roomId: uri.queryParameters['roomid'] ?? randomAlpha(8).toLowerCase(),
        peerId: randomAlpha(8),
        url: 'wss://${uri.host}:4443',
        onConsumer: addConsumer,
        onProducer: onProducer,
      );
    } else {
      roomClient = RoomClient(
        displayName: nouns[Random.secure().nextInt(2500)],
        roomId: randomAlpha(8),
        peerId: randomAlpha(8),
        url: 'wss://v3demo.mediasoup.org:4443',
        onConsumer: addConsumer,
        onProducer: onProducer,
      );
    }

    roomClient.join();
  }

  @override
  void dispose() {
    localRenderer?.dispose();
    remoteRenderers.forEach((element) {
      element?.dispose();
    });
    roomClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: roomClient.roomId != null ? Text(roomClient.roomId) : null,
      ),
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            children: remoteRenderers.map((e) {
              return Container(
                height: 200,
                width: 200,
                child: RTCVideoView(e),
              );
            }).toList(),
          ),
          if (localRenderer != null)
            Positioned(
              left: 5,
              bottom: 5,
              child: Container(
                height: 200,
                width: 200,
                child: RTCVideoView(
                  localRenderer,
                  mirror: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
