import 'dart:math';

import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:example/features/peers/bloc/peers_bloc.dart';
import 'package:example/features/producers/bloc/producers_bloc.dart';
import 'package:example/features/me/bloc/me_bloc.dart';
import 'package:example/features/room/bloc/room_bloc.dart';
import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_string/random_string.dart';

List<BlocProvider> getRoomModules({
  required RouteSettings settings,
}) {
  return [
    BlocProvider<ProducersBloc>(
      lazy: false,
      create: (context) => ProducersBloc(),
    ),
    BlocProvider<PeersBloc>(
      lazy: false,
      create: (context) => PeersBloc(
        mediaDevicesBloc: context.read<MediaDevicesBloc>(),
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
      create: (context) => RoomBloc(settings.arguments as String),
    ),
  ];
}
