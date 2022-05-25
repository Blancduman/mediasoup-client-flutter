import 'package:flutter/scheduler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:mediasoup_client_flutter/src/sctp_parameters.dart';
import 'package:mediasoup_client_flutter/src/common/enhanced_event_emitter.dart';
import 'package:mediasoup_client_flutter/src/common/logger.dart';

class DataProducerOptions {
  final bool ordered;
  final int maxPacketLifeTime;
  final int maxRetransmits;
  final Priority priority;
  final String label;
  final String protocol;
  final Map<String, dynamic> appData;

  DataProducerOptions({
    required this.ordered,
    required this.maxPacketLifeTime,
    required this.maxRetransmits,
    required this.priority,
    required this.label,
    required this.protocol,
    required this.appData,
  });
}

Logger _logger = Logger('DataProducer');

class DataProducer extends EnhancedEventEmitter {
  /// Id.
  final String id;

  /// The underlying RTCDataChannel instance.
  final RTCDataChannel dataChannel;

  /// Closed flag.
  bool closed = false;

  /// SCTP stream parameters.
  final SctpStreamParameters sctpStreamParameters;

  /// App custom data.
  final Map<String, dynamic> appData;

  /// Observer instance.
  final EnhancedEventEmitter observer;

  /// @emits transportclose
  /// @emits open
  /// @emits error - (error: Error)
  /// @emits close
  /// @emits bufferedamountlow
  /// @emits @close
  DataProducer({
    required this.id,
    required this.dataChannel,
    required this.sctpStreamParameters,
    required this.appData,
    this.closed = false,
  })  : observer = EnhancedEventEmitter(),
        super() {
    _logger.debug('constructor()');

    _handleDataChannel();
  }

  /// DataChannel readyState.
  RTCDataChannelState? get readyState => dataChannel.state;

  /// Closes the DataProducer.
  void close() {
    if (closed) return;

    _logger.debug('close()');

    closed = true;

    dataChannel.close();

    emit('@close');

    // Emit observer event.
    observer.safeEmit('close');
  }

  /// Transport was closed.
  void transportClosed() {
    if (closed) return;

    _logger.debug('transportClosed()');

    closed = true;

    dataChannel.close();

    safeEmit('transportclose');

    // Emit observer event.
    observer.safeEmit('close');
  }

  /// Send a message.
  /// @param data.
  void send(dynamic data) {
    _logger.debug('send()');

    if (closed) throw 'closed';

    dataChannel.send(data is String ? RTCDataChannelMessage(data) : RTCDataChannelMessage.fromBinary(data));
  }

  void _handleDataChannel() {
    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        if (closed) return;

        _logger.debug('DataChannel "open" event');

        safeEmit('open');
      } else if (state == RTCDataChannelState.RTCDataChannelClosing) {
        if (closed) return;

        _logger.warn('DataChannel "close" event');

        closed = true;

        emit('@close');
        safeEmit('close');
      }
    };

    dataChannel.onMessage = (RTCDataChannelMessage message) {
      if (closed) return;

      _logger.warn(
        'DataChannel "message" event is a DataProducer, message discarded',
      );
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataProducer &&
        other.id == id &&
        other.dataChannel == dataChannel &&
        other.closed == closed &&
        other.sctpStreamParameters == sctpStreamParameters &&
        other.appData == appData;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dataChannel.hashCode ^
        closed.hashCode ^
        sctpStreamParameters.hashCode ^
        appData.hashCode;
  }
}
