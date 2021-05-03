import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:random_words/random_words.dart';

import 'package:example/room_client.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class EnterPage extends StatefulWidget {
  static const String RoutePath = '/';

  @override
  _EnterPageState createState() => _EnterPageState();
}

class _EnterPageState extends State<EnterPage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool join = false;
  RoomClient roomClient;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      final String text = _textEditingController.text.toLowerCase();
      _textEditingController.value = _textEditingController.value.copyWith(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
        composing: TextRange.empty,
      );
    });

    roomClient = RoomClient(
        roomId: 'asdasdds',
        url: 'wss://v3demo.mediasoup.org:4443',
        displayName: nouns.take(1).first,
        peerId: 'zxcvvczx');
    roomClient.join();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    final stream = await roomClient.createVideoStream();
    _localRenderer.srcObject = stream;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            TextFormField(
              controller: _textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Room url',
              ),
            ),
            SizedBox(
              child: Container(
                width: 120.0,
                height: 90.0,
                child: RTCVideoView(_localRenderer, mirror: true),
                decoration: BoxDecoration(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        EnterPage.RoutePath: (context) => EnterPage(),
      },
    );
  }
}
