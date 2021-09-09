import 'dart:async';
import 'package:collection/collection.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:example/features/peers/enitity/peer.dart';
import 'package:example/features/media_devices/bloc/media_devices_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

part 'peers_event.dart';
part 'peers_state.dart';

class PeersBloc extends Bloc<dynamic, PeersState> {
  final MediaDevicesBloc mediaDevicesBloc;
  String selectedOutputId = '';
  PeersBloc({required this.mediaDevicesBloc}) : super(PeersState()) {
    // if (mediaDevicesBloc.state.selectedAudioOutput?.deviceId != null) {
    //   selectedOutputId = mediaDevicesBloc.state.selectedAudioOutput!.deviceId;
    // }
    //
    // mediaDevicesBloc.stream.listen((event) {
    //   state.peers.values.forEach((p) {
    //     final String? deviceId = event.selectedAudioOutput?.deviceId;
    //     if (deviceId != null) {
    //       selectedOutputId = deviceId;
    //       p.renderer?.audioOutput = selectedOutputId;
    //     }
    //   });
    // });
  }

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
    } else if (event is PeerPausedConsumer) {
      yield* _mapPeerPausedConsumer(event);
    } else if (event is PeerResumedConsumer) {
      yield* _mapPeerResumedConsumer(event);
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

    if (kIsWeb) {
      if (newPeers[event.peerId]!.renderer == null) {
        newPeers[event.peerId] = newPeers[event.peerId]!.copyWith(renderer: RTCVideoRenderer());
        await newPeers[event.peerId]!.renderer!.initialize();
        // newPeers[event.peerId]!.renderer!.audioOutput = selectedOutputId;
      }

      if (event.consumer.kind == 'video') {
        newPeers[event.peerId] = newPeers[event.peerId]!.copyWith(video: event.consumer);
        newPeers[event.peerId]!.renderer!.srcObject =
            newPeers[event.peerId]!.video!.stream;
      }

      if (event.consumer.kind == 'audio') {
        newPeers[event.peerId] = newPeers[event.peerId]!.copyWith(audio: event.consumer);
        if (newPeers[event.peerId]!.video == null) {
          newPeers[event.peerId]!.renderer!.srcObject =
              newPeers[event.peerId]!.audio!.stream;
        }
      }
    } else {
      if (event.consumer.kind == 'video') {
        newPeers[event.peerId] = newPeers[event.peerId]!.copyWith(
          renderer: RTCVideoRenderer(),
          video: event.consumer,
        );
        await newPeers[event.peerId]!.renderer!.initialize();
        // newPeers[event.peerId]!.renderer!.audioOutput = selectedOutputId;
        newPeers[event.peerId]!.renderer!.srcObject =
            newPeers[event.peerId]!.video!.stream;
      } else {
        newPeers[event.peerId] = newPeers[event.peerId]!.copyWith(
          audio: event.consumer,
        );
      }
    }

    yield PeersState(peers: newPeers);
  }

  Stream<PeersState> _mapConsumerRemoveToState(
      PeerRemoveConsumer event) async* {
    final Map<String, Peer> newPeers = Map<String, Peer>.of(state.peers);
    final Peer? peer = newPeers.values
        .firstWhereOrNull((p) => p.consumers.contains(event.consumerId));

    if (peer != null) {
      if (kIsWeb) {
        if (peer.audio?.id == event.consumerId) {
          final consumer = peer.audio;
          if (peer.video == null) {
            final renderer = newPeers[peer.id]?.renderer!;
            newPeers[peer.id] = newPeers[peer.id]!.removeAudioAndRenderer();
            yield PeersState(peers: newPeers);
            await renderer?.dispose();
          } else {
            newPeers[peer.id] = newPeers[peer.id]!.removeAudio();
            yield PeersState(peers: newPeers);
          }
          await consumer?.close();
        } else if (peer.video?.id == event.consumerId) {
          final consumer = peer.audio;
          if (peer.audio != null) {
            newPeers[peer.id]!.renderer!.srcObject =
                newPeers[peer.id]!.audio!.stream;
            newPeers[peer.id] = newPeers[peer.id]!.removeVideo();
            yield PeersState(peers: newPeers);
          } else {
            final renderer = newPeers[peer.id]!.renderer!;
            newPeers[peer.id] = newPeers[peer.id]!.removeVideoAndRenderer();
            yield PeersState(peers: newPeers);
            await renderer.dispose();
          }
          await consumer?.close();
        }
      } else {
        if (peer.audio?.id == event.consumerId) {
          final consumer = peer.audio;
          newPeers[peer.id] = newPeers[peer.id]!.removeAudio();
          yield PeersState(peers: newPeers);
          await consumer?.close();
        } else if (peer.video?.id == event.consumerId) {
          final consumer = peer.video;
          final renderer = peer.renderer;
          newPeers[peer.id] = newPeers[peer.id]!.removeVideoAndRenderer();
          await consumer?.close();
          await renderer?.dispose();
        }
      }
    }
  }

  Stream<PeersState> _mapPeerPausedConsumer(PeerPausedConsumer event) async* {
    final Map<String, Peer> newPeers = Map<String, Peer>.of(state.peers);
    final Peer? peer = newPeers.values
        .firstWhereOrNull((p) => p.consumers.contains(event.consumerId));

    if (peer != null) {
      newPeers[peer.id] = newPeers[peer.id]!.copyWith(
        audio: peer.audio!.pauseCopy(),
      );

      yield PeersState(peers: newPeers);
    }
  }

  Stream<PeersState> _mapPeerResumedConsumer(PeerResumedConsumer event) async* {
    final Map<String, Peer> newPeers = Map<String, Peer>.of(state.peers);
    final Peer? peer = newPeers.values
        .firstWhereOrNull((p) => p.consumers.contains(event.consumerId));

    if (peer != null) {
      newPeers[peer.id] = newPeers[peer.id]!.copyWith(
        audio: peer.audio!.resumeCopy(),
      );

      yield PeersState(peers: newPeers);
    }
  }
}
