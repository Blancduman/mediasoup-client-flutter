import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/h264/H264Utils.dart';

String RTP_PROBATOR_MID = 'probator';
int RTP_PROBATOR_SSRC = 1234;
int RTP_PROBATOR_CODEC_PAYLOAD_TYPE = 127;

class Ortc {
  /// Validates RtcpFeedback. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtcpFeedback(RtcpFeedback fb) {
    if (fb == null) {
      throw ('fb is not an object');
    }

    // type is mandatory.
    if (fb.type == null || fb.type.isEmpty) {
      throw ('missing fb.type');
    }

    // parameter is optional. If unset set it to an empty string.
    if (fb.parameter == null || fb.parameter.isEmpty) {
      fb.parameter = '';
    }
  }

  /// Validates RtpCodecCapability. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtpCodecCapability(RtpCodecCapability codec) {
    RegExp mimeTypeRegex = RegExp(r"^(audio|video)/(.+)", caseSensitive: true);

    if (codec == null) {
      throw ('codec is not an object');
    }

    // maimeType is mandatory.
    if (codec.mimeType == null || codec.mimeType.isEmpty) {
      throw ('missing codec.mimeType');
    }

    Iterable<RegExpMatch> mimeTypeMatch =
        mimeTypeRegex.allMatches(codec.mimeType);

    if (mimeTypeMatch == null) {
      throw ('invalid codec.mimeType');
    }

    // Just override kind with media component of mimeType.
    codec.kind = RTCRtpMediaTypeExtension.fromString(
        mimeTypeMatch.elementAt(0).group(1).toLowerCase());

    // // preferredPayloadType is optional.
    // if (codec.preferredPayloadType == null) {
    //   throw ('invalid codec.preferredPayloadType');
    // }

    // clockRate is mandatory.
    if (codec.clockRate == null) {
      throw ('missing codec.clockRate');
    }

    // channels is optional. If unset, set it to 1 (just if audio).
    if (codec.kind == RTCRtpMediaType.RTCRtpMediaTypeAudio) {
      if (codec.channels == null) {
        codec.channels = 1;
      }
    } else {
      codec.channels = null;
    }

    // parameters is optional. if unset, set it to an empty object.
    if (codec.parameters == null) {
      codec.parameters = {};
    }

    for (var key in codec.parameters.keys) {
      var value = codec.parameters[key];

      if (value == null) {
        codec.parameters[key] = '';
        value = '';
      }

      if (value is! String && value is! int) {
        throw ('invalid codec parameter [key:${key}s, value:$value');
      }

      // Specific parameters validation.
      if (key == 'apt') {
        if (value is! int) {
          throw ('invalid codec apt paramter');
        }
      }

      // rtcpFeedback is optional. If unset, set it to an empty array.
      // || codec.rtcpFeedback is! List<RtcpFeedback>
      if (codec.rtcpFeedback == null) {
        codec.rtcpFeedback = <RtcpFeedback>[];
      }

      for (RtcpFeedback fb in codec.rtcpFeedback) {
        validateRtcpFeedback(fb);
      }
    }
  }

  /// Validates RtpHeaderExtension. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtpHeaderExtension(RtpHeaderExtension ext) {
    if (ext == null) {
      throw ('ext is not an object');
    }

    // // kind is optional. If unset set it to an empty string.
    // if (ext.kind == null || ext.kind is! RTCRtpMediaType) {
    //   ext.kind = ''
    // }

    if (ext.kind != RTCRtpMediaType.RTCRtpMediaTypeAudio &&
        ext.kind != RTCRtpMediaType.RTCRtpMediaTypeVideo) {
      throw ('invalid ext.kind');
    }

    // uri is mandatory.
    if (ext.uri == null) {
      throw ('missing ext.uri');
    }

    // preferredId is mandatory.
    if (ext.preferredId == null) {
      throw ('missing ext.preferredId');
    }

    // preferredEncrypt is optional. If unset set it to false.
    if (ext.preferredEncrypt == null) {
      ext.preferredEncrypt = false;
    }

    // direction is optional. If unset set it to sendrecv.
    if (ext.direction == null) {
      ext.direction = RtpHeaderDirection.SendRecv;
    }
  }

  /// Validates RtpCapabilities. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtpCapabilities(RtpCapabilities caps) {
    if (caps == null) {
      throw ('caps is not an object...');
    }

    // codecs is optional. If unset, fill with an empty array.
    // if (caps.codecs != null && caps.codecs is! List<RtpCodecCapability>) {
    //   throw ('caps.codecs is not an array');
    // } else
    if (caps.codecs == null) {
      caps.codecs = <RtpCodecCapability>[];
    }

    for (RtpCodecCapability codec in caps.codecs) {
      validateRtpCodecCapability(codec);
    }

    // headerExtensions is optional. If unset, fill with an empty array.
    // if (caps.headerExtensions == null &&
    //     caps.headerExtensions is! List<RtpHeaderExtension>) {
    //   throw ('caps.headerExtensions is not an array');
    // } else
    if (caps.headerExtensions == null) {
      caps.headerExtensions = <RtpHeaderExtension>[];
    }

    for (RtpHeaderExtension ext in caps.headerExtensions) {
      validateRtpHeaderExtension(ext);
    }
  }

  /// Validates RtpHeaderExtensionParameteters. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtpHeaderExtensionParameters(
      RtpHeaderExtensionParameters ext) {
    if (ext == null) {
      throw ('ext is not an object');
    }

    // uri is mandatory.
    if (ext.uri == null) {
      throw ('missing ext.uri');
    }

    // id is mandatory.
    if (ext.id == null) {
      throw ('missing ext.id');
    }

    // encrypt is optional. If unset set it to false.
    if (ext.encrypt == null) {
      ext.encrypt = false;
    }

    // parameters is optional. If unset, set it to an empty object.
    if (ext.parameters == null) {
      ext.parameters = <dynamic, dynamic>{};
    }

    for (String key in ext.parameters.keys) {
      var value = ext.parameters[key];

      if (value == null) {
        ext.parameters[key] = '';
        value = '';
      }

      if (value is! String && value is! int) {
        throw ('invalid header extension parameter');
      }
    }
  }

  /// Validates RtpEncodingParameters. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtpEncodingParameters(RtpEncodingParameters encoding) {
    if (encoding == null) {
      throw ('encoding is not an object');
    }

    // ssrc is optional.
    if (encoding.rtx != null) {
      if (encoding.rtx.ssrc == null) {
        throw ('missing encoding.rtx.ssrc');
      }
    }

    // dtx is optional. If unset set it to false.
    if (encoding.dtx == null) {
      encoding.dtx = false;
    }
  }

  /// Validates RtcpParameters. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtcpParameters(RtcpParameters rtcp) {
    if (rtcp == null) {
      throw ('rtcp is not an object');
    }

    // reducedSize is optional. If unset set it to true.
    if (rtcp.reducedSize == null) {
      rtcp.reducedSize = true;
    }
  }

  /// Validates RtpCodecParameters. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtpCodecParameters(RtpCodecParameters codec) {
    RegExp mimeTypeRegex = RegExp(r"^(audio|video)/(.+)", caseSensitive: true);

    if (codec == null) {
      throw ('codec is not an object');
    }

    // mimeType is mandatory.
    if (codec.mimeType == null) {
      throw ('missing codec.mimeType');
    }

    Iterable<RegExpMatch> mimeTypeMatch =
        mimeTypeRegex.allMatches(codec.mimeType);

    if (mimeTypeMatch == null) {
      throw ('invalid codec.mimeType');
    }

    // payloadType is mandatory.
    if (codec.payloadType == null) {
      throw ('missing codec.payloadType');
    }

    // clockRate is mandatory.
    if (codec.clockRate == null) {
      throw ('missing codec.clockRate');
    }

    RTCRtpMediaType kind = RTCRtpMediaTypeExtension.fromString(
        mimeTypeMatch.elementAt(0).group(1).toLowerCase());

    // channels is optional. If unset, set it to 1 (just if audio).
    if (kind == RTCRtpMediaType.RTCRtpMediaTypeAudio) {
      if (codec.channels == null) {
        codec.channels = 1;
      }
    } else {
      codec.channels = null;
    }

    // Parameters is optional. if Unset, set it to an empty object.
    if (codec.parameters == null) {
      codec.parameters = <dynamic, dynamic>{};
    }

    for (String key in codec.parameters.keys) {
      var value = codec.parameters[key];
      if (value == null) {
        codec.parameters[key] = '';
        value = '';
      }

      if (value is! String && value is! int) {
        throw ('invalid codec parameter [key:${key}s, value:$value]');
      }

      // Specific parameters validation.
      if (key == 'apt') {
        if (value is! int) {
          throw ('invalid codec apt parameter');
        }
      }
    }

    // rtcpFeedback is optional. If unset, set it to an empty array.
    if (codec.rtcpFeedback == null ||
        codec.rtcpFeedback is! List<RtcpFeedback>) {
      codec.rtcpFeedback = <RtcpFeedback>[];
    }

    for (RtcpFeedback fb in codec.rtcpFeedback) {
      validateRtcpFeedback(fb);
    }
  }

  /// Validates RtpParameters. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateRtpParameters(RtpParameters params) {
    // codecs is mandatory.
    if (params.codecs == null) {
      throw ('missing params.codecs');
    }

    for (RtpCodecParameters codec in params.codecs) {
      validateRtpCodecParameters(codec);
    }

    // headerExtensions is optional. If unset, fill with an empty array.
    if (params.headerExtensions == null) {
      params.headerExtensions = <RtpHeaderExtensionParameters>[];
    }

    for (RtpHeaderExtensionParameters ext in params.headerExtensions) {
      validateRtpHeaderExtensionParameters(ext);
    }

    // encodings is optional. If unset, fill with an empty array.
    if (params.encodings == null) {
      params.encodings = <RtpEncodingParameters>[];
    }

    for (RtpEncodingParameters encoding in params.encodings) {
      validateRtpEncodingParameters(encoding);
    }

    // rtcp is optional. If unset, fill with an empty object.
    if (params.rtcp == null) {
      params.rtcp = RtcpParameters();
    }

    validateRtcpParameters(params.rtcp);
  }

  /// Validates NumSctpStreams. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateNumSctpStreams(NumSctpStreams numStreams) {
    if (numStreams == null) {
      throw ('numStreams is not an object');
    }

    // OS is mandatory.
    if (numStreams.os == null) {
      throw ('missing numStreams.OS');
    }

    // MIS is mandatory.
    if (numStreams.mis == null) {
      throw ('missing numStreams.MIS');
    }
  }

  /// Validates SctpCapabilities. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateSctpCapabilities(SctpCapabilities caps) {
    if (caps == null) {
      throw ('caps is not an object');
    }

    // numStreams is mandatory.
    if (caps.numStreams == null) {
      throw ('missing caps.numStreams');
    }

    validateNumSctpStreams(caps.numStreams);
  }

  /// Validates SctpParameters. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateSctpParameters(SctpParameters params) {
    if (params == null) {
      throw ('params is not an object');
    }

    // port is mandatory.
    if (params.port == null) {
      throw ('missing params.port');
    }

    // OS is mandatory.
    if (params.os == null) {
      throw ('missing params.OS');
    }

    // MIS is mandatory.
    if (params.mis == null) {
      throw ('missing params.MIS');
    }

    // maxMessageSize is mandatory.
    if (params.maxMessageSize == null) {
      throw ('missing params.maxMessageSize');
    }
  }

  /// Validates SctpStreamParameters. It may modify given data by adding missing
  /// fields with default values.
  /// It throws if invalid.
  static void validateSctpStreamParameters(SctpStreamParameters params) {
    if (params == null) {
      throw ('params is not an object');
    }

    // streamId is mandatory.
    if (params.streamId == null) {
      throw ('missing params.streamId');
    }

    // ordered is optional;
    bool orderedGiven = false;

    if (params.ordered != null) {
      orderedGiven = true;
    } else {
      params.ordered = true;
    }

    if (params.maxPacketLifeTime != null && params.maxRetransmits != null) {
      throw ('cannot provide both maxPacketLife and maxRetransmits');
    }

    if (orderedGiven &&
        params.ordered &&
        (params.maxPacketLifeTime != null || params.maxRetransmits != null)) {
      throw ('cannot be ordered with maxPacketLifeTime or maxRetransmits');
    } else if (!orderedGiven &
        (params.maxPacketLifeTime != null || params.maxRetransmits != null)) {
      params.ordered = false;
    }
  }

  static bool isRtxCodec(dynamic codec) {
    if (codec == null) {
      return false;
    }

    return RegExp(r'.+\/rtx$', caseSensitive: true).hasMatch(codec.mimeType);
  }

  static bool matchCodecs({
    dynamic aCodec,
    dynamic bCodec,
    bool strict = false,
    modify = false,
  }) {
    String aMimeType = aCodec.mimeType.toLowerCase();
    String bMimeType = bCodec.mimeType.toLowerCase();

    if (aMimeType != bMimeType) {
      return false;
    }

    if (aCodec.clockRate != bCodec.clockRate) {
      return false;
    }

    if (aCodec.channels != bCodec.channels) {
      return false;
    }

    // Per codec special checks.
    switch (aMimeType) {
      case 'video/h264':
        {
          var aPacketizationMode = aCodec.parameters['packetization-mode'] ?? 0;
          var bPacketizationMode = bCodec.parameters['packetization-mode'] ?? 0;

          if (aPacketizationMode != bPacketizationMode) {
            return false;
          }

          // If strict matching check profile-level-id.
          if (strict) {
            if (!H264Utils.isSameProfile(
                aCodec.parameters, bCodec.parameters)) {
              return false;
            }

            String selectedProfileLevelId;

            try {
              selectedProfileLevelId =
                  H264Utils.generateProfileLevelIdForAnswer(
                local_supported_params: aCodec.parameters,
                remote_offered_params: bCodec.parameters,
              );
            } catch (error) {
              return false;
            }

            if (modify) {
              if (selectedProfileLevelId != null) {
                aCodec.parameters['profile-level-id'] = selectedProfileLevelId;
                bCodec.parameters['profile-level-id'] = selectedProfileLevelId;
              } else {
                aCodec.parameters.remove('profile-level-id');
                bCodec.parameters.remove('profile-level-id');
              }
            }
          }
          break;
        }

      case 'video/vp9':
        {
          // If strict matching heck profile-id.
          if (strict) {
            var aProfileId = aCodec.parameters['profile-id'] ?? 0;
            var bProfileId = aCodec.parameters['profile-id'] ?? 0;

            if (aProfileId != bProfileId) {
              return false;
            }
          }
          break;
        }
    }

    return true;
  }

  static List<RtcpFeedback> reduceRtcpFeedback(dynamic codecA, dynamic codecB) {
    List<RtcpFeedback> reducedRtcpFeedback = <RtcpFeedback>[];

    for (RtcpFeedback aFb in codecA.rtcpFeedback ?? []) {
      RtcpFeedback matchingBFb = (codecB.rtcpFeedback ?? []).firstWhere(
        (RtcpFeedback bFb) =>
            bFb.type == aFb.type &&
            (bFb.parameter == aFb.parameter ||
                (bFb.parameter == null && aFb.parameter == null)),
        orElse: () => null,
      );

      if (matchingBFb != null) {
        reducedRtcpFeedback.add(matchingBFb);
      }
    }

    return reducedRtcpFeedback;
  }

  static bool matchHeaderExtensions(
    RtpHeaderExtension aExt,
    RtpHeaderExtension bExt,
  ) {
    if (aExt.kind != null && bExt.kind != null && aExt.kind != bExt.kind) {
      return false;
    }

    if (aExt.uri != bExt.uri) {
      return false;
    }

    return true;
  }

  /// Generate extended RTP capabilities for sending and receiving.
  static ExtendedRtpCapabilities getExtendedRtpCapabilities(
    RtpCapabilities localCaps,
    RtpCapabilities remoteCaps,
  ) {
    ExtendedRtpCapabilities extendedRtpCapabilities = ExtendedRtpCapabilities(
      codecs: [],
      headerExtensions: [],
    );

    // Match media codecs and keep the order preferred by remoteCaps.
    for (RtpCodecCapability remoteCodec in remoteCaps.codecs ?? []) {
      if (isRtxCodec(remoteCodec)) {
        continue;
      }

      RtpCodecCapability matchingLocalCodec =
          (localCaps.codecs ?? []).firstWhere(
        (RtpCodecCapability localCodec) => matchCodecs(
            aCodec: localCodec,
            bCodec: remoteCodec,
            strict: true,
            modify: true),
        orElse: () => null,
      );

      if (matchingLocalCodec == null) {
        continue;
      }

      ExtendedRtpCodec extendedCodec = ExtendedRtpCodec(
        mimeType: matchingLocalCodec.mimeType,
        kind: matchingLocalCodec.kind,
        clockRate: matchingLocalCodec.clockRate,
        channels: matchingLocalCodec.channels,
        localPayloadType: matchingLocalCodec.preferredPayloadType,
        localRtxPayloadType: null,
        remotePayloadType: remoteCodec.preferredPayloadType,
        remoteRtxPayloadType: null,
        localParameters: matchingLocalCodec.parameters,
        remoteParameters: remoteCodec.parameters,
        rtcpFeedback: reduceRtcpFeedback(matchingLocalCodec, remoteCodec),
      );

      extendedRtpCapabilities.codecs.add(extendedCodec);
    }

    // Match RTX codecs.
    for (ExtendedRtpCodec extendedCodec in extendedRtpCapabilities.codecs) {
      RtpCodecCapability matchingLocalRtxCodec = localCaps.codecs.firstWhere(
        (RtpCodecCapability localCodec) =>
            isRtxCodec(localCodec) &&
            localCodec.parameters['apt'] == extendedCodec.localPayloadType,
        orElse: () => null,
      );

      RtpCodecCapability matchingRemoteRtxCodec = remoteCaps.codecs.firstWhere(
        (RtpCodecCapability remoteCodec) =>
            isRtxCodec(remoteCodec) &&
            remoteCodec.parameters['apt'] == extendedCodec.remotePayloadType,
        orElse: () => null,
      );

      if (matchingLocalRtxCodec != null && matchingRemoteRtxCodec != null) {
        extendedCodec.localRtxPayloadType =
            matchingLocalRtxCodec.preferredPayloadType;
        extendedCodec.remoteRtxPayloadType =
            matchingRemoteRtxCodec.preferredPayloadType;
      }
    }

    // Match header extensions.
    for (RtpHeaderExtension remoteExt in remoteCaps.headerExtensions) {
      RtpHeaderExtension matchingLocalExt =
          localCaps.headerExtensions.firstWhere(
        (RtpHeaderExtension localExt) =>
            matchHeaderExtensions(localExt, remoteExt),
        orElse: () => null,
      );

      if (matchingLocalExt == null) {
        continue;
      }

      ExtendedRtpHeaderExtension extendedExt = ExtendedRtpHeaderExtension(
        kind: remoteExt.kind,
        uri: remoteExt.uri,
        sendId: matchingLocalExt.preferredId,
        recvId: remoteExt.preferredId,
        encrypt: matchingLocalExt.preferredEncrypt,
        direction: RtpHeaderDirection.SendRecv,
      );

      switch (remoteExt.direction) {
        case RtpHeaderDirection.SendRecv:
          extendedExt.direction = RtpHeaderDirection.SendRecv;
          break;
        case RtpHeaderDirection.RecvOnly:
          extendedExt.direction = RtpHeaderDirection.SendOnly;
          break;
        case RtpHeaderDirection.SendOnly:
          extendedExt.direction = RtpHeaderDirection.RecvOnly;
          break;
        case RtpHeaderDirection.Inactive:
          extendedExt.direction = RtpHeaderDirection.Inactive;
          break;
      }

      extendedRtpCapabilities.headerExtensions.add(extendedExt);
    }

    return extendedRtpCapabilities;
  }

  /// Create RTP parameters for a Consumer for the RTP probator.
  static RtpParameters generateProbatorRtpparameters(
    RtpParameters videoRtpParameters,
  ) {
    // Clone given reference video RTP parameters.
    videoRtpParameters = RtpParameters.copy(videoRtpParameters);

    // This may throw.
    validateRtpParameters(videoRtpParameters);

    RtpParameters rtpParameters = RtpParameters(
      mid: RTP_PROBATOR_MID,
      codecs: [],
      headerExtensions: [],
      encodings: [RtpEncodingParameters(ssrc: RTP_PROBATOR_SSRC)],
      rtcp: RtcpParameters(cname: 'probator'),
    );

    rtpParameters.codecs.add(videoRtpParameters.codecs.first);
    rtpParameters.codecs.first.payloadType = RTP_PROBATOR_CODEC_PAYLOAD_TYPE;
    rtpParameters.headerExtensions = videoRtpParameters.headerExtensions;

    return rtpParameters;
  }

  /// Reduce given codecs by returning an array of codecs "compatible" with the
  /// given capability codec. If no capability codec is given, take the first
  /// one(s).
  ///
  /// Given codecs must be generated by ortc.getSendingRtpParameters() or
  /// ortc.getSendingRemoteRtpParameters().
  ///
  /// The returned array of codecs also include a RTX codec if available.
  static List<RtpCodecParameters> reduceCodecs(
    List<RtpCodecParameters> codecs,
    RtpCodecCapability capCodec,
  ) {
    List<RtpCodecParameters> filteredCodecs = [];

    // if no capability codec is given, take the first one (and RTX).
    if (capCodec == null) {
      filteredCodecs.add(codecs.first);

      if (codecs.length > 1 && isRtxCodec(codecs[1])) {
        filteredCodecs.add(codecs[1]);
      }
    } else {
      // Otherwise look for a compatible set of codecs.
      for (int idx = 0; idx < codecs.length; ++idx) {
        if (matchCodecs(aCodec: codecs[idx], bCodec: capCodec)) {
          filteredCodecs.add(codecs[idx]);

          if (isRtxCodec(codecs[idx + 1])) {
            filteredCodecs.add(codecs[idx + 1]);
          }

          break;
        }
      }

      if (filteredCodecs.isEmpty) {
        throw ('no matching codec found');
      }
    }

    return filteredCodecs;
  }

  /// Generate RTP parameters of the given kind suitable for the remote SDP answer.
  static RtpParameters getSendingRemoteRtpParameters(
    RTCRtpMediaType kind,
    ExtendedRtpCapabilities extendedRtpCapabilities,
  ) {
    RtpParameters rtpParameters = RtpParameters(
      mid: null,
      codecs: [],
      headerExtensions: [],
      encodings: [],
      rtcp: RtcpParameters(),
    );

    for (ExtendedRtpCodec extendedCodec in extendedRtpCapabilities.codecs) {
      if (extendedCodec.kind != kind) {
        continue;
      }

      RtpCodecParameters codec = RtpCodecParameters(
        mimeType: extendedCodec.mimeType,
        payloadType: extendedCodec.localPayloadType,
        clockRate: extendedCodec.clockRate,
        channels: extendedCodec.channels,
        parameters: extendedCodec.remoteParameters,
        rtcpFeedback: extendedCodec.rtcpFeedback,
      );

      rtpParameters.codecs.add(codec);

      // Add RTX codec.
      if (extendedCodec.localRtxPayloadType != null) {
        RtpCodecParameters rtxCodec = RtpCodecParameters(
          mimeType: '${RTCRtpMediaTypeExtension.value(kind)}/rtx',
          payloadType: extendedCodec.localRtxPayloadType,
          clockRate: extendedCodec.clockRate,
          parameters: {
            'apt': extendedCodec.localPayloadType,
          },
          rtcpFeedback: [],
        );

        rtpParameters.codecs.add(rtxCodec);
      }
    }

    for (ExtendedRtpHeaderExtension extendedExtension
        in extendedRtpCapabilities.headerExtensions) {
      // Ignore RTP extensions of a different kind and those not valid for sending.
      if ((extendedExtension.kind != null && extendedExtension.kind != kind) ||
          (extendedExtension.direction != RtpHeaderDirection.SendRecv &&
              extendedExtension.direction != RtpHeaderDirection.SendOnly)) {
        continue;
      }

      RtpHeaderExtensionParameters ext = RtpHeaderExtensionParameters(
        uri: extendedExtension.uri,
        id: extendedExtension.sendId,
        encrypt: extendedExtension.encrypt,
        parameters: {},
      );

      rtpParameters.headerExtensions.add(ext);
    }

    // Reduce codecs' RTCP feedback. Use Transport-CC if available, REMB otherwise.
    if (rtpParameters.headerExtensions.any((RtpHeaderExtensionParameters ext) =>
        ext.uri ==
        'http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01')) {
      for (RtpCodecParameters codec in rtpParameters.codecs) {
        codec.rtcpFeedback = (codec.rtcpFeedback ?? [])
            .where((RtcpFeedback fb) => fb.type != 'goog-remb')
            .toList();
      }
    } else if (rtpParameters.headerExtensions.any(
        (RtpHeaderExtensionParameters ext) =>
            ext.uri ==
            'http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time')) {
      for (RtpCodecParameters codec in rtpParameters.codecs) {
        codec.rtcpFeedback = (codec.rtcpFeedback ?? [])
            .where((RtcpFeedback fb) => fb.type != 'transport-cc')
            .toList();
      }
    } else {
      for (RtpCodecParameters codec in rtpParameters.codecs) {
        codec.rtcpFeedback = (codec.rtcpFeedback ?? [])
            .where((RtcpFeedback fb) =>
                fb.type != 'transport-cc' && fb.type != 'goog-remb')
            .toList();
      }
    }

    return rtpParameters;
  }

  /// Generate RTP capabilities for receiving media based on the given extended
  /// RTP capabilities.
  static RtpCapabilities getRecvRtpCapabilities(
      ExtendedRtpCapabilities extendedRtpCapabilities) {
    RtpCapabilities rtpCapabilities = RtpCapabilities(
      codecs: [],
      headerExtensions: [],
    );

    for (ExtendedRtpCodec extendedCodec in extendedRtpCapabilities.codecs) {
      RtpCodecCapability codec = RtpCodecCapability(
        mimeType: extendedCodec.mimeType,
        kind: extendedCodec.kind,
        preferredPayloadType: extendedCodec.remotePayloadType,
        clockRate: extendedCodec.clockRate,
        channels: extendedCodec.channels,
        parameters: extendedCodec.localParameters,
        rtcpFeedback: extendedCodec.rtcpFeedback,
      );

      rtpCapabilities.codecs.add(codec);

      // Add RTX codec.
      if (extendedCodec.remoteRtxPayloadType == null) {
        continue;
      }

      RtpCodecCapability rtxCodec = RtpCodecCapability(
        mimeType: '${RTCRtpMediaTypeExtension.value(extendedCodec.kind)}/rtx',
        kind: extendedCodec.kind,
        preferredPayloadType: extendedCodec.remoteRtxPayloadType,
        clockRate: extendedCodec.clockRate,
        parameters: {
          'apt': extendedCodec.remotePayloadType,
        },
        rtcpFeedback: [],
      );

      rtpCapabilities.codecs.add(rtxCodec);
    }

    // TODO: In the future, we need to add FEC, CN, etc, codecs.

    for (ExtendedRtpHeaderExtension extendedExtension
        in extendedRtpCapabilities.headerExtensions) {
      // Ignore RTP extensions not valid for receiving.
      if (extendedExtension.direction != RtpHeaderDirection.SendRecv &&
          extendedExtension.direction != RtpHeaderDirection.RecvOnly) {
        continue;
      }

      RtpHeaderExtension ext = RtpHeaderExtension(
        kind: extendedExtension.kind,
        uri: extendedExtension.uri,
        preferredId: extendedExtension.recvId,
        preferredEncrypt: extendedExtension.encrypt,
        direction: extendedExtension.direction,
      );

      rtpCapabilities.headerExtensions.add(ext);
    }

    return rtpCapabilities;
  }

  /// Generate RTP parameters of the given kind for sending media.
  /// NOTE: mid, encodings and rtcp fields are left empty.
  static RtpParameters getSendingRtpParameters(
    RTCRtpMediaType kind,
    ExtendedRtpCapabilities extendedRtpCapabilities,
  ) {
    RtpParameters rtpParameters = RtpParameters(
      mid: null,
      codecs: [],
      headerExtensions: [],
      encodings: [],
      rtcp: RtcpParameters(),
    );

    for (ExtendedRtpCodec extendedCodec in extendedRtpCapabilities.codecs) {
      if (extendedCodec.kind != kind) {
        continue;
      }

      RtpCodecParameters codec = RtpCodecParameters(
        mimeType: extendedCodec.mimeType,
        payloadType: extendedCodec.localPayloadType,
        clockRate: extendedCodec.clockRate,
        channels: extendedCodec.channels,
        parameters: extendedCodec.localParameters,
        rtcpFeedback: extendedCodec.rtcpFeedback,
      );

      rtpParameters.codecs.add(codec);

      // Add RTX codec.
      if (extendedCodec.localRtxPayloadType != null) {
        RtpCodecParameters rtxCodec = RtpCodecParameters(
          mimeType: '${RTCRtpMediaTypeExtension.value(extendedCodec.kind)}/rtx',
          payloadType: extendedCodec.localRtxPayloadType,
          clockRate: extendedCodec.clockRate,
          parameters: {
            'apt': extendedCodec.localPayloadType,
          },
          rtcpFeedback: [],
        );

        rtpParameters.codecs.add(rtxCodec);
      }
    }

    for (ExtendedRtpHeaderExtension extendedExtension
        in extendedRtpCapabilities.headerExtensions) {
      // Ignore RTP extensions of a different kind and those not valid for sending.
      if ((extendedExtension.kind != null && extendedExtension.kind != kind) ||
          (extendedExtension.direction != RtpHeaderDirection.SendRecv &&
              extendedExtension.direction != RtpHeaderDirection.SendOnly)) {
        continue;
      }

      RtpHeaderExtensionParameters ext = RtpHeaderExtensionParameters(
        uri: extendedExtension.uri,
        id: extendedExtension.sendId,
        encrypt: extendedExtension.encrypt,
        parameters: {},
      );

      rtpParameters.headerExtensions.add(ext);
    }

    return rtpParameters;
  }

  /// Whether media can be sent based on the given RTP capabilities.
  static bool canSend(
      RTCRtpMediaType kind, ExtendedRtpCapabilities extendedRtpCapabilities) {
    return extendedRtpCapabilities.codecs
        .any((ExtendedRtpCodec codec) => codec.kind == kind);
  }

  /// Whether the given RTP parameters can be received with the given RTP
  /// capabilities.
  static bool canReceive(
    RtpParameters rtpParameters,
    ExtendedRtpCapabilities extendedRtpCapabilities,
  ) {
    // This may throw.
    validateRtpParameters(rtpParameters);

    if (rtpParameters.codecs.isEmpty) {
      return false;
    }

    RtpCodecParameters firstMediaCodec = rtpParameters.codecs.first;

    return extendedRtpCapabilities.codecs.any((ExtendedRtpCodec codec) =>
        codec.remotePayloadType == firstMediaCodec.payloadType);
  }
}

class ExtendedRtpCapabilities {
  List<ExtendedRtpCodec> codecs;
  List<ExtendedRtpHeaderExtension> headerExtensions;

  ExtendedRtpCapabilities({
    this.codecs,
    this.headerExtensions,
  });
}
