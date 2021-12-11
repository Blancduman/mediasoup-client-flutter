import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:mediasoup_client_flutter/src/common/enhanced_event_emitter.dart';
import 'package:mediasoup_client_flutter/src/common/logger.dart';
import 'package:mediasoup_client_flutter/src/rtp_parameters.dart';

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
  final String id;

  /// Local id.
  final String localId;

  /// Associated Producer id.
  final String producerId;

  /// Closed flag.
  bool closed;

  /// Associated RTCRtpReceiver.
  RTCRtpReceiver? rtpReceiver;

  /// Remote track.
  final MediaStreamTrack track;

  /// RTP parameters.
  final RtpParameters rtpParameters;

  /// Paused flag.
  late bool paused;

  /// App custom data.
  final Map<String, dynamic> appData;

  /// Stream.
  final MediaStream stream;

  /// Observer instance.
  ///
  /// @emits close
  /// @emits pause
  /// @emits resume
  /// @emits trackended
  final EnhancedEventEmitter observer;

  /// Peer id.
  String? peerId;

  String? get kind => track.kind;

  /// @emits transportclose
  /// @emits trackended
  /// @emits @getstats
  /// @emits @close
  Consumer({
    required this.id,
    required this.localId,
    required this.producerId,
    this.rtpReceiver,
    required this.track,
    required this.rtpParameters,
    required this.appData,
    required this.stream,
    this.peerId,
    this.closed = false,
  })  : observer = EnhancedEventEmitter(),
        super() {
    _logger.debug('constructor()');

    paused = !track.enabled;
    _handleTrack();
  }

  Consumer._copy({
    required this.id,
    required this.localId,
    required this.producerId,
    this.rtpReceiver,
    required this.track,
    required this.rtpParameters,
    required this.appData,
    required this.stream,
    required this.peerId,
    required this.closed,
    required this.paused,
    required this.observer,
  }) : super() {
    _logger.debug('copy()');
    _handleTrack();
  }

  /// Closes the Consumer.
  Future<void> close() async {
    if (closed) return;

    _logger.debug('close()');

    closed = true;
    await _destroyTrack();
    emit('@close');
    // Emit observer event.
    observer.safeEmit('close');
  }

  /// Closes the Consumer and return new Instance of same Consumer.
  Future<Consumer> closeCopy() async {
    if (closed) return this;

    _logger.debug('closeCopy()');

    // closed = true;
    await _destroyTrack();
    emit('@close');
    // Emit observer event.
    observer.safeEmit('close');

    return copyWith(closed: true);
  }

  /// Transport was closed.
  Future<void> transportClosed() async {
    if (closed) return;
    _logger.debug('transportClosed()');
    closed = true;
    await _destroyTrack();
    safeEmit('transportclose');
    // Emit observer event.
    observer.safeEmit('close');
  }

  /// Get associated RTCRtpReceiver stats.
  Future<dynamic> getStats() async {
    if (closed) throw 'Closed';

    return safeEmitAsFuture('@getstats');
  }

  /// Pauses receiving media.
  void pause() {
    _logger.debug('pause()');

    if (closed) {
      _logger.error('pause() | Consumer closed');
      return;
    }

    paused = true;
    track.enabled = false;

    // Emit observer event.
    observer.safeEmit('pause');
  }

  /// Pauses receiving media and return new Instance of same Consumer.
  Consumer pauseCopy() {
    _logger.debug('pauseCopy()');

    if (closed) {
      _logger.error('pauseCopy() | Consumer closed');
      return this;
    }

    // paused = true;
    track.enabled = false;

    // Emit observer event.
    observer.safeEmit('pause');

    return copyWith(paused: true);
  }

  /// Resumes receiving media.
  void resume() {
    _logger.debug('resume()');

    if (closed) {
      _logger.error('resume() | Consumer closed.');

      return;
    }

    paused = false;
    track.enabled = true;

    // Emit observer event.
    observer.safeEmit('resume');
  }

  /// Resumes receiving media and return new Instance of same Consumer.
  Consumer resumeCopy() {
    _logger.debug('resumeCopy()');

    if (closed) {
      _logger.error('resumeCopy() | Consumer closed.');

      return this;
    }

    // paused = false;
    track.enabled = true;

    // Emit observer event.
    observer.safeEmit('resume');

    return copyWith(paused: false);
  }

  void _onTrackEnded() {
    _logger.debug('track "ended" event');

    safeEmit('trackended');
    // Emit observer event.
    observer.safeEmit('trackended');
  }

  void _handleTrack() {
    track.onEnded = _onTrackEnded;
  }

  Future<void> _destroyTrack() async {
    try {
      track.onEnded = null;
      await track.stop();
    } catch (error) {}
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Consumer &&
        other.id == id &&
        other.localId == localId &&
        other.producerId == producerId &&
        other.closed == closed &&
        other.rtpReceiver == rtpReceiver &&
        other.track == track &&
        other.rtpParameters == rtpParameters &&
        other.paused == paused &&
        mapEquals(other.appData, appData) &&
        other.stream == stream &&
        other.peerId == peerId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        localId.hashCode ^
        producerId.hashCode ^
        closed.hashCode ^
        rtpReceiver.hashCode ^
        track.hashCode ^
        rtpParameters.hashCode ^
        paused.hashCode ^
        appData.hashCode ^
        stream.hashCode ^
        peerId.hashCode;
  }

  Consumer copyWith({
    String? id,
    String? localId,
    String? producerId,
    bool? closed,
    RTCRtpReceiver? rtpReceiver,
    MediaStreamTrack? track,
    RtpParameters? rtpParameters,
    bool? paused,
    Map<String, dynamic>? appData,
    MediaStream? stream,
    EnhancedEventEmitter? observer,
    String? peerId,
  }) {
    return Consumer._copy(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      producerId: producerId ?? this.producerId,
      closed: closed ?? this.closed,
      rtpReceiver: rtpReceiver ?? this.rtpReceiver,
      track: track ?? this.track,
      rtpParameters: rtpParameters ?? this.rtpParameters,
      paused: paused ?? this.paused,
      appData: appData ?? this.appData,
      stream: stream ?? this.stream,
      observer: observer ?? this.observer,
      peerId: peerId ?? this.peerId,
    );
  }
}
