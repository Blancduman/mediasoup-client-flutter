import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';

Logger _logger = Logger('Consumer');

class ConsumerOptions {
  String id;
  String producerId;
  RTCRtpMediaType kind;
  RtpParameters rtpParameters;
}

typedef void ConsumerOnTrackEnded();

class Consumer extends EnhancedEventEmitter {
  /// Id.
  String _id;
  /// Local id.
  String _localId;
  /// Associated Producer id.
  String _producerId;
  /// Closed flag.
  bool _closed = false;
  /// Associated RTCRtpReceiver.
  RTCRtpReceiver _rtpReceiver;
  /// Remote track.
  MediaStreamTrack _track;
  /// RTP parameters.
  RtpParameters _rtpParameters;
  /// Paused flag.
  bool _paused;
  /// App custom data.
  final Map<String, dynamic> _appData;
  /// Stream.
  MediaStream _stream;
  /// Observer instance.
  EnhancedEventEmitter _observer = EnhancedEventEmitter();

  /// @emits transportclose
  /// @emits trackended
  /// @emits @getstats
  /// @emits @close
  Consumer({
    String id,
    String localId,
    String producerId,
    RTCRtpReceiver rtpReceiver,
    MediaStreamTrack track,
    RtpParameters rtpParameters,
    Map<String, dynamic> appData,
    MediaStream stream,
  }) : this._appData = appData, super() {
    _logger.debug('constructor()');

    _id = id;
    _localId = localId;
    _producerId = producerId;
    _rtpReceiver = rtpReceiver;
    _track = track;
    _rtpParameters = rtpParameters;
    _paused = !track.enabled;
    _stream = stream;
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
  String get kind => _track.kind;
  /// Associated RTCRtpReceiver.
  RTCRtpReceiver get rtpReceiver => _rtpReceiver;
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
    if (_closed)
      throw 'Closed';
    
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
}
