import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:mediasoup_client_flutter/src/rtp_parameters.dart';
import 'package:mediasoup_client_flutter/src/common/enhanced_event_emitter.dart';
import 'package:mediasoup_client_flutter/src/common/logger.dart';

// https://mediasoup.org/documentation/v3/mediasoup-client/api/#ProducerCodecOptions
class ProducerCodecOptions {
  final int? opusStereo;
  final int? opusFec;
  final int? opusDtx;
  final int? opusMaxPlaybackRate;
  final int? opusMaxAverageBitrate;
  final int? opusPtime;
  final int? videoGoogleStartBitrate;
  final int? videoGoogleMaxBitrate;
  final int? videoGoogleMinBitrate;

  ProducerCodecOptions({
    this.opusStereo,
    this.opusFec,
    this.opusDtx,
    this.opusMaxPlaybackRate,
    this.opusMaxAverageBitrate,
    this.opusPtime,
    this.videoGoogleStartBitrate,
    this.videoGoogleMaxBitrate,
    this.videoGoogleMinBitrate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (opusStereo != null) 'opusStereo': opusStereo,
      if (opusFec != null) 'opusFec': opusFec,
      if (opusDtx != null) 'opusDtx': opusDtx,
      if (opusMaxPlaybackRate != null)
        'opusMaxPlaybackRate': opusMaxPlaybackRate,
      if (opusMaxAverageBitrate != null)
        'opusMaxAverageBitrate': opusMaxAverageBitrate,
      if (opusPtime != null) 'opusPtime': opusPtime,
      if (videoGoogleStartBitrate != null)
        'videoGoogleStartBitrate': videoGoogleStartBitrate,
      if (videoGoogleMaxBitrate != null)
        'videoGoogleMaxBitrate': videoGoogleMaxBitrate,
      if (videoGoogleMinBitrate != null)
        'videoGoogleMinBitrate': videoGoogleMinBitrate,
    };
  }
}

class ProducerOptions {
  final MediaStreamTrack track;
  final List<RtpEncodingParameters> encodings;
  final ProducerCodecOptions codecOptions;
  final RtpCodecCapability codec;
  final bool stopTracks;
  final bool disableTrackOnPause;
  final bool zeroRtpOnPause;
  final Map<String, dynamic> appData;

