import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/common/index.dart';

/*
 * Direction of RTP header extension.
 */
enum RtpHeaderDirection {
  SendRecv,
  SendOnly,
  RecvOnly,
  Inactive,
}

extension RtpHeaderExtensionDirection on RtpHeaderDirection {
  static const Map<String, RtpHeaderDirection> types = {
    'sendrecv': RtpHeaderDirection.SendRecv,
    'sendonly': RtpHeaderDirection.SendOnly,
    'recvonly': RtpHeaderDirection.RecvOnly,
    'inactive': RtpHeaderDirection.Inactive,
  };

  static const Map<RtpHeaderDirection, String> values = {
    RtpHeaderDirection.SendRecv: 'sendrecv',
    RtpHeaderDirection.SendOnly: 'sendonly',
    RtpHeaderDirection.RecvOnly: 'recvonly',
    RtpHeaderDirection.Inactive: 'inactive',
  };

  RtpHeaderDirection get type => types[this];
  String get value => values[this];
}

/*
 * Provides information on RTCP feedback messages for a specific codec. Those
 * messages can be transport layer feedback messages or codec-specific feedback
 * messages. The list of RTCP feedbacks supported by mediasoup is defined in the
 * supportedRtpCapabilities.ts file.
 */
class RtcpFeedback {
  String type;
  String parameter;

  RtcpFeedback({this.type, this.parameter});

  RtcpFeedback.fromMap(Map map) {
    this.type = map['type'];
    this.parameter = map['parameter'];
  }

  Map<String, String> toMap() {
    return {
      'type': this.type,
      'parameter': this.parameter,
    };
  }
}

class RtpCodecCapability {
  /*
	 * Media kind.
	 */
  final RTCRtpMediaType kind;
  /*
	 * The codec MIME media type/subtype (e.g. 'audio/opus', 'video/VP8').
	 */
  final String mimeType;
  /*
	 * The preferred RTP payload type.
	 */
  final int preferredPayloadType;
  /*
	 * Codec clock rate expressed in Hertz.
	 */
  final int clockRate;
  /*
	 * The number of channels supported (e.g. two for stereo). Just for audio.
	 * Default 1.
	 */
  final int channels;
  /*
	 * Codec specific parameters. Some parameters (such as 'packetization-mode'
	 * and 'profile-level-id' in H264 or 'profile-id' in VP9) are critical for
	 * codec matching.
	 */
  final Map<dynamic, dynamic> parameters;
  /*
	 * Transport layer and codec-specific feedback messages for this codec.
	 */
  final List<RtcpFeedback> rtcpFeedback;

  RtpCodecCapability({
    this.kind,
    this.mimeType,
    this.preferredPayloadType,
    this.clockRate,
    this.channels = 1,
    this.parameters,
    this.rtcpFeedback,
  });
}

class RtpHeaderExtension {
  /*
	 * Media kind. If empty string, it's valid for all kinds.
	 * Default any media kind.
	 */
  final RTCRtpMediaType kind;
  /*
  * The URI of the RTP header extension, as defined in RFC 5285.
  */
  final String uri;
  /*
  * The preferred numeric identifier that goes in the RTP packet. Must be
  * unique.
  */
  final int preferredId;
  /*
  * If true, it is preferred that the value in the header be encrypted as per
  * RFC 6904. Default false.
  */
  final bool preferredEncrypt;
  /*
	 * If 'sendrecv', mediasoup supports sending and receiving this RTP extension.
	 * 'sendonly' means that mediasoup can send (but not receive) it. 'recvonly'
	 * means that mediasoup can receive (but not send) it.
	 */
  final RtpHeaderDirection direction;

  RtpHeaderExtension({
    this.kind,
    this.uri,
    this.preferredId,
    this.preferredEncrypt,
    this.direction,
  });
}

class RtxSsrc {
  final int ssrc;

  RtxSsrc(this.ssrc);

  Map<String, int> toMap() {
    return {
      'ssrc': ssrc,
    };
  }
}

class RtpEncodingParameters extends RTCRtpEncoding {
  /*
	 * Codec payload type this encoding affects. If unset, first media codec is
	 * chosen.
	 */
  int codecPayloadType;
  /*
	 * RTX stream information. It must contain a numeric ssrc field indicating
	 * the RTX SSRC.
	 */
  RtxSsrc rtx;
  /*
	 * It indicates whether discontinuous RTP transmission will be used. Useful
	 * for audio (if the codec supports it) and for video screen sharing (when
	 * static content is being transmitted, this option disables the RTP
	 * inactivity checks in mediasoup). Default false.
	 */
  bool dtx;
  /*
	 * Number of spatial and temporal layers in the RTP stream (e.g. 'L1T3').
	 * See webrtc-svc.
	 */
  String scalabilityMode;

  /*
   * Others.
   */
  bool adaptivePtime;
  Priority priority;
  Priority netoworkPriority;

  RtpEncodingParameters({
    this.codecPayloadType,
    this.rtx,
    this.dtx,
    this.scalabilityMode,
    this.adaptivePtime,
    this.priority,
    this.netoworkPriority,
    bool active,
    int maxBitrate,
    int maxFramerate,
    int minBitrate,
    int numTemporalLayers,
    String rid,
    double scaleResolutionDownBy,
    int ssrc,
  }) : super(
          active: active,
          maxBitrate: maxBitrate,
          maxFramerate: maxFramerate,
          minBitrate: minBitrate,
          numTemporalLayers: numTemporalLayers,
          rid: rid,
          scaleResolutionDownBy: scaleResolutionDownBy,
          ssrc: ssrc,
        );
}

class RtcpParapeters extends RTCRTCPParameters {
  /*
	 * Whether RTCP-mux is used. Default true.
	 */
  final bool mux;

  RtcpParapeters({this.mux, String cname, bool reducedSize})
      : super(cname, reducedSize);

  factory RtcpParapeters.fromMap(Map<dynamic, dynamic> map) {
    return RtcpParapeters(
      cname: map['cname'],
      mux: map['mux'],
      reducedSize: map['reducedSize'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cname': cname,
      'reducedSize': reducedSize,
      'mux': mux,
    };
  }
}
