import 'package:flutter/scheduler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';

class DataProducerOptions {
  bool ordered;
  int maxPacketLifeTime;
  int maxRetransmits;
  Priority priority;
  String label;
  String protocol;
  Map<String, dynamic> appData;
}

Logger _logger = Logger('DataProducer');

class DataProducer extends EnhancedEventEmitter {
  // Id.
  String _id;
  // The underlying RTCDataChannel instance.
  RTCDataChannel _dataChannel;
  // Closed flag.
  bool _closed = false;
  // SCTP stream parameters.
  SctpStreamParameters _sctpStreamParameters;
  // App custom data.
  Map<String, dynamic> _appData;
  // Observer instance.
  EnhancedEventEmitter _observer = EnhancedEventEmitter();

	/// @emits transportclose
	/// @emits open
	/// @emits error - (error: Error)
	/// @emits close
	/// @emits bufferedamountlow
	/// @emits @close
  DataProducer({
    String id,
    RTCDataChannel dataChannel,
    SctpStreamParameters sctpStreamParameters,
    Map<String, dynamic> appData,
  }) : _appData = appData {
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
  RTCDataChannelState get readyState => _dataChannel.state;
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
}