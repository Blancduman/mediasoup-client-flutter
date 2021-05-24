import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';
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
  List<Consumer> consumers;
  List<RTCVideoRenderer> _localRenderers;
  bool join = false;
  RoomClient roomClient;

  @override
  void initState() {
    super.initState();

    consumers = [];
    _localRenderers = [];

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
        roomId: 'umohtbqv',
        url: 'wss://v3demo.mediasoup.org:4443',
        displayName: nouns.take(1).first,
        peerId: 'zxcvvczx',
        onConsumer: addConsumer);
    roomClient.join();
  }

  Future<void> addConsumer(Consumer consumer) async {
    if (consumer.kind == 'audio' ) {
      return;
    }
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    final mediaStream = await createLocalMediaStream(consumer.id);
    await mediaStream.addTrack(consumer.track);
    renderer.srcObject = mediaStream;

    consumers.add(consumer);
    setState(() {
      _localRenderers.add(renderer);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mediasoup-client-flutter'),
      ),
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
            ..._localRenderers.map((renderer) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  return Center(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      width: 480,
                      height: 240,
                      decoration: BoxDecoration(color: Colors.black54),
                      child: RTCVideoView(renderer, mirror: true),
                    ),
                  );
                },
              );
            }),
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
