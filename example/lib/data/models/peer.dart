import 'package:example/data/models/peer_device.dart';

class Peer {
  final List<String> consumers;
  final List<String> dataConsumers;
  final PeerDevice device;
  final String displayName;
  final String id;

  const Peer({
    this.consumers = const [],
    this.dataConsumers = const [],
    this.device,
    this.displayName,
    this.id,
  });


  Peer.fromMap(Map data)
      : id = data['id'],
        displayName = data['displayName'],
        consumers = data['consumers'] ?? [],
        dataConsumers = data['dataConsumers'] ?? [],
        device = PeerDevice.fromMap(data['device']);

  static Peer copy(
    Peer old, {
    List<String> consumers,
    List<String> dataConsumers,
    PeerDevice device,
    String displayName,
    String id,
  }) {
    return Peer(
      consumers: consumers != null ? List<String>.of(consumers) : old.consumers,
      displayName: displayName ?? old.displayName,
      dataConsumers: dataConsumers != null
          ? List<String>.of(dataConsumers)
          : old.consumers,
      device: device ?? old.device,
      id: id ?? old.id,
    );
  }
}
