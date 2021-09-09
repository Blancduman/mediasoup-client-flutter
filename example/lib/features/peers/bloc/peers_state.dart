part of 'peers_bloc.dart';

class PeersState extends Equatable {
  final Map<String, Peer> peers;

  const PeersState({this.peers = const <String, Peer>{}});

  @override
  List<Object> get props => [peers];
}
