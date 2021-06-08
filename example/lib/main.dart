import 'dart:math';

import 'package:example/Presentation/room.dart';
import 'package:example/data/repositories/room_client_repository.dart';
import 'package:example/logic/blocs/consumers/consumers_bloc.dart';
import 'package:example/logic/blocs/me/me_bloc.dart';
import 'package:example/logic/blocs/peers/peers_bloc.dart';
import 'package:example/logic/blocs/producers/producers_bloc.dart';
import 'package:example/logic/blocs/room/room_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_string/random_string.dart';
import 'package:random_words/random_words.dart';

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

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      final String text = _textEditingController.text.toLowerCase();
      setState(() {
        _textEditingController.value = _textEditingController.value.copyWith(
          text: text,
          // selection: TextSelection(
          //   baseOffset: text.length,
          //   extentOffset: text.length,
          // ),
          // composing: TextRange.empty,
        );
      });
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
            TextField(
              autofocus: false,
              controller: _textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Room url',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/room',
                    arguments: _textEditingController.value.text.toLowerCase());
              },
              child: Text('Join'),
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
      // ignore: missing_return
      onGenerateRoute: (settings) {
        if (settings.name == EnterPage.RoutePath) {
          return MaterialPageRoute(
            builder: (context) => EnterPage(),
          );
        }
        if (settings.name == '/room') {
          return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider<ProducersBloc>(
                    lazy: false,
                    create: (context) => ProducersBloc(),
                  ),
                  BlocProvider<ConsumersBloc>(
                    lazy: false,
                    create: (context) => ConsumersBloc(),
                  ),
                  BlocProvider<PeersBloc>(
                    lazy: false,
                    create: (context) => PeersBloc(
                      consumersBloc: context.read<ConsumersBloc>(),
                    ),
                  ),
                  BlocProvider<MeBloc>(
                    lazy: false,
                    create: (context) => MeBloc(
                        displayName: nouns[Random.secure().nextInt(2500)],
                        id: randomAlpha(8)),
                  ),
                  BlocProvider<RoomBloc>(
                    lazy: false,
                    create: (context) => RoomBloc(settings.arguments),
                  ),
                ],
                child: RepositoryProvider(
                  lazy: false,
                  create: (context) {
                    final meState = context.read<MeBloc>().state;
                    String displayName = meState.displayName;
                    String id = meState.id;
                    final roomState = context.read<RoomBloc>().state;
                    String url = roomState.url;

                    Uri uri = Uri.parse(url);

                    return RoomClientRepository(
                      peerId: id,
                      consumersBloc: context.read<ConsumersBloc>(),
                      displayName: displayName,
                      url: url != null
                          ? 'wss://${uri.host}:4443'
                          : 'wss://v3demo.mediasoup.org:4443',
                      roomId: uri.queryParameters['roomId'] ?? randomAlpha(8).toLowerCase(),
                      peersBloc: context.read<PeersBloc>(),
                      producersBloc: context.read<ProducersBloc>(),
                      meBloc: context.read<MeBloc>(),
                      roomBloc: context.read<RoomBloc>(),
                    )..join();
                  },
                  child: Room(),
                )),
          );
        }
      },
    );
  }
}
