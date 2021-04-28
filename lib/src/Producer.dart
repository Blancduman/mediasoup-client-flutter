import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';
import 'package:mediasoup_client_flutter/src/common/EnhancedEventEmitter.dart';

// https://mediasoup.org/documentation/v3/mediasoup-client/api/#ProducerCodecOptions
class ProducerCodecOptions {
  int opusStereo;
  int opusFec;
  int opusDtx;
  int opusMaxPlaybackRate;
  int opusMaxAverageBitrate;
  int opusPtime;
  int videoGoogleStartBitrate;
  int videoGoogleMaxBitrate;
  int videoGoogleMinBitrate;

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
      if (opusStereo != null)
      'opusStereo': opusStereo,
      if (opusFec != null)
      'opusFec': opusFec,
      if (opusDtx != null)
      'opusDtx': opusDtx,
      if (opusMaxPlaybackRate != null)
      'opusMaxPlaybackRate': opusMaxPlaybackRate,
      if (opusMaxAverageBitrate != null)
      'opusMaxAverageBitrate': opusMaxAverageBitrate,
      if (opusPtime != null)
      'opusPtime': opusPtime,
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
  MediaStreamTrack track;
  List<RtpEncodingParameters> encodings;
  ProducerCodecOptions codecOptions;
  RtpCodecCapability codec;
  bool stopTracks;
  bool disableTrackOnPause;
  bool zeroRtpOnPause;
  Map<String, dynamic> appData;

  ProducerOptions({
    this.track,
    this.encodings,
    this.codecOptions,
    this.codec,
    this.stopTracks,
    this.disableTrackOnPause,
    this.zeroRtpOnPause,
    this.appData,
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
  String _id;
  // Local id.
  String _localId;
  // Closed flag.
  bool _closed;
  // Associated RTCRtpSender.
  RTCRtpSender _rtpSender;
  // Local track.
  MediaStreamTrack _track;
  // Producer kind.
  String _kind;
  // RTP parameters.
  RtpParameters _rtpParameters;
  // Paused flag.
  bool _paused;
  // Video max spatial layer.
  int _maxSpatialLayer;
  // Whether the Producer should call stop() in given tracks.
  bool _stopTracks;
  // Whether the Producer should set track.enabled = false when paused.
  bool _disableTrackOnPause;
  // Whether we should replace the RTCRtpSender.track with null when paused.
  bool _zeroRtpOnPause;
  // App custom data.
  final Map<String, dynamic> _appData;
  // Observer instance.
  EnhancedEventEmitter _observer = EnhancedEventEmitter();
  // Stream
  MediaStream _stream;
  // Source
  String _source;

	/// @emits transportclose
	/// @emits trackended
	/// @emits @replacetrack - (track: MediaStreamTrack | null)
	/// @emits @setmaxspatiallayer - (spatialLayer: string)
	/// @emits @setrtpencodingparameters - (params: any)
	/// @emits @getstats
	/// @emits @close
  Producer({
    String id,
    String localId,
    RTCRtpSender rtpSender,
    MediaStreamTrack track,
    RtpParameters rtpParameters,
    bool stopTracks,
    bool disableTrackOnPause,
    bool zeroRtpOnPause,
    Map<String, dynamic> appData,
    MediaStream stream,
    String source,
  }) : this._appData = appData, super() {
    _logger.debug('constructor()');

    _id = id;
    _localId = localId;
    _rtpSender = rtpSender;
    _track = track;
    _kind = track.kind;
    _rtpParameters = rtpParameters;
    _paused = disableTrackOnPause ? !track.enabled : false;
    _maxSpatialLayer = null;
    _stopTracks = stopTracks;
    _disableTrackOnPause = disableTrackOnPause;
    _zeroRtpOnPause = zeroRtpOnPause;
    _stream = stream;
    _source = source;
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
  RTCRtpSender get rtpSender => _rtpSender;
  /// The associated track.
  MediaStreamTrack get track => _track;
  /// RTP parameters.
  RtpParameters get rtpParameters => _rtpParameters;
  /// Whether the Producer is paused.
  bool get paused => _paused;
  /// Max spatial layer.
  /// 
  /// @type {int}
  int get maxSpatiallayer => _maxSpatialLayer;
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

    _destoryTrack();

    emit('@close');

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /// Transport was closed.
  void transportClosed() {
    if (_closed) return;

    _logger.debug('transportClosed()');

    _closed = true;

    _destoryTrack();

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

    if (_track != null && _disableTrackOnPause) {
      _track.enabled = false;
    }

    if (_zeroRtpOnPause) {
      safeEmitAsFuture('@replacetrack').catchError(() {});
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

     if (_track != null && _disableTrackOnPause) {
       _track.enabled = true;
     }

     if (_zeroRtpOnPause) {
       safeEmitAsFuture('@replacetrack', {
         '_track': _track,
       }).catchError((){});
     }

     // Emit observer event.
     _observer.safeEmit('resume');
   }

  /// Replaces the current track with a new one.
  Future<void> replaceTrack(MediaStreamTrack track) async {
    _logger.debug('replcaeTrack() ${track.toString()}');

    if (_closed) {
      // Thus must be done here. Otherwise there is no chance to stop the given track.
      if (track != null && _stopTracks) {
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
    _destoryTrack();

    // Set the new track.
    _track = track;
    
    // If this Producer was paused/resumed and the state of the new
    // track does not match, fix it.
    if (_track != null && _disableTrackOnPause) {
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
    if (_closed) throw 'closed';
    else if (_kind != 'video')
      throw 'not a video Producer';
    
    if (spatialLayer == _maxSpatialLayer)
      return;

      await safeEmitAsFuture('@setmaxspatiallayer', {
        'spatialLayer': spatialLayer,
      });

      _maxSpatialLayer = spatialLayer;
  }

  /// Sets the DSCP value.
  Future<void> setRtpEncodingParameters(RtpEncodingParameters params) async {
    if (_closed) throw 'closed';
    else if (params == null)
      throw 'invalid params';

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
    if (_track == null) return;

    _track.onEnded = _onTrackEnded;
  }

  void _destoryTrack() {
    if (_track == null) return;

    try {
      _track.onEnded = null;

      if (_stopTracks) {
        _track.stop();
      }
    } catch (error) {}
  }
}