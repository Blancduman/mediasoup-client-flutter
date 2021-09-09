import 'dart:io';

import 'package:example/constants.dart';
import 'package:example/screens/room/room.dart';
import 'package:example/screens/room/room_modules.dart';
import 'package:example/screens/welcome/welcome.dart';
import 'package:example/features/signaling/room_client_repository.dart';
import 'package:example/features/me/bloc/me_bloc.dart';
import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:example/features/peers/bloc/peers_bloc.dart';
import 'package:example/features/producers/bloc/producers_bloc.dart';
import 'package:example/features/room/bloc/room_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_string/random_string.dart';

import 'package:flutter/material.dart';

import 'app_modules/app_modules.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new DevHttpOverrides();
  runApp(
    MultiBlocProvider(
      providers: getAppModules(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: Constants.theme,
      // ignore: missing_return
      onGenerateRoute: (settings) {
        if (settings.name == Welcome.RoutePath) {
          return MaterialPageRoute(
            builder: (context) => Welcome(),
          );
        }
        if (settings.name == Room.RoutePath) {
          return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                providers: getRoomModules(settings: settings),
                child: RepositoryProvider(
                  lazy: false,
                  create: (context) {
                    final meState = context.read<MeBloc>().state;
                    String displayName = meState.displayName;
                    String id = meState.id;
                    final roomState = context.read<RoomBloc>().state;
                    String url = roomState.url;

                    Uri? uri = Uri.parse(url);

                    return RoomClientRepository(
                      peerId: id,
                      displayName: displayName,
                      url: url.isEmpty
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
