import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/SdpTransform/SdpTransform.dart';
import 'package:mediasoup_client_flutter/src/Ortc.dart';
import 'package:mediasoup_client_flutter/src/SdpObject.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';
import 'package:mediasoup_client_flutter/src/handlers/HandlerInterface.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/CommonUtils.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/MediaSection.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/PlanBUtils.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/RemoteSdp.dart';
import 'package:mediasoup_client_flutter/src/utils.dart';

Logger logger = Logger('Native');

class Native extends HandlerInterface {
  // Handler direction.
  Direction _direction;
  // Remote SDP handler.
  RemoteSdp _remoteSdp;
  // Generic sending RTP parameters for audio and video.
  Map<RTCRtpMediaType, RtpParameters> _sendingRtpParametersByKind;
  // Generic sending RTP parameters for audio and video suitable for the SDP
  // remote answer.
  Map<RTCRtpMediaType, RtpParameters> _sendingRemoteRtpParametersByKind;
  // RTCPeerConnection instance.
  RTCPeerConnection _pc;
  // Local stream for sending.
  MediaStream _sendStream;
  // Map of sending MediaStreamTracks indexed by localId.
  Map<String, MediaStreamTrack> _mapSendLocalIdTrack =
      <String, MediaStreamTrack>{};
  // Next sending localId.
  int _nextSendLocalId = 0;
  // Map of MID, RTP parameters and RTCRtpReceiver indexed by local id.
  // Value is an Object with mid, rtpParameters and rtpReceiver.
  Map<String, RtpParameters> _mapRecvLocalIdInfo = <String, RtpParameters>{};
  // Whether  a DataChannel m=application section has been created.
  bool _hasDataChannelMediaSection = false;
  // Sending DataChannel id value counter. Increamented for each new DataChannel.
  int _nextSendSctpStreamId = 0;
  // Got transport local and remote parameters.
  bool _transportReady = false;

  Native() : super();

  void _assertSendRirection() {
    if (_direction != Direction.send) {
      throw ('method can just be called for handlers with "send" direction');
    }
  }

  void _assertRecvDirection() {
    if (_direction != Direction.recv) {
      throw ('method can just be called for handlers with "recv" direction');
    }
  }

  Future<void> _setupTransport({
    DtlsRole localDtlsRole,
    SdpObject localSdpObject,
  }) async {
    if (localSdpObject == null) {
      localSdpObject = SdpObject.fromMap(parse((await _pc.getLocalDescription()).sdp));
    }

    // Get our local DTLS parameters.
    DtlsParameters dtlsParameters = CommonUtils.extractDtlsParameters(localSdpObject);

    // Set our DTLS role.
    dtlsParameters.role = localDtlsRole;

    // Update the remote DTLS role in the SDP.
    _remoteSdp.updateDtlsRole(localDtlsRole == DtlsRole.client ? DtlsRole.server : DtlsRole.client);

    // Need to tell the remote transport about our parameters.
    await safeEmitAsFuture('@connect', [dtlsParameters]);

    _transportReady = true;
  }

  @override
  Future<void> close() async {
    logger.debug('close()');

    // Close RTCPeerConnection.
    if (_pc != null) {
      try {
        await _pc.close();
      } catch (error) {}
    }
  }

  @override
  Future<RtpCapabilities> getNativeRtpCapabilities() async {
    logger.debug('getNativeRtpCapabilities()');

    RTCPeerConnection pc = await createPeerConnection({
      'iceServers': [],
      'iceTransportPolicy': 'all',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'plan-b'
    });

    try {
      RTCSessionDescription offer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });

      try {
        await pc.close();
      } catch (error) {}

      SdpObject sdpObject = SdpObject.fromMap(parse(offer.sdp));
      RtpCapabilities nativeRtpCapabilities =
          CommonUtils.extractRtpCapabilities(sdpObject);

