import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/SdpTransform/SdpTransform.dart';
import 'package:mediasoup_client_flutter/src/Ortc.dart';
import 'package:mediasoup_client_flutter/src/ScalabilityModes.dart';
import 'package:mediasoup_client_flutter/src/SdpObject.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';
import 'package:mediasoup_client_flutter/src/handlers/HandlerInterface.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/CommonUtils.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/MediaSection.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/RemoteSdp.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/UnifiedPlanUtils.dart';

Logger logger = Logger('Browser');

class Browser extends HandlerInterface {
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
  // Map of RTCTransceivers indexed by MID.
  Map<String, RTCRtpTransceiver> _mapMidTransceiver = {};
  // Whether a DataChannel m=application section has been created.
  bool _hasDataChannelMediaSection = false;
  // Sending DataChannel id value counter. Incremented for each new DataChannel.
  int _nextSendSctpStreamId = 0;
  // Got transport local and remote parameters.
  bool _transportReady = false;

  Browser() : super();

  Future<void> _setupTransport({
    DtlsRole localDtlsRole,
    SdpObject localSdpObject,
  }) async {
    if (localSdpObject == null) {
      localSdpObject =
          SdpObject.fromMap(parse((await _pc.getLocalDescription()).sdp));

      // Get our local DTLS parameters.
      DtlsParameters dtlsParameters =
          CommonUtils.extractDtlsParameters(localSdpObject);

      // Update the remote DTLC role in the SDP.
      _remoteSdp.updateDtlsRole(
        localDtlsRole == DtlsRole.client ? DtlsRole.server : DtlsRole.client,
      );

      // Need to tell the remote transport about our parameters.
      await safeEmitAsFuture('@connect', {
        'dtlsParameters': dtlsParameters,
      });

      _transportReady = true;
    }
  }

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
      'sdpSemantics': 'unified-plan',
    });

    try {
      bool audio = false;
      bool video = false;
      final List<MediaDeviceInfo> devices =
          await navigator.mediaDevices.enumerateDevices();

      devices.forEach((MediaDeviceInfo info) {
        if (info.kind == 'audioinput') {
          audio = true;
        }
        if (info.kind == 'videoinput') {
          video = true;
        }
      });
      MediaStream audioStream;
      if (audio) {
        final Map<String, dynamic> audioMediaConstraints = <String, dynamic>{
          'audio': true,
        };

        audioStream =
            await navigator.mediaDevices.getUserMedia(audioMediaConstraints);

        pc.addTransceiver(
            track: audioStream.getAudioTracks().first,
            kind: RTCRtpMediaType.RTCRtpMediaTypeAudio);
      }

      MediaStream videoStream;
      if (video) {
        final Map<String, dynamic> videoMediaConstraints = <String, dynamic>{
          'audio': false,
          'video': {
            'mandatory': {
              'minWidth': '320',
              'minHeight': '240',
              'minFrameRate': '30',
            },
          },
        };

        videoStream =
            await navigator.mediaDevices.getUserMedia(videoMediaConstraints);

        pc.addTransceiver(
            track: videoStream.getVideoTracks().first,
            kind: RTCRtpMediaType.RTCRtpMediaTypeVideo);
      }

      RTCSessionDescription offer = await pc.createOffer();
      final parsedOffer = parse(offer.sdp);
      print('parsed: ' + parsedOffer.toString());
      SdpObject sdpObject = SdpObject.fromMap(parsedOffer);

      RtpCapabilities nativeRtpCapabilities =
          CommonUtils.extractRtpCapabilities(sdpObject);

      return nativeRtpCapabilities;
    } catch (error) {
      try {
        await pc.close();
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
    ));
  }

  @override
  Future<List<StatsReport>> getReceiverStats(String localId) async {
    _assertRecvDirection();

    RTCRtpTransceiver transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw ('associated RTCRtpTransceiver not found');
    }

    return await transceiver.receiver.getStats();
  }

  @override
  Future<List<StatsReport>> getSenderStats(String localId) async {
    _assertSendRirection();

    RTCRtpTransceiver transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw ('associated RTCRtpTransceiver not found');
    }

    return await transceiver.sender.getStats();
  }

  @override
  Future<List<StatsReport>> getTransportStats() async {
    return await _pc.getStats();
  }

  @override
  String get name => 'Browser';

  @override
  Future<HandlerReceiveResult> receive(HandlerReceiveOptions options) async {
    _assertRecvDirection();

    logger.debug(
        'receive() [trackId:${options.trackId}, kind:${RTCRtpMediaTypeExtension.value(options.kind)}]');

    String localId =
        options.rtpParameters.mid ?? _mapMidTransceiver.length.toString();

    _remoteSdp.receive(
      mid: localId,
      kind: options.kind,
      offerRtpParameters: options.rtpParameters,
      streamId: options.rtpParameters.rtcp.cname,
      trackId: options.trackId,
    );

    RTCSessionDescription offer = RTCSessionDescription(
      _remoteSdp.getSdp(),
      'offer',
    );

    logger.debug(
        'receive() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

    await _pc.setRemoteDescription(offer);

    RTCSessionDescription answer = await _pc.createAnswer();

    SdpObject localSdpObject = SdpObject.fromMap(parse(answer.sdp));

    MediaObject answerMediaObject = localSdpObject.media.firstWhere(
      (MediaObject m) => m.mid == localId,
      orElse: () => null,
    );

    // May need to modify codec parameters in the answer based on codec
    // parameters in the offer.
    CommonUtils.applyCodecParameters(options.rtpParameters, answerMediaObject);

    answer = RTCSessionDescription(
      write(localSdpObject.toMap(), null),
      'answer',
    );

    if (!_transportReady) {
      await _setupTransport(
        localDtlsRole: DtlsRole.client,
        localSdpObject: localSdpObject,
      );
    }

    logger.debug(
        'receive() | calling pc.setLocalDescription() [answer:${answer.toMap()}]');

    await _pc.setLocalDescription(answer);

    RTCRtpTransceiver transceiver = (await _pc.getTransceivers())
        .firstWhere((RTCRtpTransceiver t) => t.mid == localId);

    if (transceiver == null) {
      throw ('new RTCRtpTransceiver not found');
    }

    // Store in the map.
    _mapMidTransceiver[localId] = transceiver;

    return HandlerReceiveResult(
      localId: localId,
      track: transceiver.receiver.track,
      rtpReceiver: transceiver.receiver,
    );
  }

  @override
  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
      HandlerReceiveDataChannelOptions options) async {
    _assertRecvDirection();

    RTCDataChannelInit initOptions = RTCDataChannelInit();
    initOptions.negotiated = true;
    initOptions.id = options.sctpStreamParameters.streamId;
    initOptions.ordered = options.sctpStreamParameters.ordered;
    initOptions.maxRetransmitTime =
        options.sctpStreamParameters.maxPacketLifeTime;
    initOptions.maxRetransmits = options.sctpStreamParameters.maxRetransmits;
    initOptions.protocol = options.protocol;

    logger.debug('receiveDataChannel() [options:${initOptions.toMap()}]');

    RTCDataChannel dataChannel =
        await _pc.createDataChannel(options.label, initOptions);

    // If this is the first DataChannel we need to create the SDP offer with
    // m=application section.
    if (!_hasDataChannelMediaSection) {
      _remoteSdp.receiveSctpAssociation();

      RTCSessionDescription offer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

      logger.debug(
          'receiveDataChannel() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

      await _pc.setRemoteDescription(offer);

      RTCSessionDescription answer = await _pc.createAnswer();

      if (_transportReady) {
        SdpObject localSdpObject = SdpObject.fromMap(parse(answer.sdp));

        await _setupTransport(
            localDtlsRole: DtlsRole.client, localSdpObject: localSdpObject);
      }

      logger.debug(
          'receiveDataChannel() | calling pc.setRemoteDescription() [answer: ${answer.toMap()}');

      await _pc.setLocalDescription(answer);

      _hasDataChannelMediaSection = true;
    }

    return HandlerReceiveDataChannelResult(dataChannel: dataChannel);
  }

  @override
  Future<void> replaceTrack(ReplaceTrackOptions options) async {
    _assertSendRirection();

    if (options.track != null) {
      logger.debug(
          'replaceTrack() [localId:${options.localId}, track.id${options.track.id}');
    } else {
      logger.debug('replaceTrack() [localId:${options.localId}, no track');
    }

    RTCRtpTransceiver transceiver = _mapMidTransceiver[options.localId];

    if (transceiver == null) {
      throw ('associated RTCRtpTransceiver not found');
    }

    await transceiver.sender.replaceTrack(options.track);
  }

  @override
  Future<void> restartIce(IceParameters iceParameters) async {
    logger.debug('restartIce()');

    // Provide the remote SDP handler with new remote Ice parameters.
    _remoteSdp.updateIceParameters(iceParameters);

    if (!_transportReady) {
      return null;
    }

    if (_direction == Direction.send) {
      RTCSessionDescription offer =
          await _pc.createAnswer({'iceRestart': true});

      logger.debug(
          'restartIce() | calling pc.setLocalDescription() [offer:${offer.toMap()}]');

      await _pc.setLocalDescription(offer);

      RTCSessionDescription answer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

      logger.debug(
          'restartIce() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

      await _pc.setRemoteDescription(answer);
    } else {
      RTCSessionDescription offer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

      logger.debug(
          'restartIce() | calling pc.setRemoteDescription() [offer:${offer.toMap()}]');

      await _pc.setRemoteDescription(offer);

      RTCSessionDescription answer = await _pc.createAnswer();

      logger.debug(
          'restartIce() | calling pc.setLocalDescription() [answer:${answer.toMap()}]');

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
      'iceServers': options.iceServers != null
          ? options.iceServers.map((RTCIceServer i) => i.toMap()).toList()
          : [],
      'iceTransportPolicy': options.iceTransportPolicy != null
          ? options.iceTransportPolicy.value
          : 'all',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'unified-plan',
      ...options.additionalSettings,
    }, options.proprietaryConstraints);

    // Handle RTCPeerConnection connection status.
    _pc.onIceConnectionState = (RTCIceConnectionState state) {
      switch (_pc.iceConnectionState) {
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
          {
            emit('@connectionstatechange', {'state': 'connecting'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          {
            emit('@connectionstatechange', {'state':'connected'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          {
            emit('@connectionstatechange', {'state':'failed'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          {
            emit('@connectionstatechange', {'state':'disconnected'});
            break;
          }
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          {
            emit('@connectionstatechange', {'state':'closed'});
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

    logger.debug(
        'send() [kind:${options.track.kind}, tack.id:${options.track.id}');

    if (options.encodings != null && options.encodings.length > 1) {
      int idx = 0;
      options.encodings.forEach((RtpEncodingParameters encoding) {
        encoding.rid = 'r$idx';
        idx++;
      });
    }

    RtpParameters sendingRtpParameters = RtpParameters.copy(
        _sendingRtpParametersByKind[
            RTCRtpMediaTypeExtension.fromString(options.track.kind)]);

    // This may throw.
    sendingRtpParameters.codecs =
        Ortc.reduceCodecs(sendingRtpParameters.codecs, options.codec);

    RtpParameters sendingRemoteRtpParameters = RtpParameters.copy(
        _sendingRemoteRtpParametersByKind[
            RTCRtpMediaTypeExtension.fromString(options.track.kind)]);

    // This may throw.
    sendingRemoteRtpParameters.codecs =
        Ortc.reduceCodecs(sendingRemoteRtpParameters.codecs, options.codec);

    MediaSectionIdx mediaSectionIdx = _remoteSdp.getNextMediaSectionIdx();
    RTCRtpTransceiver transceiver = await _pc.addTransceiver(
      track: options.track,
      kind: RTCRtpMediaTypeExtension.fromString(options.track.kind),
      init: RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [_sendStream],
        sendEncodings: options.encodings,
      ),
    );

    RTCSessionDescription offer = await _pc.createOffer();
    SdpObject localSdpObject = SdpObject.fromMap(parse(offer.sdp));
    MediaObject offerMediaObject;

    if (!_transportReady) {
      await _setupTransport(
        localDtlsRole: DtlsRole.server,
        localSdpObject: localSdpObject,
      );
    }

    // Speacial case for VP9 with SVC.
    bool hackVp9Svc = false;

    ScalabilityMode layers = ScalabilityMode.parse(
        (options.encodings ?? [RtpEncodingParameters(scalabilityMode: '')])
            .first
            .scalabilityMode);

    if (options.encodings != null &&
        options.encodings.length == 1 &&
        layers.spatialLayers > 1 &&
        sendingRtpParameters.codecs.first.mimeType.toLowerCase() ==
            'video/vp9') {
      logger.debug('send() | enabling legacy simulcast for VP9 SVC');

      hackVp9Svc = true;
      localSdpObject = SdpObject.fromMap(parse(offer.sdp));
      offerMediaObject = localSdpObject.media[mediaSectionIdx.idx];

      UnifiedPlanUtils.addLegacySimulcast(
          offerMediaObject, layers.spatialLayers);

      offer =
          RTCSessionDescription(write(localSdpObject.toMap(), null), 'offer');
    }

    logger.debug(
        'send() | calling pc.setLocalDescription() [offer:${offer.toMap()}');

    await _pc.setLocalDescription(offer);

    // We can now get the transceiver.mid.
    String localId = transceiver.mid;

    // Set MID.
    sendingRtpParameters.mid = localId;

    localSdpObject =
        SdpObject.fromMap(parse((await _pc.getLocalDescription()).sdp));
    offerMediaObject = localSdpObject.media[mediaSectionIdx.idx];

    // Set RTCP CNAME.
    sendingRtpParameters.rtcp.cname = CommonUtils.getCname(offerMediaObject);

    // Set RTP encdoings by parsing the SDP offer if no encoding are given.
    if (options.encodings == null) {
      sendingRtpParameters.encodings =
          UnifiedPlanUtils.getRtpEncodings(offerMediaObject);
    }
    // Set RTP encodings by parsing the SDP offer and complete them with given
    // one if just a single encoding has been given.
    else if (options.encodings.length == 1) {
      List<RtpEncodingParameters> newEncodings =
          UnifiedPlanUtils.getRtpEncodings(offerMediaObject);

      newEncodings[0] =
          RtpEncodingParameters.assign(newEncodings[0], options.encodings[0]);

      // Hack for VP9 SVC.
      if (hackVp9Svc) {
        newEncodings = [newEncodings[0]];
      }

      sendingRtpParameters.encodings = newEncodings;
    }
    // Otherwise if more than 1 encoding are given use them verbatim.
    else {
      sendingRtpParameters.encodings = options.encodings;
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
      reuseMid: mediaSectionIdx.reuseMid,
      offerRtpParameters: sendingRtpParameters,
      answerRtpParameters: sendingRemoteRtpParameters,
      codecOptions: options.codecOptions,
      extmapAllowMixed: true,
    );

    RTCSessionDescription answer =
        RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

    logger.debug(
        'send() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

    await _pc.setRemoteDescription(answer);

    // Store in the map.
    _mapMidTransceiver[localId] = transceiver;

    return HandlerSendResult(
      localId: localId,
      rtpParameters: sendingRtpParameters,
      rtpSender: transceiver.sender,
    );
  }

  @override
  Future<HandlerSendDataChannelResult> sendDataChannel(
      SctpStreamParameters options) async {
    _assertSendRirection();

    RTCDataChannelInit initOptions = RTCDataChannelInit();
    initOptions.negotiated = true;
    initOptions.id = options.streamId;
    initOptions.ordered = options.ordered;
    initOptions.maxRetransmitTime = options.maxPacketLifeTime;
    initOptions.maxRetransmits = options.maxRetransmits;
    initOptions.protocol = options.protocol;
    // initOptions.priority = options.priority;

    logger.debug('sendDataChannel() [options:${initOptions.toMap()}]');

    RTCDataChannel dataChannel =
        await _pc.createDataChannel(options.label, initOptions);

    // Increase next id.
    _nextSendSctpStreamId = ++_nextSendSctpStreamId % SCTP_NUM_STREAMS.MIS;

    // If this is the first DataChannel we need to create the SDP answer with
    // m=application section.
    if (!_hasDataChannelMediaSection) {
      RTCSessionDescription offer = await _pc.createOffer();
      SdpObject localSdpObject = SdpObject.fromMap(parse(offer.sdp));
      MediaObject offerMediaObject = localSdpObject.media.firstWhere(
        (MediaObject m) => m.type == 'application',
        orElse: () => null,
      );

      if (!_transportReady) {
        await _setupTransport(
          localDtlsRole: DtlsRole.server,
          localSdpObject: localSdpObject,
        );
      }

      logger.debug(
          'sendDataChannel() | calling pc.setLocalDescription() [offer:${offer.toMap()}');

      await _pc.setLocalDescription(offer);

      _remoteSdp.sendSctpAssociation(offerMediaObject);

      RTCSessionDescription answer =
          RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

      logger.debug(
          'sendDataChannel() | calling pc.setRemoteDescription() [answer:${answer.toMap()}]');

      await _pc.setRemoteDescription(answer);

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
  Future<void> setMaxSpatialLayer(SetMaxSpatialLayerOptions options) async {
    _assertSendRirection();

    logger.debug(
        'setMaxSpatialLayer() [localId:${options.localId}, spatialLayer:${options.spatialLayer}');

    RTCRtpTransceiver transceiver = _mapMidTransceiver[options.localId];

    if (transceiver == null) {
      throw ('associated RTCRtpTransceiver not found');
    }

    RTCRtpParameters parameters = transceiver.sender.parameters;

    int idx = 0;
    parameters.encodings.forEach((RTCRtpEncoding encoding) {
      if (idx <= options.spatialLayer) {
        encoding.active = true;
      } else {
        encoding.active = false;
      }
      idx++;
    });

    await transceiver.sender.setParameters(parameters);
  }

  @override
  Future<void> setRtpEncodingParameters(
      SetRtpEncodingParametersOptions options) async {
    _assertSendRirection();

    logger.debug(
        'setRtpEncodingParameters() [localId:${options.localId}, params:${options.params}]');

    RTCRtpTransceiver transceiver = _mapMidTransceiver[options.localId];

    if (transceiver == null) {
      throw ('associated RTCRtpTransceiver not found');
    }

    RTCRtpParameters parameters = transceiver.sender.parameters;

    int idx = 0;
    parameters.encodings.forEach((RTCRtpEncoding encoding) {
      parameters.encodings[idx] = RTCRtpEncoding(
        active: options.params.active != null
            ? options.params.active
            : encoding.active,
        maxBitrate: options.params.maxBitrate ?? encoding.maxBitrate,
        maxFramerate: options.params.maxFramerate ?? encoding.maxFramerate,
        minBitrate: options.params.minBitrate ?? encoding.minBitrate,
        numTemporalLayers:
            options.params.numTemporalLayers ?? encoding.numTemporalLayers,
        rid: options.params.rid ?? encoding.rid,
        scaleResolutionDownBy: options.params.scaleResolutionDownBy ??
            encoding.scaleResolutionDownBy,
        ssrc: options.params.ssrc ?? encoding.ssrc,
      );
      idx++;
    });

    await transceiver.sender.setParameters(parameters);
  }

  @override
  Future<void> stopReceiving(String localId) async {
    _assertRecvDirection();

    logger.debug('stopReceiving() [localId:$localId');

    RTCRtpTransceiver transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw ('associated RTCRtpTransceiveer not found');
    }

    _remoteSdp.closeMediaSection(transceiver.mid);

    RTCSessionDescription offer =
        RTCSessionDescription(_remoteSdp.getSdp(), 'offer');

    logger.debug(
        'stopReceiving() | calling pc.setRemoteDescription() [offer:${offer.toMap()}');

    await _pc.setRemoteDescription(offer);

    RTCSessionDescription answer = await _pc.createAnswer();

    logger.debug(
        'stopReceiving() | calling pc.setLocalDescription() [answer:${answer.toMap()}');

    await _pc.setLocalDescription(answer);
  }

  @override
  Future<void> stopSending(String localId) async {
    _assertSendRirection();

    logger.debug('stopSending() [localId:$localId]');

    RTCRtpTransceiver transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw ('associated RTCRtpTransceiver not found');
    }

    await transceiver.sender.replaceTrack(null);
    await _pc.removeTrack(transceiver.sender);
    _remoteSdp.closeMediaSection(transceiver.mid);

    RTCSessionDescription offer = await _pc.createOffer();

    logger.debug(
        'stopSending() | calling pc.setLocalDescription() [offer:${offer.toMap()}');

    await _pc.setLocalDescription(offer);

    RTCSessionDescription answer =
        RTCSessionDescription(_remoteSdp.getSdp(), 'answer');

    logger.debug(
        'stopSending() | calling pc.setRemoteDescription() [answer:${answer.toMap()}');

    await _pc.setRemoteDescription(answer);
  }

  @override
  Future<void> updateIceServers(List<RTCIceServer> iceServers) async {
    logger.debug('updateIceServers()');

    Map<String, dynamic> configuration = _pc.getConfiguration;

    configuration['iceServers'] =
        iceServers.map((RTCIceServer ice) => ice.toMap()).toList();

    await _pc.setConfiguration(configuration);
  }
}
