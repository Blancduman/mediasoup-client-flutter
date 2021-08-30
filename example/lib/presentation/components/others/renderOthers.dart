import 'package:example/logic/blocs/consumers/consumers_bloc.dart';
import 'package:example/presentation/components/others/other.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/logic/blocs/peers/peers_bloc.dart';
import 'package:example/data/models/Peer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RenderOther extends StatelessWidget {
  const RenderOther({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, Peer> peers =
        context.select((PeersBloc bloc) => bloc.state.peers);
    final Map<String, RTCVideoRenderer> renderers =
    context.select((ConsumersBloc bloc) => bloc.state.renderers);

    return GridView.count(
      crossAxisCount: 2,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        for (final key in peers.keys)
          Other(
          key: Key(key),
          peer: peers[key],
          renderer: renderers[key],
        )
      ],
    );
  }
}
