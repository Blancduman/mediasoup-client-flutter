import 'package:flutter/material.dart';
import 'package:example/features/peers/enitity/peer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RemoteStream extends StatelessWidget {
  final Peer peer;

  const RemoteStream({required Key key, required this.peer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (peer.renderer != null && peer.video != null)
            RTCVideoView(
              peer.renderer!,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  Icons.person,
                  // size: double.infinity,
                ),
              ),
            ),
          Positioned(
              bottom: 5,
              left: 2,
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${peer.displayName}',
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${peer.device.name} ${peer.device.version}',
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                padding: const EdgeInsets.all(8),
              ))
        ],
      ),
    );
  }
}
