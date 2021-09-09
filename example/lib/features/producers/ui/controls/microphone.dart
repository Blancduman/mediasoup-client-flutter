import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:example/features/signaling/room_client_repository.dart';
import 'package:example/features/producers/bloc/producers_bloc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

class Microphone extends StatelessWidget {
  const Microphone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Producer? microphone =
        context.select((ProducersBloc bloc) => bloc.state.mic);
    final int audioInputDevicesLength = context
        .select((MediaDevicesBloc bloc) => bloc.state.audioInputs.length);
    if (audioInputDevicesLength == 0) {
      return IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.mic_off,
          color: Colors.grey,
        ),
      );
    }
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(CircleBorder()),
        padding: MaterialStateProperty.all(EdgeInsets.all(8)),
        backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) return Colors.grey;
        }),
        shadowColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) return Colors.grey;
        }),
      ),
      onPressed: () {
        if (microphone?.paused == true) {
          context.read<RoomClientRepository>().unmuteMic();
        } else {
          context.read<RoomClientRepository>().muteMic();
        }
      },
      child: Icon(
        microphone?.paused == true ? Icons.mic_off : Icons.mic,
        color: microphone == null ? Colors.grey : Colors.black,
      ),
    );
  }
}
