import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:mediasoup_client_flutter/src/rtp_parameters.dart';
import 'package:mediasoup_client_flutter/src/common/enhanced_event_emitter.dart';
import 'package:mediasoup_client_flutter/src/common/logger.dart';

Logger _logger = Logger('Consumer');

class ConsumerOptions {
  final String id;
  final String producerId;
  final RTCRtpMediaType kind;
  final RtpParameters rtpParameters;

  ConsumerOptions({
    required this.id,
    required this.producerId,
    required this.kind,
    required this.rtpParameters,
  });
}

typedef void ConsumerOnTrackEnded();

class Consumer extends EnhancedEventEmitter {
  /// Id.
  late String _id;

  /// Local id.
  late String _localId;

  /// Associated Producer id.
  late String _producerId;

  /// Closed flag.
  bool _closed = false;

  /// Associated RTCRtpReceiver.
  RTCRtpReceiver? _rtpReceiver;

  /// Remote track.
  late MediaStreamTrack _track;

  /// RTP parameters.
  late RtpParameters _rtpParameters;

  /// Paused flag.
  late bool _paused;

  /// App custom data.
  final Map<String, dynamic> _appData;

  /// Stream.
  late MediaStream _stream;

  /// Observer instance.
  final EnhancedEventEmitter _observer = EnhancedEventEmitter();

  /// Peer id.
  late String _peerId;

  /// @emits transportclose
  /// @emits trackended
  /// @emits @getstats
  /// @emits @close
  Consumer({
    required String id,
    required String localId,
    required String producerId,
    RTCRtpReceiver? rtpReceiver,
    required MediaStreamTrack track,
    required RtpParameters rtpParameters,
    required Map<String, dynamic> appData,
    required MediaStream stream,
    required String peerId,
  })  : this._appData = appData,
        super() {
    _logger.debug('constructor()');

    _id = id;
    _localId = localId;
    _producerId = producerId;
    _rtpReceiver = rtpReceiver;
    _track = track;
    _rtpParameters = rtpParameters;
    _paused = !track.enabled;
    _stream = stream;
    _peerId = peerId;
    _handleTrack();
  }

  /// Consumer id.
  String get id => _id;

  /// Local id.
  String get localId => _localId;

  /// Associated Producer id.
  String get producerId => _producerId;

  /// Wheter the Consumer is closed.
  bool get closed => _closed;

  /// Media kind.
  String? get kind => _track.kind;

  /// Associated RTCRtpReceiver.
  RTCRtpReceiver? get rtpReceiver => _rtpReceiver;

  /// The associated track.
  MediaStreamTrack get track => _track;

  /// RTP parameters.
  RtpParameters get rtpParameters => _rtpParameters;

  /// Whether the Consumer is paused.
  bool get paused => _paused;

  /// App custom data.
  Map<String, dynamic> get appData => _appData;

  /// Stream.
  MediaStream get stream => _stream;

  /// Observer.
  ///
  /// @emits close
  /// @emits pause
  /// @emits resume
  /// @emits trackended
  EnhancedEventEmitter get observer => _observer;

  /// Peer id.
  String get peerId => _peerId;

  /// Closes the Consumer.
  Future<void> close() async {
    if (_closed) return;

    _logger.debug('close()');

    _closed = true;
    await _destroyTrack();
    emit('@close');
    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Transport was closed.
  Future<void> transportClosed() async {
    if (_closed) return;
    _logger.debug('transportClosed()');
    _closed = true;
    await _destroyTrack();
    safeEmit('transportclose');
    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Get associated RTCRtpReceiver stats.
  Future<dynamic> getStats() async {
    if (_closed) throw 'Closed';

    return safeEmitAsFuture('@getstats');
  }

  /// Pauses receiving media.
  void pause() {
    _logger.debug('pause()');

    if (_closed) {
      _logger.error('pause() | Consumer closed');
      return;
    }

    _paused = true;
    _track.enabled = false;

    // Emit observer event.
    _observer.safeEmit('pause');
  }

  /// Resumes receiving media.
  void resume() {
    _logger.debug('resume()');

    if (_closed) {
      _logger.error('resume() | Consumer closed.');

      return;
    }

    _paused = false;
    _track.enabled = true;

    // Emit observer event.
    _observer.safeEmit('resume');
  }

  void _onTrackEnded() {
    _logger.debug('track "ended" event');

    safeEmit('trackended');
    // Emit observer event.
    _observer.safeEmit('trackended');
  }

  void _handleTrack() {
    _track.onEnded = _onTrackEnded;
  }

  Future<void> _destroyTrack() async {
    try {
      _track.onEnded = null;
      await _track.stop();
    } catch (error) {}
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Consumer &&
        other._id == _id &&
        other._localId == _localId &&
        other._producerId == _producerId &&
        other._closed == _closed &&
        other._rtpReceiver == _rtpReceiver &&
        other._track == _track &&
        other._rtpParameters == _rtpParameters &&
        other._paused == _paused &&
        mapEquals(other._appData, _appData) &&
        other._stream == _stream &&
        other._peerId == _peerId;
  }

  @override
  int get hashCode {
    return _id.hashCode ^
        _localId.hashCode ^
        _producerId.hashCode ^
        _closed.hashCode ^
        _rtpReceiver.hashCode ^
        _track.hashCode ^
        _rtpParameters.hashCode ^
        _paused.hashCode ^
        _appData.hashCode ^
        _stream.hashCode ^
        _peerId.hashCode;
  }
}
