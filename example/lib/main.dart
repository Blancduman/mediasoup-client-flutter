import 'dart:io';
import 'dart:math';

import 'package:example/Presentation/room.dart';
import 'package:example/data/repositories/room_client_repository.dart';
import 'package:example/logic/blocs/consumers/consumers_bloc.dart';
import 'package:example/logic/blocs/me/me_bloc.dart';
import 'package:example/logic/blocs/media_devices/media_devices_bloc.dart';
import 'package:example/logic/blocs/peers/peers_bloc.dart';
import 'package:example/logic/blocs/producers/producers_bloc.dart';
import 'package:example/logic/blocs/room/room_bloc.dart';
import 'package:example/presentation/enter_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_string/random_string.dart';
import 'package:random_words/random_words.dart';

import 'package:flutter/material.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new DevHttpOverrides();
  runApp(BlocProvider<MediaDevicesBloc>(
    create: (context) => MediaDevicesBloc()..add(MediaDeviceLoadDevices()),
    lazy: false,
    child: MyApp(),
  ));
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
                      roomId: uri.queryParameters['roomId'] ??
                          uri.queryParameters['roomid'] ??
                          randomAlpha(8).toLowerCase(),
                      peersBloc: context.read<PeersBloc>(),
                      producersBloc: context.read<ProducersBloc>(),
                      meBloc: context.read<MeBloc>(),
                      roomBloc: context.read<RoomBloc>(),
                      mediaDevicesBloc: context.read<MediaDevicesBloc>(),
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
