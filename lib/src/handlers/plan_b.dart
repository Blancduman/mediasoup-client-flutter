import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:mediasoup_client_flutter/src/ortc.dart';
import 'package:mediasoup_client_flutter/src/sdp_object.dart';
import 'package:mediasoup_client_flutter/src/transport.dart';
import 'package:mediasoup_client_flutter/src/sctp_parameters.dart';
import 'package:mediasoup_client_flutter/src/rtp_parameters.dart';
import 'package:mediasoup_client_flutter/src/common/logger.dart';
import 'package:mediasoup_client_flutter/src/handlers/handler_interface.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/common_utils.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/media_section.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/plan_b_utils.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/remote_sdp.dart';
import 'package:mediasoup_client_flutter/src/utils.dart';

Logger _logger = Logger('Plan B handler');

class PlanB extends HandlerInterface {
  // Handler direction.
  late Direction _direction;
  // Remote SDP handler.
  late RemoteSdp _remoteSdp;
  // Generic sending RTP parameters for audio and video.
  late Map<RTCRtpMediaType, RtpParameters> _sendingRtpParametersByKind;
  // Generic sending RTP parameters for audio and video suitable for the SDP
  // remote answer.
  late Map<RTCRtpMediaType, RtpParameters> _sendingRemoteRtpParametersByKind;
  // RTCPeerConnection instance.
  RTCPeerConnection? _pc;
  // // Local stream for sending.
  // MediaStream _sendStream;
  // Map of sending MediaStreamTracks indexed by localId.
  Map<String, MediaStreamTrack> _mapSendLocalIdTrack =
      <String, MediaStreamTrack>{};
  // Next sending localId.
  int _nextSendLocalId = 0;
  // Map of MID, RTP parameters and RTCRtpReceiver indexed by local id.
  // Value is an Object with mid, rtpParameters and rtpReceiver.
  Map<String, Map<String, dynamic>> _mapRecvLocalIdInfo =
      <String, Map<String, dynamic>>{};
  // Whether  a DataChannel m=application section has been created.
  bool _hasDataChannelMediaSection = false;
  // Sending DataChannel id value counter. Increamented for each new DataChannel.
  int _nextSendSctpStreamId = 0;
  // Got transport local and remote parameters.
  bool _transportReady = false;

