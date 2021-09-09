import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<BlocProvider> getAppModules() {
  return [
    BlocProvider<MediaDevicesBloc>(
      create: (context) => MediaDevicesBloc()..add(MediaDeviceLoadDevices()),
      lazy: false,
    ),
  ];
}