      return nativeRtpCapabilities;
    } catch (error) {
      try {
        await pc?.close();
      } catch (error2) {}

      throw error;
    }
  }

  @override
  SctpCapabilities getNativeSctpCapabilities() {
    logger.debug('getNativeSctpCapabilities()');

    return SctpCapabilities(
      numStreams: NumSctpStreams(
        mis: SCTP_NUM_STREAMS.MIS,
        os: SCTP_NUM_STREAMS.OS,
      ),
    );
  }

  @override
  Future<List<StatsReport>> getReceiverStats({String localId}) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<List<StatsReport>> getSenderStats({String localId}) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<List<StatsReport>> getTransportStats() async {
    return await _pc.getStats();
  }

  @override
  String get name => 'Native';

  @override
  Future<HandlerReceiveResult> receive({HandlerReceiveOptions options}) async {
    _assertRecvDirection();

    logger.debug('receive() [trackId:${options.trackId}, kind:${RTCRtpMediaTypeExtension.value(options.kind)}]');

    String localId = options.trackId;
    String mid = RTCRtpMediaTypeExtension.value(options.kind);
    String streamId = options.rtpParameters.rtcp.cname;

    logger.debug(
			'receive() | forcing a random remote streamId to avoid well known bug in native');
    streamId += '-hack-${generateRandomNumber()}';

    _remoteSdp.receive(
      mid: mid,
      kind: options.kind,
      offerRtpParameters: options.rtpParameters,
      streamId: streamId,
      trackId: options.trackId,
    );

    RTCSessionDescription offer = RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

    logger.debug('receive() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

    await _pc.setRemoteDescription(offer);

    RTCSessionDescription answer = await _pc.createAnswer();

    SdpObject localSdpObject = SdpObject.fromMap(parse(answer.sdp));
    MediaObject answerMediaObject = localSdpObject.media.firstWhere((MediaObject m) => m.mid == mid, orElse: () => null,);

    // May need to modify codec parameters in the answer based on codec
    // parameters in the offer.
    CommonUtils.applyCodecParameters(options.rtpParameters, answerMediaObject);

    answer = RTCSessionDescription(write(localSdpObject.toMap(), null), 'answer');

    if (!_transportReady) {
      await _setupTransport(localDtlsRole: DtlsRole.client, localSdpObject: localSdpObject);
    }

    logger.debug('receive() | calling pc.setLocalDescription() [answer:${answer.toMap()}]');

    await _pc.setLocalDescription(answer);

    MediaStream stream = _pc.getRemoteStreams().firstWhere((MediaStream s) => s.id == streamId, orElse: () => null,);
    MediaStreamTrack track = stream.getTrackById(localId);

    if (track == null) {
      throw('remote track not found');
    }

    _mapRecvLocalIdInfo[localId] = RtpParameters.copy(options.rtpParameters, mid: mid);

    return HandlerReceiveResult(localId: localId, track: track);
  }

  @override
  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
      HandlerReceiveDataChannelOptions options) async {
    _assertRecvDirection();

    RTCDataChannelInit initOptions = RTCDataChannelInit();
    initOptions.negotiated = true;
    initOptions.id = options.sctpStreamParameters.streamId;
    initOptions.ordered = options.sctpStreamParameters.ordered;
    initOptions.maxRetransmitTime = options.sctpStreamParameters.maxPacketLifeTime;
    initOptions.maxRetransmits = options.sctpStreamParameters.maxRetransmits;
    initOptions.protocol = options.protocol;

    logger.debug('receiveDataChannel() [options:${initOptions.toMap()}]');

    RTCDataChannel dataChannel = await _pc.createDataChannel(options.label, initOptions);

    // If this is the first DataChannel we need to create the SDP offer with
    // m=application section.
    
    if (!_hasDataChannelMediaSection) {
      _remoteSdp.receiveSctpAssociation(oldDataChannelSpec: true);

      RTCSessionDescription offer = RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

      logger.debug('receiveDataChannel() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

      await _pc.setRemoteDescription(offer);

      RTCSessionDescription answer = await _pc.createAnswer();

      if (!_transportReady) {
        SdpObject localSdpObject = SdpObject.fromMap(parse(answer.sdp));

        await _setupTransport(localDtlsRole: DtlsRole.client, localSdpObject: localSdpObject);
      }

      logger.debug('receiveDataChannel() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

      await _pc.setLocalDescription(answer);

      _hasDataChannelMediaSection = true;
    }

    return HandlerReceiveDataChannelResult(dataChannel: dataChannel);
  }

  @override
  Future<void> replaceTrack({String localId, MediaStreamTrack track}) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<void> restartIce({IceParameters iceParameters}) async {
    logger.debug('restartIce()');

    if (!_transportReady) {
      return null;
    }

    if (_direction == Direction.send) {
      RTCSessionDescription offer = await _pc.createOffer({ 'iceRestart': true});

      logger.debug('restartIce() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

      await _pc.setLocalDescription(offer);

      RTCSessionDescription answer = RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

      logger.debug('restartIce() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

      await _pc.setRemoteDescription(answer);
    } else {
      RTCSessionDescription offer = RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

      logger.debug('restartIce() | calling pc.setRemoteDescription() [offer:${offer.sdp}]');

      await _pc.setRemoteDescription(offer);

      RTCSessionDescription answer = await _pc.createAnswer();

      logger.debug('restartIce() | calling pc.setLocalDescription() [answer:${answer.toMap()}]');

      await _pc.setLocalDescription(answer);
    }
  }


  @override
  void run({HandlerRunOptions options}) async {
    logger.debug('run()');

    _direction = options.direction;

    _remoteSdp = RemoteSdp(
      iceParameters: options.iceParameters,
      iceCandidates: options.iceCandidates,
      dtlsParameters: options.dtlsParameters,
      sctpParameters: options.sctpParameters,
      planB: true,
    );

    _sendingRtpParametersByKind = {
      RTCRtpMediaType.RTCRtpMediaTypeAudio: Ortc.getSendingRtpParameters(RTCRtpMediaType.RTCRtpMediaTypeAudio, options.extendedRtpCapabilities),
      RTCRtpMediaType.RTCRtpMediaTypeVideo: Ortc.getSendingRtpParameters(RTCRtpMediaType.RTCRtpMediaTypeVideo, options.extendedRtpCapabilities),
    };

    _sendingRemoteRtpParametersByKind = {
      RTCRtpMediaType.RTCRtpMediaTypeAudio: Ortc.getSendingRemoteRtpParameters(RTCRtpMediaType.RTCRtpMediaTypeAudio, options.extendedRtpCapabilities),
      RTCRtpMediaType.RTCRtpMediaTypeVideo: Ortc.getSendingRemoteRtpParameters(RTCRtpMediaType.RTCRtpMediaTypeVideo, options.extendedRtpCapabilities),
    };

    _pc = await createPeerConnection({
        'iceServers'         : options.iceServer != null ? [options.iceServer.toMap()] : [],
				'iceTransportPolicy' : options.iceTransportPolicy != null ? options.iceTransportPolicy.value : 'all',
				'bundlePolicy'       : 'max-bundle',
				'rtcpMuxPolicy'      : 'require',
				'sdpSemantics'       : 'plan-b',
				...options.additionalSettings,
    }, options.proprietaryConstraints);

    // Handle RTCPeerConnection connection status.
    _pc.onIceConnectionState = (RTCIceConnectionState state) {
      switch (_pc.iceConnectionState) {
        case RTCIceConnectionState.RTCIceConnectionStateChecking: {
          emit('@connectionstatechange', ['connecting']);
          break;
        }
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted: {
          emit('@connectionstatechange', ['connected']);
          break;
        }
        case RTCIceConnectionState.RTCIceConnectionStateFailed: {
          emit('@connectionstatechange', ['failed']);
          break;
        }
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected: {
          emit('@connectionstatechange', ['disconnected']);
          break;
        }
        case RTCIceConnectionState.RTCIceConnectionStateClosed: {
          emit('@connectionstatechange', ['closed']);
          break;
        }

        default: break;
      }
    };
  }

  @override
  Future<HandlerSendResult> send({HandlerSendOptions options}) async {
    _assertSendRirection();

    logger.debug('send() [kind:${options.track.kind}, track.id:${options.track.id}]');

    _sendStream.addTrack(options.track);
    _pc.addStream(_sendStream);

    RTCSessionDescription offer = await _pc.createOffer();
    SdpObject localSdpObject = SdpObject.fromMap(parse(offer.sdp));
    MediaObject offerMediaObject;
    RtpParameters sendingRtpParameters = RtpParameters.copy(_sendingRtpParametersByKind[options.track.kind]);

    sendingRtpParameters.codecs = Ortc.reduceCodecs(sendingRtpParameters.codecs, null);

    RtpParameters sendingRemoteRtpParameters = RtpParameters.copy(_sendingRemoteRtpParametersByKind[options.track.kind]);

    sendingRemoteRtpParameters.codecs = Ortc.reduceCodecs(sendingRemoteRtpParameters.codecs, null);

    if (!_transportReady) {
      await _setupTransport(localDtlsRole: DtlsRole.server, localSdpObject: localSdpObject);
    }

    if (options.track.kind == 'video' && options.encodings != null && options.encodings.length > 1) {
      logger.debug('send() | enabling simulcast');

      localSdpObject = SdpObject.fromMap(parse(offer.sdp));
      offerMediaObject = localSdpObject.media.firstWhere((MediaObject m) => m.type == 'video', orElse: () => null,);

      PlanBUtils.addLegacySimulcast(offerMediaObject, options.track, options.encodings.length);

      offer = RTCSessionDescription(write(localSdpObject.toMap(), null), 'offer');
    }

    logger.debug('send() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

    await _pc.setLocalDescription(offer);

    localSdpObject = SdpObject.fromMap(parse((await _pc.getLocalDescription()).sdp));
    offerMediaObject = localSdpObject.media.firstWhere((MediaObject m) => m.type == options.track.kind, orElse: () => null,);

    // Set RTCP CNAME.
    sendingRtpParameters.rtcp.cname = CommonUtils.getCname(offerMediaObject);

    // Set RTP encodings.
    sendingRtpParameters.encodings = PlanBUtils.getRtpEncodings(offerMediaObject, options.track);

    // Complete encodings with given values.
    if (options.encodings != null) {
      for (int idx = 0; idx < sendingRtpParameters.encodings.length; ++idx) {
        if (options.encodings[idx] != null) {
          sendingRtpParameters.encodings[idx] = RtpEncodingParameters.assign(sendingRtpParameters.encodings[idx], options.encodings[idx]);
        }
      }
    }

    // If VP8 or H264 and there is effective simulcast, add scalabilityMode to
    // each encoding.
    
    if (sendingRtpParameters.encodings.length > 1 &&
      (
        sendingRtpParameters.codecs[0].mimeType.toLowerCase() == 'video/vp8' ||
        sendingRtpParameters.codecs[0].mimeType.toLowerCase() == 'video/h264'
      )
    ) {
      for (RtpEncodingParameters encoding in sendingRtpParameters.encodings) {
        encoding.scalabilityMode = 'S1T3';
      }
    }

    _remoteSdp.send(
      offerMediaObject: offerMediaObject,
      offerRtpParameters: sendingRtpParameters,
      answerRtpParameters: sendingRemoteRtpParameters,
      codecOptions: options.codecOptions,
    );

    RTCSessionDescription answer = RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

    logger.debug('send() | calling pc.setRemoteDescription() [answer:${answer.toMap()}');

    await _pc.setRemoteDescription(answer);

    String localId = _nextSendLocalId.toString();
    _nextSendLocalId++;

    // Insert into the map.
    _mapSendLocalIdTrack[localId] = options.track;

    return HandlerSendResult(localId: localId, rtpParameters: sendingRtpParameters,);
  }

  @override
  Future<HandlerSendDataChannelResult> sendDataChannel(
      {SctpStreamParameters options}) async {
    _assertSendRirection();

    RTCDataChannelInit initOptions = RTCDataChannelInit();
    initOptions.negotiated = true;
    initOptions.id = _nextSendSctpStreamId;
    initOptions.ordered = options.ordered;
    initOptions.maxRetransmitTime = options.maxPacketLifeTime;
    initOptions.maxRetransmits = options.maxRetransmits;
    initOptions.protocol = options.protocol;
    // initOptions.priority = options.priority;
    
    logger.debug('sendDataChannel() [options:${initOptions.toMap()}]');

    RTCDataChannel dataChannel = await _pc.createDataChannel(options.label, initOptions);

    // Increase next id.
    _nextSendSctpStreamId = ++ _nextSendSctpStreamId % SCTP_NUM_STREAMS.MIS;

    // If this is the first DataChannel we need to create the SDP answer with
    // m=application section.
    if (!_hasDataChannelMediaSection) {
      RTCSessionDescription offer = await _pc.createOffer();
      SdpObject localSdpObject = SdpObject.fromMap(parse(offer.sdp));
      MediaObject offerMediaObject = localSdpObject.media.firstWhere((MediaObject m) => m.type == 'application', orElse: () => null,);

      if (!_transportReady) {
        await _setupTransport(localDtlsRole: DtlsRole.server, localSdpObject: localSdpObject);
      }

      logger.debug('sendDataChannel() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

      await _pc.setLocalDescription(offer);

      _remoteSdp.sendSctpAssociation(offerMediaObject);

      RTCSessionDescription answer = RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

      logger.debug('sendDataChannel() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

			await _pc.setRemoteDescription(answer);

			_hasDataChannelMediaSection = true;
    }

    SctpStreamParameters sctpStreamParameters = SctpStreamParameters(
      streamId: initOptions.id,
      ordered: initOptions.ordered,
      maxPacketLifeTime: initOptions.maxRetransmitTime,
      maxRetransmits: initOptions.maxRetransmits,
    );

    return HandlerSendDataChannelResult(dataChannel: dataChannel, sctpStreamParameters: sctpStreamParameters,);
  }

  @override
  Future<void> setMaxSpatialLayer({String localId, int spatialLayer}) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<void> setRtpEncodingParameters(
      {String localId, RtpEncodingParameters params}) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<void> stopReceiving({String localId}) async {
    _assertRecvDirection();

    logger.debug('stopReceiving() [localId:$localId]');

    RtpParameters rtpParameters = _mapRecvLocalIdInfo[localId];

    // Remote from the map.
    _mapRecvLocalIdInfo.remove(localId);

    _remoteSdp.planBStopReceiving(rtpParameters.mid, rtpParameters);

    RTCSessionDescription offer = RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

    logger.debug('stopReceiving() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

    await _pc.setRemoteDescription(offer);
  }

  @override
  Future<void> stopSending({String localId}) async {
    _assertSendRirection();

    logger.debug('stopSending() [localId:$localId]');

    MediaStreamTrack track = _mapSendLocalIdTrack[localId];

    if (track == null) {
      throw ('track not found');
    }

    _mapSendLocalIdTrack.remove(localId);
    await _sendStream.removeTrack(track);
    await  _pc.addStream(_sendStream);
    
    RTCSessionDescription offer = await _pc.createOffer();

    logger.debug('stopSending() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

    try {
      await _pc.setLocalDescription(offer);
    } catch (error) {
      // NOTE: If there are no sending tracks, setLocalDescription() will fail with
			// "Failed to create channels". If so, ignore it.
			if (_sendStream.getTracks().length == 0)
			{
				logger.warn('stopSending() | ignoring expected error due no sending tracks: ${error.toString()}',);

				return;
			}

			throw error;
    }

    if (_pc.signalingState == RTCSignalingState.RTCSignalingStateStable) {
      return;
    }

    RTCSessionDescription answer = RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

    logger.debug('stopSending() | calling pc.setRemoteDescription() [answer:[${answer.toMap()}]');

    await _pc.setRemoteDescription(answer);
  }

  @override
  Future<void> updateIceServers({List<RTCIceServer> iceServers}) async {
    logger.debug('updateIceServers()');

    Map<String, dynamic> configuration = _pc.getConfiguration;

    configuration['iceServers'] = iceServers.map((RTCIceServer ice) => ice.toMap()).toList();

    await _pc.setConfiguration(configuration);
  }
}