  PlanB() : super();

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
    required DtlsRole localDtlsRole,
    SdpObject? localSdpObject,
  }) async {
    if (localSdpObject == null) {
      localSdpObject =
          SdpObject.fromMap(parse((await _pc!.getLocalDescription())!.sdp!));
    }

    // Get our local DTLS parameters.
    DtlsParameters dtlsParameters =
        CommonUtils.extractDtlsParameters(localSdpObject);

    // Set our DTLS role.
    dtlsParameters.role = localDtlsRole;

    // Update the remote DTLS role in the SDP.
    _remoteSdp.updateDtlsRole(
        localDtlsRole == DtlsRole.client ? DtlsRole.server : DtlsRole.client);

    // Need to tell the remote transport about our parameters.
    await safeEmitAsFuture('@connect', {
      'dtlsParameters': dtlsParameters,
    });

    _transportReady = true;
  }

  @override
  Future<void> close() async {
    _logger.debug('close()');

    // Close RTCPeerConnection.
    if (_pc != null) {
      try {
        await _pc!.close();
      } catch (error) {}
    }
  }

  @override
  Future<RtpCapabilities> getNativeRtpCapabilities() async {
    _logger.debug('getNativeRtpCapabilities()');

    final Map<String, dynamic> config = {
      'iceServers': [
        {"url": "stun:stun.l.google.com:19302"},
      ],
      'iceTransportPolicy': 'all',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'plan-b',
      'startAudioSession': false
    };

    final Map<String, dynamic> constraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    RTCPeerConnection pc = await createPeerConnection(config, constraints);

    try {
      RTCSessionDescription offer = await pc.createOffer(constraints);

      try {
        await pc.close();
        // pc?.dispose();
      } catch (error) {}

      SdpObject sdpObject = SdpObject.fromMap(parse(offer.sdp!));
      RtpCapabilities nativeRtpCapabilities =
          CommonUtils.extractRtpCapabilities(sdpObject);

      return nativeRtpCapabilities;
    } catch (error) {
      try {
        await pc.close();
        // pc?.dispose();
      } catch (error2) {}

      throw error;
    }
  }

  @override
  SctpCapabilities getNativeSctpCapabilities() {
    _logger.debug('getNativeSctpCapabilities()');

    return SctpCapabilities(
      numStreams: NumSctpStreams(
        mis: SCTP_NUM_STREAMS.MIS,
        os: SCTP_NUM_STREAMS.OS,
      ),
    );
  }

  @override
  Future<List<StatsReport>> getReceiverStats(String localId) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<List<StatsReport>> getSenderStats(String localId) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<List<StatsReport>> getTransportStats() async {
    return await _pc!.getStats();
  }

  @override
  String get name => 'Plan B handler';

  @override
  Future<HandlerReceiveResult> receive(HandlerReceiveOptions options) async {
    _assertRecvDirection();

    _logger.debug(
        'receive() [trackId:${options.trackId}, kind:${RTCRtpMediaTypeExtension.value(options.kind)}]');

    String localId = options.trackId;
    String mid = RTCRtpMediaTypeExtension.value(options.kind);
    String streamId = options.rtpParameters.rtcp!.cname;

    _logger.debug(
        'receive() | forcing a random remote streamId to avoid well known bug in native');
    streamId += '-hack-${generateRandomNumber()}';

    _remoteSdp.receive(
      mid: mid,
      kind: options.kind,
      offerRtpParameters: options.rtpParameters,
      streamId: streamId,
      trackId: options.trackId,
    );

    RTCSessionDescription offer =
        RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

    _logger.debug(
        'receive() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

    await _pc!.setRemoteDescription(offer);

    RTCSessionDescription answer = await _pc!.createAnswer();

    SdpObject localSdpObject = SdpObject.fromMap(parse(answer.sdp!));
    MediaObject? answerMediaObject = localSdpObject.media.firstWhere(
      (MediaObject m) => m.mid == mid,
      orElse: () => null as MediaObject,
    );

    // May need to modify codec parameters in the answer based on codec
    // parameters in the offer.
    CommonUtils.applyCodecParameters(options.rtpParameters, answerMediaObject);

    answer =
        RTCSessionDescription(write(localSdpObject.toMap(), null), 'answer');

    if (!_transportReady) {
      await _setupTransport(
          localDtlsRole: DtlsRole.client, localSdpObject: localSdpObject);
    }

    _logger.debug(
        'receive() | calling pc.setLocalDescription() [answer:${answer.toMap()}]');

    await _pc!.setLocalDescription(answer);

    MediaStream? stream = (_pc!
            .getRemoteStreams()
            .where((s) => s != null)
            .toList() as List<MediaStream>)
        .firstWhere(
      (MediaStream s) => s.id == streamId,
      orElse: () => null as MediaStream,
    );
    MediaStreamTrack? track = stream.getTrackById(localId);

    if (track == null) {
      throw ('remote track not found');
    }

    _mapRecvLocalIdInfo[localId] = {
      'mid': mid,
      'rtpParameters': options.rtpParameters,
    };

    return HandlerReceiveResult(localId: localId, track: track, stream: stream);
  }

  @override
  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
      HandlerReceiveDataChannelOptions options) async {
    _assertRecvDirection();

    RTCDataChannelInit initOptions = RTCDataChannelInit();
    initOptions.negotiated = true;
    initOptions.id = options.sctpStreamParameters.streamId;
    initOptions.ordered =
        options.sctpStreamParameters.ordered ?? initOptions.ordered;
    initOptions.maxRetransmitTime =
        options.sctpStreamParameters.maxPacketLifeTime ??
            initOptions.maxRetransmitTime;
    initOptions.maxRetransmits = options.sctpStreamParameters.maxRetransmits ??
        initOptions.maxRetransmits;
    initOptions.protocol = options.protocol;

    _logger.debug('receiveDataChannel() [options:${initOptions.toMap()}]');

    RTCDataChannel dataChannel =
        await _pc!.createDataChannel(options.label, initOptions);

    // If this is the first DataChannel we need to create the SDP offer with
    // m=application section.

    if (!_hasDataChannelMediaSection) {
      _remoteSdp.receiveSctpAssociation(oldDataChannelSpec: true);

      RTCSessionDescription offer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

      _logger.debug(
          'receiveDataChannel() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

      await _pc!.setRemoteDescription(offer);

      RTCSessionDescription answer = await _pc!.createAnswer();

      if (!_transportReady) {
        SdpObject localSdpObject = SdpObject.fromMap(parse(answer.sdp!));

        await _setupTransport(
            localDtlsRole: DtlsRole.client, localSdpObject: localSdpObject);
      }

      _logger.debug(
          'receiveDataChannel() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

      await _pc!.setLocalDescription(answer);

      _hasDataChannelMediaSection = true;
    }

    return HandlerReceiveDataChannelResult(dataChannel: dataChannel);
  }

  @override
  Future<void> replaceTrack(ReplaceTrackOptions options) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<void> restartIce(IceParameters iceParameters) async {
    _logger.debug('restartIce()');

    if (!_transportReady) {
      return null;
    }

    if (_direction == Direction.send) {
      RTCSessionDescription offer =
          await _pc!.createOffer({'iceRestart': true});

      _logger.debug(
          'restartIce() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

      await _pc!.setLocalDescription(offer);

      RTCSessionDescription answer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

      _logger.debug(
          'restartIce() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

      await _pc!.setRemoteDescription(answer);
    } else {
      RTCSessionDescription offer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

      _logger.debug(
          'restartIce() | calling pc.setRemoteDescription() [offer:${offer.sdp}]');

      await _pc!.setRemoteDescription(offer);

      RTCSessionDescription answer = await _pc!.createAnswer();

      _logger.debug(
          'restartIce() | calling pc.setLocalDescription() [answer:${answer.toMap()}]');

      await _pc!.setLocalDescription(answer);
    }
  }

  @override
  void run({required HandlerRunOptions options}) async {
    _logger.debug('run()');

    _direction = options.direction;

    _remoteSdp = RemoteSdp(
      iceParameters: options.iceParameters,
      iceCandidates: options.iceCandidates,
      dtlsParameters: options.dtlsParameters,
      sctpParameters: options.sctpParameters,
      planB: true,
    );

    _sendingRtpParametersByKind = {
      RTCRtpMediaType.RTCRtpMediaTypeAudio: Ortc.getSendingRtpParameters(
          RTCRtpMediaType.RTCRtpMediaTypeAudio,
          options.extendedRtpCapabilities),
      RTCRtpMediaType.RTCRtpMediaTypeVideo: Ortc.getSendingRtpParameters(
          RTCRtpMediaType.RTCRtpMediaTypeVideo,
          options.extendedRtpCapabilities),
    };

    _sendingRemoteRtpParametersByKind = {
      RTCRtpMediaType.RTCRtpMediaTypeAudio: Ortc.getSendingRemoteRtpParameters(
          RTCRtpMediaType.RTCRtpMediaTypeAudio,
          options.extendedRtpCapabilities),
      RTCRtpMediaType.RTCRtpMediaTypeVideo: Ortc.getSendingRemoteRtpParameters(
          RTCRtpMediaType.RTCRtpMediaTypeVideo,
          options.extendedRtpCapabilities),
    };

    _pc = await createPeerConnection({
      'iceServers':
          options.iceServers.map((RTCIceServer i) => i.toMap()).toList(),
      'iceTransportPolicy': options.iceTransportPolicy?.value ?? 'all',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'plan-b',
      ...options.additionalSettings,
    }, options.proprietaryConstraints);

    // Handle RTCPeerConnection connection status.
    _pc!.onIceConnectionState = (RTCIceConnectionState state) {
      switch (_pc!.iceConnectionState) {
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
          {
            emit('@connectionstatechange', {'state': 'connecting'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          {
            emit('@connectionstatechange', {'state': 'connected'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          {
            emit('@connectionstatechange', {'state': 'failed'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          {
            emit('@connectionstatechange', {'state': 'disconnected'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          {
            emit('@connectionstatechange', {'state': 'closed'});
            break;
          }

        default:
          break;
      }
    };
  }

  @override
  Future<HandlerSendResult> send(HandlerSendOptions options) async {
    _assertSendRirection();

    _logger.debug(
        'send() [kind:${options.track.kind}, track.id:${options.track.id}]');

    if (options.codec != null) {
      _logger
          .warn('send() | codec selection is not available in Native handler');
    }

    // await options.stream.addTrack(options.track);
    await _pc!.addStream(options.stream);

    RTCSessionDescription offer = await _pc!.createOffer({
      'mandatory': {
        'OfferToReceiveAudio': false,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    });
    SdpObject localSdpObject = SdpObject.fromMap(parse(offer.sdp!));
    MediaObject offerMediaObject;
    RtpParameters sendingRtpParameters = RtpParameters.copy(
        _sendingRtpParametersByKind[
            RTCRtpMediaTypeExtension.fromString(options.track.kind!)]!);

    sendingRtpParameters.codecs =
        Ortc.reduceCodecs(sendingRtpParameters.codecs, null);

    RtpParameters sendingRemoteRtpParameters = RtpParameters.copy(
        _sendingRemoteRtpParametersByKind[
            RTCRtpMediaTypeExtension.fromString(options.track.kind!)]!);

    sendingRemoteRtpParameters.codecs =
        Ortc.reduceCodecs(sendingRemoteRtpParameters.codecs, null);

    if (!_transportReady) {
      await _setupTransport(
          localDtlsRole: DtlsRole.server, localSdpObject: localSdpObject);
    }

    if (options.track.kind == 'video' && options.encodings.length > 1) {
      _logger.debug('send() | enabling simulcast');

      localSdpObject = SdpObject.fromMap(parse(offer.sdp!));
      offerMediaObject = localSdpObject.media.firstWhere(
        (MediaObject m) => m.type == 'video',
        orElse: () => null as MediaObject,
      );

      PlanBUtils.addLegacySimulcast(
          offerMediaObject, options.track, options.encodings.length);

      offer =
          RTCSessionDescription(write(localSdpObject.toMap(), null), 'offer');
    }

    _logger.debug(
        'send() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

    await _pc!.setLocalDescription(offer);

    localSdpObject =
        SdpObject.fromMap(parse((await _pc!.getLocalDescription())!.sdp!));
    offerMediaObject = localSdpObject.media.firstWhere(
      (MediaObject m) => m.type == options.track.kind,
      orElse: () => null as MediaObject,
    );

    // Set RTCP CNAME.
    sendingRtpParameters.rtcp!.cname = CommonUtils.getCname(offerMediaObject);

    // Set RTP encodings.
    sendingRtpParameters.encodings =
        PlanBUtils.getRtpEncodings(offerMediaObject, options.track);

    // Complete encodings with given values.
    if (options.encodings.isNotEmpty) {
      for (int idx = 0; idx < sendingRtpParameters.encodings.length; ++idx) {
        sendingRtpParameters.encodings[idx] = RtpEncodingParameters.assign(
            sendingRtpParameters.encodings[idx], options.encodings[idx]);
      }
    }

    // If VP8 or H264 and there is effective simulcast, add scalabilityMode to
    // each encoding.
    if (sendingRtpParameters.encodings.length > 1 &&
        (sendingRtpParameters.codecs[0].mimeType.toLowerCase() == 'video/vp8' ||
            sendingRtpParameters.codecs[0].mimeType.toLowerCase() ==
                'video/h264')) {
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

    RTCSessionDescription answer =
        RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

    _logger.debug(
        'send() | calling pc.setRemoteDescription() [answer:${answer.toMap()}');

    await _pc!.setRemoteDescription(answer);

    String localId = _nextSendLocalId.toString();
    _nextSendLocalId++;

    // Insert into the map.
    _mapSendLocalIdTrack[localId] = options.track;

    return HandlerSendResult(
        localId: localId, rtpParameters: sendingRtpParameters);
  }

  @override
  Future<HandlerSendDataChannelResult> sendDataChannel(
      SendDataChannelArguments options) async {
    _assertSendRirection();

    RTCDataChannelInit initOptions = RTCDataChannelInit();
    initOptions.negotiated = true;
    initOptions.id = _nextSendSctpStreamId;
    initOptions.ordered = options.ordered ?? initOptions.ordered;
    initOptions.maxRetransmitTime =
        options.maxPacketLifeTime ?? initOptions.maxRetransmitTime;
    initOptions.maxRetransmits =
        options.maxRetransmits ?? initOptions.maxRetransmits;
    initOptions.protocol = options.protocol ?? initOptions.protocol;
    // initOptions.priority = options.priority;

    _logger.debug('sendDataChannel() [options:${initOptions.toMap()}]');

    RTCDataChannel dataChannel =
        await _pc!.createDataChannel(options.label!, initOptions);

    // Increase next id.
    _nextSendSctpStreamId = ++_nextSendSctpStreamId % SCTP_NUM_STREAMS.MIS;

    // If this is the first DataChannel we need to create the SDP answer with
    // m=application section.
    if (!_hasDataChannelMediaSection) {
      RTCSessionDescription offer = await _pc!.createOffer();
      SdpObject localSdpObject = SdpObject.fromMap(parse(offer.sdp!));
      MediaObject offerMediaObject = localSdpObject.media.firstWhere(
        (MediaObject m) => m.type == 'application',
        orElse: () => null as MediaObject,
      );

      if (!_transportReady) {
        await _setupTransport(
            localDtlsRole: DtlsRole.server, localSdpObject: localSdpObject);
      }

      _logger.debug(
          'sendDataChannel() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

      await _pc!.setLocalDescription(offer);

      _remoteSdp.sendSctpAssociation(offerMediaObject);

      RTCSessionDescription answer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

      _logger.debug(
          'sendDataChannel() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

      await _pc!.setRemoteDescription(answer);

      _hasDataChannelMediaSection = true;
    }

    SctpStreamParameters sctpStreamParameters = SctpStreamParameters(
      streamId: initOptions.id,
      ordered: initOptions.ordered,
      maxPacketLifeTime: initOptions.maxRetransmitTime,
      maxRetransmits: initOptions.maxRetransmits,
    );

    return HandlerSendDataChannelResult(
      dataChannel: dataChannel,
      sctpStreamParameters: sctpStreamParameters,
    );
  }

  @override
  Future<void> setMaxSpatialLayer(SetMaxSpatialLayerOptions options) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<void> setRtpEncodingParameters(
      SetRtpEncodingParametersOptions options) {
    throw UnsupportedError('not implemented');
  }

  @override
  Future<void> stopReceiving(String localId) async {
    _assertRecvDirection();

    _logger.debug('stopReceiving() [localId:$localId]');

    RtpParameters rtpParameters =
        _mapRecvLocalIdInfo[localId]!['rtpParameters'];
    String mid = _mapRecvLocalIdInfo[localId]!['mid'];

    // Remote from the map.
    _mapRecvLocalIdInfo.remove(localId);

    _remoteSdp.planBStopReceiving(mid, rtpParameters);

    RTCSessionDescription offer =
        RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

    _logger.debug(
        'stopReceiving() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

    await _pc!.setRemoteDescription(offer);
  }

  @override
  Future<void> stopSending(String localId) async {
    _assertSendRirection();

    _logger.debug('stopSending() [localId:$localId]');

    MediaStreamTrack? track = _mapSendLocalIdTrack[localId];

    if (track == null) {
      throw ('track not found');
    }

    _mapSendLocalIdTrack.remove(localId);
    // MediaStream sendStream = _pc.getLocalStreams().firstWhere((stream) {
    //   List<MediaStreamTrack> tracks = stream.getVideoTracks();
    //   if (tracks.isNotEmpty) {
    //     return tracks.first.id == track.id;
    //   }
    //   return false;
    // });

    final List<RTCRtpSender> senders = await _pc!.getSenders();

    RTCRtpSender? sender = senders.firstWhereOrNull(
      (e) => e.senderId == track.id,
    );
    if (sender == null) {
      throw 'sender not found';
    }
    await _pc!.removeTrack(sender);
    // await _pc.removeStream(sendStream);
    // await _sendStream.removeTrack(track);
    //
    // await  _pc.addStream(_sendStream);

    RTCSessionDescription offer = await _pc!.createOffer();

    _logger.debug(
        'stopSending() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

    try {
      await _pc!.setLocalDescription(offer);
    } catch (error) {
      // NOTE: If there are no sending tracks, setLocalDescription() will fail with
      // "Failed to create channels". If so, ignore it.
      if (_mapSendLocalIdTrack[localId] == null) {
        _logger.warn(
          'stopSending() | ignoring expected error due no sending tracks: ${error.toString()}',
        );

        return;
      }

      throw error;
    }

    if (_pc!.signalingState == RTCSignalingState.RTCSignalingStateStable) {
      return;
    }

    RTCSessionDescription answer =
        RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

    _logger.debug(
        'stopSending() | calling pc.setRemoteDescription() [answer:[${answer.toMap()}]');

    await _pc!.setRemoteDescription(answer);
  }

  @override
  Future<void> updateIceServers(List<RTCIceServer> iceServers) async {
    _logger.debug('updateIceServers()');

    Map<String, dynamic> configuration = _pc!.getConfiguration;

    configuration['iceServers'] =
        iceServers.map((RTCIceServer ice) => ice.toMap()).toList();

    await _pc!.setConfiguration(configuration);
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}