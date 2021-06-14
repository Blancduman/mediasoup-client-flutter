import 'package:example/logic/blocs/producers/producers_bloc.dart';
import 'package:example/presentation/components/me/microphone.dart';
import 'package:example/presentation/components/me/webcam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RenderMe extends StatefulWidget {
  const RenderMe({Key key}) : super(key: key);

  @override
  _RenderMeState createState() => _RenderMeState();
}

class _RenderMeState extends State<RenderMe> {
  RTCVideoRenderer renderer;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProducersBloc, ProducersState>(
      listener: (context, state) {
        renderer.srcObject = state.webcam?.stream;
      },
      builder: (context, state) {
        return Align(
          alignment: Alignment.bottomLeft,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .3,
                height: MediaQuery.of(context).size.height * .3,
                margin: const EdgeInsets.only(left: 5, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                    style: BorderStyle.solid,
                  ),
                ),
                child: RTCVideoView(
                  renderer,
                  // mirror: true,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Microphone(),
                    Webcam(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void initRenderers() async {
    renderer = RTCVideoRenderer();
    await renderer.initialize();
  }

  @override
  void dispose() {
    renderer?.dispose();
    super.dispose();
  }
}
