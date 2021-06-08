import 'package:example/data/repositories/room_client_repository.dart';
import 'package:example/logic/blocs/producers/producers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Microphone extends StatefulWidget {
  const Microphone({Key key}) : super(key: key);

  @override
  _MicrophoneState createState() => _MicrophoneState();
}

class _MicrophoneState extends State<Microphone> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProducersBloc, ProducersState>(
      builder: (context, state) {
        if (state.mic == null)
          return IconButton(
            icon: Icon(
              Icons.mic_off,
              color: Colors.grey,
            ),
            onPressed: () {},
          );
        return IconButton(
            onPressed: () {
              if (state.mic.paused) {
                context.read<RoomClientRepository>().unmuteMic();
                setState(() {});
              } else {
                context.read<RoomClientRepository>().muteMic();
                setState(() {});
              }
            },
            icon: Icon(state.mic.paused ? Icons.mic_off : Icons.mic));
      },
    );
  }
}
