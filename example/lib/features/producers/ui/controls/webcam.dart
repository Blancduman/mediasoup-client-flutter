import 'package:example/features/me/bloc/me_bloc.dart';
import 'package:example/features/producers/bloc/producers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:example/features/signaling/room_client_repository.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

class Webcam extends StatelessWidget {
  const Webcam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int videoInputDevicesLength = context.select(
            (MediaDevicesBloc bloc) =>
        bloc.state.videoInputs.length);
    final bool inProgress = context
        .select((MeBloc bloc) => bloc.state.webcamInProgress);
    final Producer? webcam = context
        .select((ProducersBloc bloc) => bloc.state.webcam);
    if (videoInputDevicesLength == 0) {
      return IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.videocam,
          color: Colors.grey,
          // size: screenHeight * 0.045,
        ),
      );
    }
    if (webcam == null) {
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
          if (!inProgress) {
            context
                .read<RoomClientRepository>()
                .enableWebcam();
          }
        },
        child: Icon(
          Icons.videocam_off,
          color: Colors.black,
          // size: screenHeight * 0.045,
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
        if (!inProgress) {
          context
              .read<RoomClientRepository>()
              .disableWebcam();
        }
      },
      child: Icon(
        Icons.videocam,
        color: Colors.black,
        // size: screenHeight * 0.045,
      ),
    );
  }
}
