import 'package:flutter/material.dart';
import 'package:example/data/models/Peer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

class Other extends StatelessWidget {
  final Peer peer;
  final Consumer video;
  final RTCVideoRenderer renderer;

  const Other({Key key, this.peer, this.video, this.renderer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: 300,
      color: Colors.black87,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video != null && renderer != null)
            RTCVideoView(renderer)
          else
            Container(
              height: 250,
              width: 300,
              decoration: BoxDecoration(color: Colors.black54),
            ),
          Positioned(
              bottom: 5,
              left: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      '${peer.displayName}\n${peer.device.name} ${peer.device.version}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
