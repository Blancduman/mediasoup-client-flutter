import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:example/data/models/Peer.dart';
import 'package:example/logic/blocs/consumers/consumers_bloc.dart';

part 'peers_event.dart';
part 'peers_state.dart';

class PeersBloc extends Bloc<dynamic, PeersState> {
  final ConsumersBloc consumersBloc;
  PeersBloc({this.consumersBloc}) : super(PeersState());

  @override
  Stream<PeersState> mapEventToState(
    dynamic event,
  ) async* {
    if (event is PeerAdd) {
      yield* _mapPeerAddToState(event);
    } else if (event is PeerRemove) {
      yield* _mapPeerRemoveToState(event);
    } else if (event is PeerAddConsumer) {
      yield* _mapConsumerAddToState(event);
    } else if (event is PeerRemoveConsumer) {
      yield* _mapConsumerRemoveToState(event);
    }
  }

  Stream<PeersState> _mapPeerAddToState(PeerAdd event) async* {
    final Map<String, Peer> newPeers = Map<String, Peer>.of(state.peers);
    final Peer newPeer = Peer.fromMap(event.newPeer);
    newPeers[newPeer.id] = newPeer;

    yield PeersState(peers: newPeers);
  }

  Stream<PeersState> _mapPeerRemoveToState(PeerRemove event) async* {
    final Map<String, Peer> newPeers = Map<String, Peer>.of(state.peers);
    newPeers.remove(event.peerId);

    yield PeersState(peers: newPeers);
  }

  Stream<PeersState> _mapConsumerAddToState(PeerAddConsumer event) async* {
    final Map<String, Peer> newPeers = Map<String, Peer>.of(state.peers);
    newPeers[event.peerId] =
        Peer.copy(newPeers[event.peerId]);
    newPeers[event.peerId].consumers.add(event.consumerId);

    yield PeersState(peers: newPeers);
  }

  Stream<PeersState> _mapConsumerRemoveToState(PeerRemoveConsumer event) async* {
    final Map<String, Peer> newPeers = Map<String, Peer>.of(state.peers);
    newPeers[event.peerId]?.consumers?.removeWhere?.call((c) => c == event.consumerId);
    // final Map<String, Peer> newPeers = state.peers.map((key, value) {
    //   if (value.consumers.contains(event.consumerId)) {
    //     return MapEntry(key, Peer.copy(
    //       value,
    //       consumers: value
    //           .consumers
    //           .where((c) => c != event.consumerId)
    //           .toList(),
    //     ));
    //   }
    //   return MapEntry(key, value);
    // });

    yield PeersState(peers: newPeers);
  }
}
