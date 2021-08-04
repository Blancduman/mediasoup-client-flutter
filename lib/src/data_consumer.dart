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

  DataConsumerOptions({
    required this.id,
    required this.dataProducerId,
    required this.sctpStreamParameters,
    required this.label,
    required this.protocol,
    required this.appData,
  });
}

Logger _logger = Logger('DataConsumer');

class DataConsumer extends EnhancedEventEmitter {
  // Id.
  late String _id;
  // Associated DataProducer id.
  late String _dataProducerId;
  // The underlying RCTDataChannel instance.
  late RTCDataChannel _dataChannel;
  // Clsoed flag.
  bool _closed = false;
  // SCTP stream parameters.
  late SctpStreamParameters _sctpStreamParameters;
  // App custom data.
  final Map<String, dynamic> _appData;
  // Observer instance.
  final EnhancedEventEmitter _observer = EnhancedEventEmitter();

  /// @emits transportclose
  /// @emits open
  /// @emits error - (error: Error)
  /// @emits close
  /// @emits message - (message: any)
  /// @emits @close
  DataConsumer({
    required String id,
    required String dataProducerId,
    required RTCDataChannel dataChannel,
    required SctpStreamParameters sctpStreamParameters,
    required Map<String, dynamic> appData,
  })  : _appData = appData,
        super() {
    _logger.debug('constructor()');

    _id = id;
    _dataProducerId = dataProducerId;
    _dataChannel = dataChannel;
    _sctpStreamParameters = sctpStreamParameters;

    _handleDataChannel();
  }

  /// DataConsumer id.
  String get id => _id;

  /// Associated DataProducer id.
  String get dataProducerId => _dataProducerId;

  /// Whether the DataConsumer is closed.
  bool get closed => _closed;

  /// SCTP stream parameters.
  SctpStreamParameters get sctpStreamParameters => _sctpStreamParameters;

  /// DataChannel readyState.
  RTCDataChannelState? get readyState => _dataChannel.state;

  /*
    /// DataChannel label.
    String get label => 'TODO: _dataChannel.label';
    /// DataChannel protocol.
    String get protocol => _dataChannel.
  */

  /// App custom data.
  Map<String, dynamic> get appData => _appData;

  /// Observer.
  EnhancedEventEmitter get observer => _observer;

  /// Closes the DataConsumer.
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

  void _handleDataChannel() {
    _dataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        if (_closed) return;

        _logger.debug('DataChannel "open" event');

        safeEmit('open');
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        if (_closed) return;

        _logger.warn('DataChannel "close" event');

        _closed = true;

        emit('@close');
        safeEmit('close');
      }
    };
    _dataChannel.onMessage = (RTCDataChannelMessage data) {
      if (_closed) return;

      safeEmit('message', {
        'data': data,
      });
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataConsumer &&
        other._id == _id &&
        other._dataProducerId == _dataProducerId &&
        other._dataChannel == _dataChannel &&
        other._closed == _closed &&
        other._sctpStreamParameters == _sctpStreamParameters &&
        mapEquals(other._appData, _appData);
  }

  @override
  int get hashCode {
    return _id.hashCode ^
        _dataProducerId.hashCode ^
        _dataChannel.hashCode ^
        _closed.hashCode ^
        _sctpStreamParameters.hashCode ^
        _appData.hashCode;
  }
}
