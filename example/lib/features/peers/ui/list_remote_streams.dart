import 'package:example/features/peers/ui/remote_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/features/peers/bloc/peers_bloc.dart';
import 'package:example/features/peers/enitity/peer.dart';

class ListRemoteStreams extends StatelessWidget {
  const ListRemoteStreams({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, Peer> peers =
        context.select((PeersBloc bloc) => bloc.state.peers);

    final bool small = MediaQuery.of(context).size.width < 800;
    final bool horizontal = MediaQuery.of(context).orientation == Orientation.landscape;

    if (small && peers.length == 1) {
      return RemoteStream(
        key: ValueKey(peers.keys.first),
        peer: peers.values.first,
      );
    }

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;


    if (small && horizontal)
      return MediaQuery.removePadding(context: context, child: GridView.count(
        crossAxisCount: 2,
        children: peers.values.map((peer) {
          return Container(
            key: ValueKey('${peer.id}_container'),
            width: width / 2,
            height: peers.length <= 2 ? height : height / 2,
            child: RemoteStream(
              key: ValueKey(peer.id),
              peer: peer,
            ),
          );
        }).toList(),
      ),
        removeTop: true,
      );
    
    if (small)
      return MediaQuery.removePadding(context: context, child: ListView.builder(
        itemBuilder: (context, index) {
          final peerId = peers.keys.elementAt(index);
          return Container(
            key: ValueKey('${peerId}_container'),
            width: double.infinity,
            height: peers.length > 2 ? height / 3 : height / 2,
            child: RemoteStream(
              key: ValueKey(peerId),
              peer: peers[peerId]!,
            ),
          );
        },
        itemCount: peers.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
      ), removeTop: true,);

    return Center(
      child: Wrap(
        spacing: 10,
        children: [
          for (Peer peer in peers.values)
            Container(
              key: ValueKey('${peer.id}_container'),
              width: 450,
              height: 380,
              child: RemoteStream(
                key: ValueKey(peer.id),
                peer: peers[peer.id]!,
              ),
            ),
        ],
      ),
    );
  }
}
