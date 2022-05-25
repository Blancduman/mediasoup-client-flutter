import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:mediasoup_client_flutter/src/sctp_parameters.dart';
import 'package:mediasoup_client_flutter/src/common/enhanced_event_emitter.dart';
import 'package:mediasoup_client_flutter/src/common/logger.dart';

class DataConsumerOptions {
  final String id;
  final String dataProducerId;
  final SctpStreamParameters sctpStreamParameters;
  final String label;
  final String protocol;
  final Map<String, dynamic> appData;
  final String? peerId;

  DataConsumerOptions({
    required this.id,
    required this.dataProducerId,
    required this.sctpStreamParameters,
    required this.label,
    required this.protocol,
    required this.appData,
    this.peerId,
  });
}

Logger _logger = Logger('DataConsumer');

class DataConsumer extends EnhancedEventEmitter {
  /// Id.
  final String id;
  /// Associated DataProducer id.
  final String dataProducerId;
  /// The underlying RCTDataChannel instance.
  final RTCDataChannel dataChannel;
  /// Clsoed flag.
  bool closed;
  /// SCTP stream parameters.
  final SctpStreamParameters sctpStreamParameters;
  /// App custom data.
  final Map<String, dynamic> appData;
  /// Observer instance.
  final EnhancedEventEmitter observer;
  /// Peer id.
  final String? peerId;

  /// @emits transportclose
  /// @emits open
  /// @emits error - (error: Error)
  /// @emits close
  /// @emits message - (message: any)
  /// @emits @close
  DataConsumer({
    required this.id,
    required this.dataProducerId,
    required this.dataChannel,
    required this.sctpStreamParameters,
    this.appData = const <String, dynamic>{},
    this.closed = false,
    this.peerId
  }) : observer = EnhancedEventEmitter(),
        super() {
    _logger.debug('constructor()');

    _handleDataChannel();
  }
  /// DataChannel readyState.
  RTCDataChannelState? get readyState => dataChannel.state;

  /*
    /// DataChannel label.
    String get label => 'TODO: _dataChannel.label';
    /// DataChannel protocol.
    String get protocol => _dataChannel.
  */

  /// Closes the DataConsumer.
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

  void _handleDataChannel() {
    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        if (closed) return;

        _logger.debug('DataChannel "open" event');

        safeEmit('open');
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        if (closed) return;

        _logger.warn('DataChannel "close" event');

        closed = true;

        emit('@close');
        safeEmit('close');
      }
    };
    dataChannel.onMessage = (RTCDataChannelMessage data) {
      if (closed) return;

      safeEmit('message', {
        'data': data,
      });
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataConsumer &&
        other.id == id &&
        other.dataProducerId == dataProducerId &&
        other.dataChannel == dataChannel &&
        other.closed == closed &&
        other.sctpStreamParameters == sctpStreamParameters &&
        mapEquals(other.appData, appData);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dataProducerId.hashCode ^
        dataChannel.hashCode ^
        closed.hashCode ^
        sctpStreamParameters.hashCode ^
        appData.hashCode;
  }
}