  ProducerOptions({
    required this.track,
    required this.encodings,
    required this.codecOptions,
    required this.codec,
    required this.stopTracks,
    required this.disableTrackOnPause,
    required this.zeroRtpOnPause,
    required this.appData,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'track': track,
  //     'encoding': encodings,
  //     'codecOptions': codecOptions,
  //     'codec': codec,
  //     'stopTracks': stopTracks,
  //     'disableTrackOnPause': disableTrackOnPause,
  //     'zeroRtpOnPause': zeroRtpOnPause,
  //     'appData': appData,
  //   };
  // }
}

Logger _logger = Logger('Producer');

class Producer extends EnhancedEventEmitter {
  // Id.
  late String _id;
  // Local id.
  late String _localId;
  // Closed flag.
  late bool _closed;
  // Associated RTCRtpSender.
  RTCRtpSender? _rtpSender;
  // Local track.
  late MediaStreamTrack _track;
  // Producer kind.
  late String _kind;
  // RTP parameters.
  late RtpParameters _rtpParameters;
  // Paused flag.
  late bool _paused;
  // Video max spatial layer.
  late int? _maxSpatialLayer;
  // Whether the Producer should call stop() in given tracks.
  late bool _stopTracks;
  // Whether the Producer should set track.enabled = false when paused.
  late bool _disableTrackOnPause;
  // Whether we should replace the RTCRtpSender.track with null when paused.
  late bool _zeroRtpOnPause;
  // App custom data.
  final Map<String, dynamic> _appData;
  // Observer instance.
  final EnhancedEventEmitter _observer = EnhancedEventEmitter();
  // Stream
  late MediaStream _stream;
  // Source
  late String _source;

  /// @emits transportclose
  /// @emits trackended
  /// @emits @replacetrack - (track: MediaStreamTrack | null)
  /// @emits @setmaxspatiallayer - (spatialLayer: string)
  /// @emits @setrtpencodingparameters - (params: any)
  /// @emits @getstats
  /// @emits @close
  Producer({
    required String id,
    required String localId,
    RTCRtpSender? rtpSender,
    required MediaStreamTrack track,
    required RtpParameters rtpParameters,
    required bool stopTracks,
    required bool disableTrackOnPause,
    required bool zeroRtpOnPause,
    required Map<String, dynamic> appData,
    required MediaStream stream,
    required String source,
  })  : this._appData = appData,
        super() {
    _logger.debug('constructor()');

    _id = id;
    _localId = localId;
    _rtpSender = rtpSender;
    _track = track;
    _kind = track.kind!;
    _rtpParameters = rtpParameters;
    _paused = disableTrackOnPause ? !track.enabled : false;
    _maxSpatialLayer = null;
    _stopTracks = stopTracks;
    _disableTrackOnPause = disableTrackOnPause;
    _zeroRtpOnPause = zeroRtpOnPause;
    _stream = stream;
    _source = source;
    _closed = false;
  }

  /// Producer id.
  String get id => _id;

  /// Local id.
  String get localId => _localId;

  /// Whether the Producer is closed.
  bool get closed => _closed;

  /// Media kind.
  String get kind => _kind;

  /// Associated RTCRtpSender.
  RTCRtpSender? get rtpSender => _rtpSender;

  /// The associated track.
  MediaStreamTrack get track => _track;

  /// RTP parameters.
  RtpParameters get rtpParameters => _rtpParameters;

  /// Whether the Producer is paused.
  bool get paused => _paused;

  /// Max spatial layer.
  ///
  /// @type {int?}
  int? get maxSpatiallayer => _maxSpatialLayer;

  /// App custom data.
  Map<String, dynamic> get appData => _appData;

  /// Observer.
  ///
  /// @emits close
  /// @emits pause
  /// @emits resume
  /// @emits trackended
  EnhancedEventEmitter get observer => _observer;

  /// Stream
  MediaStream get stream => _stream;

  /// Source of stream
  String get source => _source;

  /// Closes the Producer.
  void close() {
    if (_closed) return;

    _logger.debug('close()');

    _closed = true;

    _destroyTrack();

    emit('@close');

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Transport was closed.
  void transportClosed() {
    if (_closed) return;

    _logger.debug('transportClosed()');

    _closed = true;

    _destroyTrack();

    safeEmit('transportclose');

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Get associated RTCRtpSender stats.
  Future<dynamic> getStats() async {
    if (_closed) throw 'closed';

    return safeEmitAsFuture('@getstats');
  }

  /// Pauses sending media.
  void pause() {
    _logger.debug('pause()');

    if (_closed) {
      _logger.error('pause() | Producer closed');

      return;
    }

    _paused = true;

    if (_disableTrackOnPause) {
      _track.enabled = false;
    }

    if (_zeroRtpOnPause) {
      safeEmitAsFuture('@replacetrack').catchError((error, stackTrace) {});
    }

    // Emit observer event.
    _observer.safeEmit('pause');
  }

  /// Resumes sending media.
  void resume() {
    _logger.debug('resume()');

    if (_closed) {
      _logger.error('resume() | Producer closed');

      return;
    }

    _paused = false;

    if (_disableTrackOnPause) {
      _track.enabled = true;
    }

    if (_zeroRtpOnPause) {
      safeEmitAsFuture('@replacetrack', {
        '_track': _track,
      }).catchError((error, stackTrace) {});
    }

    // Emit observer event.
    _observer.safeEmit('resume');
  }

  /// Replaces the current track with a new one.
  Future<void> replaceTrack(MediaStreamTrack track) async {
    _logger.debug('replcaeTrack() ${track.toString()}');

    if (_closed) {
      // Thus must be done here. Otherwise there is no chance to stop the given track.
      if (_stopTracks) {
        try {
          track.stop();
        } catch (error) {}
      }
      throw 'closed';
    }

    // flutter_webrtc, как получить состояние? : )
    // else if (track != null && track.readyState == 'ended'))

    // Do nothing if this is the same track as the current handled one.
    if (track == _track) {
      _logger.debug('replaceTrack() | same track, ignored.');

      return;
    }

    if (_zeroRtpOnPause || _paused) {
      await safeEmitAsFuture('@replacetrack', {
        'track': track,
      });
    }

    // Destroy the previous track.
    _destroyTrack();

    // Set the new track.
    _track = track;

    // If this Producer was paused/resumed and the state of the new
    // track does not match, fix it.
    if (_disableTrackOnPause) {
      if (!_paused) {
        _track.enabled = true;
      } else if (_paused) {
        _track.enabled = false;
      }
    }

    // Handle the effective track.
    _handleTrack();
  }

  /// Sets the video max spatial layer to be sent.
  Future<void> setMaxSpatialLayer(int spatialLayer) async {
    if (_closed)
      throw 'closed';
    else if (_kind != 'video') throw 'not a video Producer';

    if (spatialLayer == _maxSpatialLayer) return;

    await safeEmitAsFuture('@setmaxspatiallayer', {
      'spatialLayer': spatialLayer,
    });

    _maxSpatialLayer = spatialLayer;
  }

  /// Sets the DSCP value.
  Future<void> setRtpEncodingParameters(RtpEncodingParameters params) async {
    if (_closed)
      throw 'closed';
    else if (params == null) throw 'invalid params';

    await safeEmitAsFuture('@setrtpencodingparameters', {
      'params': params,
    });
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

  void _destroyTrack() {
    try {
      _track.onEnded = null;

      if (_stopTracks) {
        _track.stop();
        _stream.dispose();
      }
    } catch (error) {}
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Producer &&
        other._id == _id &&
        other._localId == _localId &&
        other._closed == _closed &&
        other._rtpSender == _rtpSender &&
        other._track == _track &&
        other._kind == _kind &&
        other._rtpParameters == _rtpParameters &&
        other._paused == _paused &&
        other._maxSpatialLayer == _maxSpatialLayer &&
        other._stopTracks == _stopTracks &&
        other._disableTrackOnPause == _disableTrackOnPause &&
        other._zeroRtpOnPause == _zeroRtpOnPause &&
        mapEquals(other._appData, _appData) &&
        other._stream == _stream &&
        other._source == _source;
  }

  @override
  int get hashCode {
    return _id.hashCode ^
        _localId.hashCode ^
        _closed.hashCode ^
        _rtpSender.hashCode ^
        _track.hashCode ^
        _kind.hashCode ^
        _rtpParameters.hashCode ^
        _paused.hashCode ^
        _maxSpatialLayer.hashCode ^
        _stopTracks.hashCode ^
        _disableTrackOnPause.hashCode ^
        _zeroRtpOnPause.hashCode ^
        _appData.hashCode ^
        _stream.hashCode ^
        _source.hashCode;
  }
}
