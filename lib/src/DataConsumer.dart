import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';

class DataConsumerOptions {
  String id;
  String dataProducerId;
  SctpStreamParameters sctpStreamParameters;
  String label;
  String protocol;
  Map<String, dynamic> appData;
}

Logger _logger = Logger('DataConsumer');

class DataConsumer extends EnhancedEventEmitter {
  // Id.
  String _id;
  // Associated DataProducer id.
  String _dataProducerId;
  // The underlying RCTDataChannel instance.
  RTCDataChannel _dataChannel;
  // Clsoed flag.
  bool _closed = false;
  // SCTP stream parameters.
  SctpStreamParameters _sctpStreamParameters;
  // App custom data.
  final Map<String, dynamic> _appData;
  // Observer instance.
  EnhancedEventEmitter _observer = EnhancedEventEmitter();

  /// @emits transportclose
  /// @emits open
  /// @emits error - (error: Error)
  /// @emits close
  /// @emits message - (message: any)
  /// @emits @close
  DataConsumer({
    String id,
    String dataProducerId,
    RTCDataChannel dataChannel,
    SctpStreamParameters sctpStreamParameters,
    Map<String, dynamic> appData,
  }) : _appData = appData, super() {
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
  RTCDataChannelState get readyState => _dataChannel.state;

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
}
