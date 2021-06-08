import 'package:example/data/repositories/room_client_repository.dart';
import 'package:example/logic/blocs/me/me_bloc.dart';
import 'package:example/logic/blocs/producers/producers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Webcam extends StatefulWidget {
  const Webcam({Key key}) : super(key: key);

  @override
  _WebcamState createState() => _WebcamState();
}

class _WebcamState extends State<Webcam> {
  @override
  Widget build(BuildContext context) {
    bool inProgress = context.select((MeBloc bloc) => bloc.state.webcamInProgress);

    return BlocBuilder<ProducersBloc, ProducersState>(
      builder: (context, state) {
        // if (state.webcam == null) return IconButton(icon: Icon(Icons.videocam_off, color: Colors.grey,),);
        return IconButton(
            onPressed: () {
              if (inProgress) {
                return;
              }
              if (state.webcam != null) {
                context.read<RoomClientRepository>().disableWebcam();
                setState(() {
                });
              } else {
                context.read<RoomClientRepository>().enableWebcam();
                setState(() {
                });
              }
            },
            icon: Icon(
                state.webcam == null ? Icons.videocam_off : Icons.videocam));
      },
    );
  }
}
