import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:example/features/producers/bloc/producers_bloc.dart';
import 'package:example/features/producers/ui/renderer/dragger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LocalStream extends StatefulWidget {
  const LocalStream({Key? key}) : super(key: key);

  @override
  _LocalStreamState createState() => _LocalStreamState();
}

class _LocalStreamState extends State<LocalStream> {
  late RTCVideoRenderer renderer;
  final double streamContainerSize = 180;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProducersBloc, ProducersState>(
      listener: (context, state) {
        if (renderer.srcObject != state.webcam?.stream) {
          renderer.srcObject = state.webcam?.stream;
        }
      },
      builder: (context, state) {
        final MediaDeviceInfo? selectedVideoInput = context.select(
            (MediaDevicesBloc mediaDevicesBloc) =>
                mediaDevicesBloc.state.selectedVideoInput);
        if (renderer.srcObject != null && renderer.renderVideo)
          return Dragger(
            key: ValueKey('Dragger'),
            child: Container(
              key: ValueKey('RenderMe_Border'),
              width: streamContainerSize,
              height: streamContainerSize,
              // margin: const EdgeInsets.only(left: 5, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red,
                  width: 2.0,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child2: Container(
              key: ValueKey('RenderMe_View'),
              width: streamContainerSize - 4,
              height: streamContainerSize - 4,
              margin: const EdgeInsets.all(2),
              child: ClipOval(
                child: RTCVideoView(
                  renderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: selectedVideoInput != null &&
                          selectedVideoInput.label.contains('back')
                      ? false
                      : true,
                  // mirror: true,
                ),
              ),
            ),
          );

        return SizedBox.shrink();
      },
    );
  }

  void initRenderers() async {
    renderer = RTCVideoRenderer();
    await renderer.initialize();
  }

  @override
  void dispose() {
    renderer.dispose();
    super.dispose();
  }
}
