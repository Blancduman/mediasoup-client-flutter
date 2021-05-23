import 'package:mediasoup_client_flutter/SdpTransform/Parser.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/SdpObject.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/MediaSection.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';

class CommonUtils {
  static RtpCapabilities extractRtpCapabilities(SdpObject sdpObject) {
    // Map of RtpCodecParameters indexed by payload type.
    Map<int, RtpCodecCapability> codecsMap = <int, RtpCodecCapability>{};
    // Array of RtpHeaderExtensions.
    List<RtpHeaderExtension> headerExtensions = <RtpHeaderExtension>[];
    // Whether a m=audio/video section has been already found.
    bool gotAudio = false;
    bool gotVideo = false;

    for (MediaObject m in sdpObject.media) {
      String kind = m.type;

      switch (kind) {
        case 'audio': {
          if (gotAudio){
            continue;
          }
          gotAudio = true;
          break;
          }
        case 'video': {
          if (gotVideo) {
            continue;
          }
          gotVideo = true;
          break;
        }
        default: {
          continue;
        }
      }

      // Get codecs.
      for (Rtp rtp in m.rtp) {
        RtpCodecCapability codec = RtpCodecCapability(
          kind: RTCRtpMediaTypeExtension.fromString(kind),
          mimeType: '$kind/${rtp.codec}',
          preferredPayloadType: rtp.payload,
          clockRate: rtp.rate,
          channels: rtp.encoding,
          parameters: {},
          rtcpFeedback: [],
        );

        codecsMap[codec.preferredPayloadType] = codec;
      }

      // Get codec parameters.
      for (Fmtp fmtp in m.fmtp ?? []) {
        Map<dynamic, dynamic> parameters = parseParams(fmtp.config);
        RtpCodecCapability codec = codecsMap[fmtp.payload];

        if (codec == null) {
          continue;
        }

        // Specials case to convert parameter value to string.
        if (parameters != null && parameters['profile-level-id'] != null) {
          parameters['profile-level-id'] = '${parameters['profile-level-id']}';
        }

        codec.parameters = parameters;
      }

      // Get RTCP feedback for each codec.
      for (RtcpFb fb in m.rtcpFb ?? []) {
        RtpCodecCapability codec = codecsMap[fb.payload];

        if (codec == null) {
          continue;
        }

        RtcpFeedback feedback = RtcpFeedback(type: fb.type, parameter: fb.subtype,);

        // if (feedback.parameter == null || feedback.parameter.isEmpty) {
        //   feedback.parameter = null;
        // }
        
        codec.rtcpFeedback.add(feedback);
      }

      // Get RTP header extensions.
      for (Ext ext in m.ext ?? []) {
        // Ignore encrypted extensions (not yet supported in mediasoup).
        if (ext.encryptUri != null && ext.encryptUri.isNotEmpty) {
          continue;
        }

        RtpHeaderExtension headerExtension = RtpHeaderExtension(kind: RTCRtpMediaTypeExtension.fromString(kind), uri: ext.uri, preferredId: ext.value,);

        headerExtensions.add(headerExtension);
      }
    }

    RtpCapabilities rtpCapabilities = RtpCapabilities(
      codecs: List<RtpCodecCapability>.of(codecsMap.values),
      headerExtensions:  headerExtensions,
    );

    return rtpCapabilities;
  }

  static DtlsParameters extractDtlsParameters(SdpObject sdpObject) {
    MediaObject mediaObject = (sdpObject.media ?? [])
      .firstWhere((m) =>
       m.iceUfrag != null && m.iceUfrag.isNotEmpty && m.port != null && m.port != 0,
       orElse: () => null,
      );
    if (mediaObject == null) {
      throw('no active media section found');
    }

    Fingerprint fingerprint = mediaObject.fingerprint ?? sdpObject.fingerprint;

    DtlsRole role;

    switch (mediaObject.setup) {
      case 'active':
        role = DtlsRole.client;
        break;
      case 'passive':
        role = DtlsRole.server;
        break;
      case 'actpass':
        role = DtlsRole.auto;
        break;
    }

    DtlsParameters dtlsParameters = DtlsParameters(
      role: role,
      fingerprints: [
        DtlsFingerprint(
          algorithm: fingerprint.type,
          value: fingerprint.hash,
        ),
      ],
    );

    return dtlsParameters;
  }

  static String getCname(MediaObject offerMediaObject) {
    Ssrc ssrcCnameLine = (offerMediaObject.ssrcs ?? [])
      .firstWhere((Ssrc ssrc) => ssrc.attribute == 'cname',
      orElse: () => Ssrc(value: ''),
      );

    return ssrcCnameLine.value;
  }

  /// Apply codec parameters in the given SDP m= section answer based on the
  /// given RTP parameters of an offer.
  static void applyCodecParameters(RtpParameters offerRtpParameters, MediaObject answerMediaObject,) {
    for (RtpCodecParameters codec in offerRtpParameters.codecs) {
      String mimeType = codec.mimeType.toLowerCase();

      // Avoid parsing codec parameters for unhandled codecs.
      if (mimeType != 'audio/opus') {
        continue;
      }

      Rtp rtp = (answerMediaObject.rtp ?? [])
        .firstWhere((Rtp r) => r != null && r.payload == codec.payloadType, orElse: () => null,);

      if (rtp == null) {
        continue;
      }

      // Just in case.. ?
      answerMediaObject.fmtp = answerMediaObject.fmtp ?? [];

      Fmtp fmtp = answerMediaObject.fmtp
        .firstWhere((Fmtp f) => f != null && f.payload == codec.payloadType, orElse: () => null,);
      
      if (fmtp == null) {
        fmtp = Fmtp(payload: codec.payloadType, config: '',);
        answerMediaObject.fmtp.add(fmtp);
      }

      Map<dynamic, dynamic> parameters = parseParams(fmtp.config);

      switch (mimeType) {
        case 'audio/opus': {
          int spropStereo = codec.parameters['sprop-stereo'];

          if (spropStereo != null) {
            parameters['stereo'] = spropStereo > 0 ? 1 : 0;
          }
          break;
        }
          
        default: break;
      }
      
      // Write the codec fmtp.config back.
      fmtp.config = '';

      for (String key in parameters.keys) {
        if (fmtp.config.isNotEmpty) {
          fmtp.config += ';';
        }

        fmtp.config += '$key=${parameters[key]}';
      }
    }
  }
}