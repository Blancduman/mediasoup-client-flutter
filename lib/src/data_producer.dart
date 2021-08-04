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
  // Id.
  late String _id;
  // The underlying RTCDataChannel instance.
  late RTCDataChannel _dataChannel;
  // Closed flag.
  bool _closed = false;
  // SCTP stream parameters.
  late SctpStreamParameters _sctpStreamParameters;
  // App custom data.
  late final Map<String, dynamic> _appData;
  // Observer instance.
  final EnhancedEventEmitter _observer = EnhancedEventEmitter();

  /// @emits transportclose
  /// @emits open
  /// @emits error - (error: Error)
  /// @emits close
  /// @emits bufferedamountlow
  /// @emits @close
  DataProducer({
    required String id,
    required RTCDataChannel dataChannel,
    required SctpStreamParameters sctpStreamParameters,
    required Map<String, dynamic> appData,
  })  : _appData = appData,
        super() {
    _logger.debug('constructor()');

    _id = id;
    _dataChannel = dataChannel;
    _sctpStreamParameters = sctpStreamParameters;

    _handleDataChannel();
  }

  /// DataProducer id.
  String get id => _id;

  /// Whether the DataProducer is closed.
  bool get closed => _closed;

  /// SCTP stream parameters.
  SctpStreamParameters get sctpStreamParameters => _sctpStreamParameters;

  /// DataChannel readyState.
  RTCDataChannelState? get readyState => _dataChannel.state;

  /// App custom data.
  Map<String, dynamic> get appData => _appData;

  /// Observer.
  EnhancedEventEmitter get observer => _observer;

  /// Closes the DataProducer.
  void close() {
    if (_closed) return;

    _logger.debug('close()');

    _closed = true;

    _dataChannel.close();

    emit('@close');

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Transport was closed.
  void transportClosed() {
    if (_closed) return;

    _logger.debug('transportClosed()');

    _closed = true;

    _dataChannel.close();

    safeEmit('transportclose');

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Send a message.
  /// @param data.
  void send(dynamic data) {
    _logger.debug('send()');

    if (_closed) throw 'closed';

    _dataChannel.send(data);
  }

  void _handleDataChannel() {
    _dataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        if (_closed) return;

        _logger.debug('DataChannel "open" event');

        safeEmit('open');
      } else if (state == RTCDataChannelState.RTCDataChannelClosing) {
        if (_closed) return;

        _logger.warn('DataChannel "close" event');

        _closed = true;

        emit('@close');
        safeEmit('close');
      }
    };

    _dataChannel.onMessage = (RTCDataChannelMessage message) {
      if (_closed) return;

      _logger.warn(
        'DataChannel "message" event is a DataProducer, message discarded',
      );
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataProducer &&
        other._id == _id &&
        other._dataChannel == _dataChannel &&
        other._closed == _closed &&
        other._sctpStreamParameters == _sctpStreamParameters &&
        other._appData == _appData;
  }

  @override
  int get hashCode {
    return _id.hashCode ^
        _dataChannel.hashCode ^
        _closed.hashCode ^
        _sctpStreamParameters.hashCode ^
        _appData.hashCode;
  }
}
