import 'package:example/data/repositories/room_client_repository.dart';
import 'package:example/logic/blocs/media_devices/media_devices_bloc.dart';
import 'package:example/logic/blocs/room/room_bloc.dart';
import 'package:example/presentation/components/me/renderMe.dart';
import 'package:example/presentation/components/others/renderOthers.dart';
import 'package:example/presentation/voice_audio_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Room extends StatelessWidget {
  const Room({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            String url = context.select((RoomBloc bloc) => bloc.state.url);
            return Text(Uri.parse(url).queryParameters['roomId'] ??
                Uri.parse(url).queryParameters['roomid']);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              String url = context.read<RoomBloc>().state.url;
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Room link copied to clipboard'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(Icons.copy),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MediaDevicesBloc>(),
                    child: AudioVideoSettings(),
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.read<RoomClientRepository>().close();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RenderOther(),
          RenderMe(),
        ],
      ),
    );
  }
}
