part of 'peers_bloc.dart';

abstract class PeersEvent extends Equatable {
  const PeersEvent();
}

class PeerAdd extends PeersEvent {
  final Map<String, dynamic> newPeer;

  const PeerAdd({this.newPeer});

  @override
  List<Object> get props => [newPeer];
}

class PeerAddConsumer extends PeersEvent {
  final String consumerId;
  final String peerId;

  const PeerAddConsumer({this.consumerId, this.peerId});

  @override
  List<Object> get props => [consumerId, peerId];
}

class PeerRemoveConsumer extends PeersEvent {
  final String consumerId;
  final String peerId;

  const PeerRemoveConsumer({this.consumerId, this.peerId});

  @override
  List<Object> get props => [consumerId, peerId];
}

class PeerRemove extends PeersEvent {
  final String peerId;

  const PeerRemove({this.peerId});

  @override
  List<Object> get props => [peerId];
}