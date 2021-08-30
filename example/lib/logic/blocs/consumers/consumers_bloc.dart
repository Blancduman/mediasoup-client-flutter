import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

part 'consumers_event.dart';
part 'consumers_state.dart';

class ConsumersBloc extends Bloc<ConsumersEvent, ConsumersState> {
  Timer timer;
  StreamController<ConsumersEvent> subs;
  ConsumersBloc() : super(ConsumersState()) {
    subs = StreamController<ConsumersEvent>();
  }

  @override
  Stream<ConsumersState> mapEventToState(
    ConsumersEvent event,
  ) async* {
    if (event is ConsumerAdd) {
      yield* _mapConsumersAddToState(event);
      subs?.add(event);
    } else if (event is ConsumerRemove) {
      yield* _mapConsumersRemoveToState(event);
      subs?.add(event);
    } else if (event is ConsumerResumed) {
      yield* _mapConsumerResumedToState(event);
    } else if (event is ConsumerPaused) {
      yield* _mapConsumerPausedToState(event);
    }
  }

  Stream<ConsumersState> _mapConsumersAddToState(ConsumerAdd event) async* {
    final Map<String, Consumer> newConsumers = Map<String, Consumer>.of(state.consumers);
    final Map<String, RTCVideoRenderer> newRenderers = Map<String, RTCVideoRenderer>.of(state.renderers);
    newConsumers[event.consumer.id] = event.consumer;
    final String peerId = event.consumer.peerId;
    if (kIsWeb) {
      if (newRenderers[peerId] == null) {
        newRenderers[peerId] = RTCVideoRenderer();
        await newRenderers[peerId].initialize();
      }
      final Consumer existing = newConsumers.values.firstWhere(
        (c) => c.peerId == peerId && c.id != event.consumer.id,
        orElse: () => null,
      );

      if (existing != null) {
        if (existing.kind == 'audio' && event.consumer.kind == 'video') {
          newRenderers[peerId].srcObject = event.consumer.stream;
        }
      } else {
        newRenderers[peerId].srcObject = event.consumer.stream;
      }
    } else if (event.consumer.kind == 'video') {
      newRenderers[peerId] = RTCVideoRenderer();
      await newRenderers[peerId].initialize();
      newRenderers[peerId].srcObject = newConsumers[event.consumer.id].stream;
    }

    yield ConsumersState(consumers: newConsumers, renderers: newRenderers);
  }

  Stream<ConsumersState> _mapConsumersRemoveToState(ConsumerRemove event) async* {
    final Map<String, Consumer> newConsumers = Map<String, Consumer>.of(state.consumers);
    final Map<String, RTCVideoRenderer> newRenderers = Map<String, RTCVideoRenderer>.of(state.renderers);
    final peerId = newConsumers[event.consumerId].peerId;
    await newConsumers[event.consumerId]?.close();
    newConsumers.remove(event.consumerId);
    final renderer = newRenderers[peerId];

    if (kIsWeb) {
      final Consumer existing = newConsumers.values.firstWhere(
        (c) => c.peerId == peerId,
        orElse: () => null,
      );
      if (existing == null) {
        await renderer?.dispose();
      } else {
        renderer.srcObject = existing.stream;
      }
    } else {
      newRenderers.remove(peerId);
      renderer.srcObject = null;
      await renderer?.dispose();
    }


    yield ConsumersState(consumers: newConsumers, renderers: newRenderers);
  }

  Stream<ConsumersState> _mapConsumerResumedToState(ConsumerResumed event) async* {
    final Map<String, Consumer> newConsumers = Map<String, Consumer>.of(state.consumers);
    newConsumers[event.consumerId]?.resume();

    yield ConsumersState(consumers: newConsumers, renderers: state.renderers);
  }

  Stream<ConsumersState> _mapConsumerPausedToState(ConsumerPaused event) async* {
    final Map<String, Consumer> newConsumers = Map<String, Consumer>.of(state.consumers);
    newConsumers[event.consumerId]?.pause();

    yield ConsumersState(consumers: newConsumers, renderers: state.renderers);
  }

  @override
  Future<void> close() async {
    await subs?.close();
    for (var r in state.renderers.values) {
      await r.dispose();
    }
    return super.close();
  }
}
