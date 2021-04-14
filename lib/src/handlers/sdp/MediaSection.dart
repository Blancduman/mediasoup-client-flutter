import 'package:mediasoup_client_flutter/src/Producer.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';

class Rtp {
  int payload;
  String codec;
  int rate;
  int encoding;

  Rtp({
    this.payload,
    this.codec,
    this.rate,
    this.encoding,
  });

  Rtp.fromMap(Map data) {
    payload = data['payload'];
    codec = data['codec'];
    rate = data['rate'];
    encoding = data['encoding'];
  }

  Map<String, dynamic> toMap() {
    return {
      'payload': payload,
      'codec': codec,
      'rate': rate,
      'encoding': encoding,
    };
  }
}

class Fmtp {
  int payload;
  String config;

  Fmtp({
    this.payload,
    this.config,
  });

  Fmtp.fromMap(Map data) {
    payload = data['payload'];
    config = data['config'];
  }

  Map<String, dynamic> toMap() {
    return {
      'payload': payload,
      'config': config,
    };
  }
}

class Connection {
  int version;
  String ip;

  Connection({this.version, this.ip});

  Connection.fromMap(Map data) {
    version = data['version'];
    ip = data['ip'];
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'ip': ip,
    };
  }
}

class Rtcp {
  int port;
  String netType;
  int ipVer;
  String address;

  Rtcp({
    this.port,
    this.netType,
    this.address,
    this.ipVer,
  });

  Rtcp.fromMap(Map data) {
    port = data['port'];
    netType = data['netType'];
    ipVer = data['ipVer'];
    address = data['address'];
  }

  Map<String, dynamic> toMap() {
    return {
      'port': port,
      'netType': netType,
      'ipVer': ipVer,
      'address': address,
    };
  }
}

class Fingerprint {
  String type;
  String hash;

  Fingerprint({
    this.type,
    this.hash,
  });

  Fingerprint.fromMap(Map data) {
    type = data['type'];
    hash = data['hash'];
  }

  Map<String, String> toMap() {
    return {
      'type': type,
      'hash': hash,
    };
  }
}

class Ext {
  int value;
  String direction;
  String uri;
  String config;

  Ext({
    this.value,
    this.direction,
    this.uri,
    this.config,
  });

  Ext.fromMap(Map data) {
    value = data['value'];
    direction = data['direction'];
    uri = data['uri'];
    config = data['config'];
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'direction': direction,
      'uri': uri,
      'config': config,
    };
  }
}

class RtcpFb {
  int payload;
  String type;
  String subtype;

  RtcpFb({
    this.payload,
    this.type,
    this.subtype,
  });
  RtcpFb.fromMap(Map data) {
    payload = data['payload'];
    type = data['type'];
    subtype = data['subtype'];
  }

  Map<String, dynamic> toMap() {
    return {
      'payload': payload,
      'type': type,
      'subtype': subtype,
    };
  }
}

class Ssrc {
  int id;
  String attribute;
  String value;

  Ssrc({
    this.id,
    this.attribute,
    this.value,
  });
  Ssrc.fromMap(Map data) {
    id = data['id'];
    attribute = data['attribute'];
    value = data['value'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attribute': attribute,
      'value': value,
    };
  }
}

class SsrcGroup {
  String semantics;
  String ssrcs;

  SsrcGroup({
    this.semantics,
    this.ssrcs,
  });

  SsrcGroup.fromMap(Map data) {
    semantics = data['semantics'];
    ssrcs = data['ssrcs'];
  }

  Map<String, String> toMap() {
    return {
      'semantics': semantics,
      'ssrcs': ssrcs,
    };
  }
}

class Sctpmap {
  String app;
  int sctpmanNumber;
  int maxMessageSize;

  Sctpmap({
    this.app,
    this.sctpmanNumber,
    this.maxMessageSize,
  });

  Sctpmap.fromMap(Map data) {
    app = data['app'];
    sctpmanNumber = data['sctpmanNumber'];
    maxMessageSize = data['maxMessageSize'];
  }

  Map<String, dynamic> toMap() {
    return {
      'app': app,
      'sctpmanNumber': sctpmanNumber,
      'maxMessageSize': maxMessageSize,
    };
  }
}

class Rid {
  var id;
  String direction;

  Rid({
    this.id,
    this.direction,
  });
}

class Simulcast {
  String dir1;
  var list1;

  Simulcast({
    this.dir1,
    this.list1,
  });
}

class Simulcast_03 {
  String value;

  Simulcast_03({this.value});
}

class MediaObject {
  List<IceCandidate> candidates;
  String iceUfrag;
  String icePwd;
  String endOfCandidates;
  String iceOptions;

  /// Always 'actpass'.
  String setup;
  int mid;
  int port;
  RtpHeaderDirection direction;
  List<Rtp> rtp;
  List<Fmtp> fmtp;
  String type;
  String protocol;
  String payloads;
  Connection connection;
  Rtcp rtcp;
  List<Ext> ext;
  String msid;
  String rtcpMux;
  List<RtcpFb> rtcpFb;
  List<Ssrc> ssrcs;
  List<SsrcGroup> ssrcGroups;
  Simulcast simulcast;
  Simulcast_03 simulcast_03;
  List<Rid> rids;
  String extmapAllowMixed;
  String rtcpRsize;
  int sctpPort;
  int maxMessageSize;
  Sctpmap sctpmap;
  String xGoogleFlag;

  MediaObject({
    this.candidates,
    this.iceUfrag,
    this.icePwd,
    this.endOfCandidates,
    this.iceOptions,
    this.setup,
    this.mid,
    this.port,
    this.direction,
    this.rtp,
    this.fmtp,
    this.type,
    this.protocol,
    this.payloads,
    this.connection,
    this.rtcp,
    this.ext,
    this.msid,
    this.rtcpMux,
    this.rtcpFb,
    this.ssrcs,
    this.extmapAllowMixed,
    this.rids,
    this.simulcast,
    this.simulcast_03,
    this.ssrcGroups,
    this.rtcpRsize,
    this.sctpPort,
    this.maxMessageSize,
    this.sctpmap,
    this.xGoogleFlag,
  });
}

abstract class MediaSection {
  MediaObject _mediaObject;
  bool _planB;

  MediaSection({
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    bool planB,
  }) {
    _mediaObject = MediaObject();
    _planB = planB;

    if (iceParameters != null) {
      setIceParameters(iceParameters);
    }

    if (iceParameters != null) {
      _mediaObject.candidates = [];

      _mediaObject.candidates = List<IceCandidate>.of(iceCandidates);
    }

    if (dtlsParameters != null) {
      setDtlsRole(dtlsParameters.role);
    }
  }

  MediaSection.fromMap(Map data) {
    IceParameters iceParameters = IceParameters.fromMap(data['iceParameters']);
    List<IceCandidate> iceCandidates = [];
    if (data['iceCandidates'] != null) {
      iceCandidates.addAll(data['iceCandidates']
          .map((iceC) => IceCandidate.fromMap(iceC))
          .toList());
    }

    _planB = data['planB'] == true;

    _mediaObject = MediaObject(
      candidates: iceCandidates,
      iceUfrag: iceParameters.usernameFragment,
      icePwd: iceParameters.password,
    );
  }

  void setIceParameters(IceParameters iceParameters) {
    _mediaObject.iceUfrag = iceParameters.usernameFragment;
    _mediaObject.icePwd = iceParameters.password;
  }

  MediaObject get getObject => _mediaObject;

  void setDtlsRole(DtlsRole role);

  String get mid => _mediaObject.mid.toString();

  bool get closed => _mediaObject.port == 0;

  void disable() {
    _mediaObject.direction = RtpHeaderDirection.Inactive;

    _mediaObject.ext = null;
    _mediaObject.ssrcs = null;
    _mediaObject.ssrcGroups = null;
    _mediaObject.simulcast = null;
    _mediaObject.simulcast_03 = null;
    _mediaObject.rids = null;
  }

  void close() {
    _mediaObject.direction = RtpHeaderDirection.Inactive;

    _mediaObject.port = 0;

    _mediaObject.ext = null;
    _mediaObject.ssrcs = null;
    _mediaObject.ssrcGroups = null;
    _mediaObject.simulcast = null;
    _mediaObject.simulcast_03 = null;
    _mediaObject.rids = null;
    _mediaObject.extmapAllowMixed = null;
  }
}

class AnswerMediaSection extends MediaSection {
  AnswerMediaSection({
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    SctpParameters sctpParameters,
    PlainRtpParameters plainRtpParameters,
    bool planB,
    MediaObject offerMediaObject,
    RtpParameters offerRtpParameters,
    RtpParameters answerRtpParameters,
    ProducerCodecOptions codecOptions,
    bool extmapAllowMixed,
  }) : super(
          dtlsParameters: dtlsParameters,
          iceParameters: iceParameters,
          iceCandidates: iceCandidates,
          planB: planB,
        ) {
    _mediaObject.mid = int.parse(mid);
    _mediaObject.type = offerMediaObject.type;
    _mediaObject.protocol = offerMediaObject.protocol;

    if (plainRtpParameters == null) {
      _mediaObject.connection = Connection(
        ip: '127.0.0.1',
        version: 4,
      );
      _mediaObject.port = 7;
    } else {
      _mediaObject.connection = Connection(
        ip: plainRtpParameters.ip,
        version: plainRtpParameters.ipVersion,
      );
      _mediaObject.port = plainRtpParameters.port;
    }

    switch (offerMediaObject.type) {
      case 'audio':
      case 'video':
        {
          _mediaObject.direction =
              RtpHeaderExtensionDirection.fromString('recvonly');
          _mediaObject.rtp = <Rtp>[];
          _mediaObject.rtcpFb = <RtcpFb>[];
          _mediaObject.fmtp = <Fmtp>[];

          for (RtpCodecParameters codec in answerRtpParameters.codecs) {
            Rtp rtp = Rtp(
              payload: codec.payloadType,
              codec: getCodecName(codec),
              rate: codec.clockRate,
            );

            if (codec.channels > 1) {
              rtp.encoding = codec.channels;
            }

            _mediaObject.rtp.add(rtp);

            CodecParameters codecParameters =
                CodecParameters.copy(codec.parameters);

            if (codecOptions != null) {
              bool opusStereo = codecOptions.opusStereo;
              bool opusFec = codecOptions.opusFec;
              bool opusDtx = codecOptions.opusDtx;
              int opusMaxPlaybackRate = codecOptions.opusMaxPlaybackRate;
              int opusMaxAverageBitrate = codecOptions.opusMaxAverageBitrate;
              int opusPtime = codecOptions.opusPtime;
              int videoGoogleStartBitrate =
                  codecOptions.videoGoogleStartBitrate;
              int videoGoogleMaxBitrate = codecOptions.videoGoogleMaxBitrate;
              int videoGoogleMinBitrate = codecOptions.videoGoogleMinBitrate;

              RtpCodecParameters offerCodec = offerRtpParameters.codecs
                  .firstWhere(
                      (RtpCodecParameters c) =>
                          c.payloadType == codec.payloadType,
                      orElse: () => null);
/*
CodecParameters {
  int spropStereo; // sprop-stereo;
  int stereo;
  int useinbandfec;
  int usedtx;
  int maxplaybackrate;
  int maxaveragebitrate;
  int ptime;
  int xGoogleStartBitrate // x-google-start-bitrate;
  int xGoogleMaxBitrate // x-google-max-bitrate;
  int xGoogleMinBitrate // x-google-min-bitrate;
}
*/
              switch (codec.mimeType.toLowerCase()) {
                case 'audio/opus':
                  {
                    if (opusStereo != null) {
                      offerCodec.parameters.spropStereo = opusStereo ? 1 : 0;
                      codecParameters.stereo = opusStereo ? 1 : 0;
                    }

                    if (opusFec != null) {
                      offerCodec.parameters.useinbandfec = opusFec ? 1 : 0;
                      codecParameters.useinbandfec = opusFec ? 1 : 0;
                    }

                    if (opusDtx != null) {
                      offerCodec.parameters.usedtx = opusDtx ? 1 : 0;
                      codecParameters.usedtx = opusDtx ? 1 : 0;
                    }

                    if (opusMaxPlaybackRate != null) {
                      codecParameters.maxplaybackrate = opusMaxPlaybackRate;
                    }

                    if (opusMaxAverageBitrate != null) {
                      codecParameters.maxaveragebitrate = opusMaxAverageBitrate;
                    }

                    if (opusPtime != null) {
                      offerCodec.parameters.ptime = opusPtime;
                      codecParameters.ptime = opusPtime;
                    }

                    break;
                  }

                case 'video/vp8':
                case 'video/vp9':
                case 'video/h264':
                case 'video/h265':
                  {
                    if (videoGoogleStartBitrate != null) {
                      codecParameters.xGoogleStartBitrate =
                          videoGoogleStartBitrate;
                    }

                    if (videoGoogleMaxBitrate != null) {
                      codecParameters.xGoogleMaxBitrate = videoGoogleMaxBitrate;
                    }

                    if (videoGoogleMinBitrate != null) {
                      codecParameters.xGoogleMinBitrate = videoGoogleMinBitrate;
                    }
                    break;
                  }
              }
            }

            Fmtp fmtp = Fmtp(
              payload: codec.payloadType,
              config: '',
            );

            for (String key in codecParameters.keys) {
              if (fmtp.config != null && fmtp.config.isNotEmpty) {
                fmtp.config += ';';
              }

              fmtp.config += '$key=${codecParameters[key]}';
            }

            if (fmtp.config != null && fmtp.config.isNotEmpty) {
              _mediaObject.fmtp.add(fmtp);
            }

            for (RtcpFeedback fb in codec.rtcpFeedback) {
              _mediaObject.rtcpFb.add(RtcpFb(
                payload: codec.payloadType,
                type: fb.type,
                subtype: fb.parameter,
              ));
            }
          }

          _mediaObject.payloads = answerRtpParameters.codecs
              .map((RtpCodecParameters codec) => codec.payloadType)
              .toList()
              .join(' ');

          _mediaObject.ext = <Ext>[];

          for (RtpHeaderExtensionParameters ext
              in answerRtpParameters.headerExtensions) {
            // Don't add a header extension if not present in the offer.
            bool found = (offerMediaObject.ext ?? [])
                .any((Ext localExt) => localExt.uri == ext.uri);

            if (!found) {
              continue;
            }

            _mediaObject.ext.add(Ext(
              uri: ext.uri,
              value: ext.id,
            ));
          }

          // Allow both 1 byte and 2 bytes length header extensions.
          if (extmapAllowMixed &&
              offerMediaObject.extmapAllowMixed == 'extmap-allow-mixed') {
            _mediaObject.extmapAllowMixed = 'extmap-allow-mixed';
          }

          // Simulcast.
          if (offerMediaObject.simulcast != null) {
            _mediaObject.simulcast = Simulcast(
              dir1: 'recv',
              list1: offerMediaObject.simulcast.list1,
            );

            _mediaObject.rids = <Rid>[];

            for (Rid rid in offerMediaObject.rids ?? []) {
              if (rid.direction != 'send') {
                continue;
              }

              _mediaObject.rids.add(Rid(
                id: rid.id,
                direction: 'recv',
              ));
            }
          } else if (offerMediaObject.simulcast_03 != null) {
            // Simulcast (draft version 03).
            _mediaObject.simulcast_03 = Simulcast_03(
              value: offerMediaObject.simulcast_03.value
                  .replaceAll(RegExp(r'/send/g'), 'recv'),
            );

            _mediaObject.rids = <Rid>[];

            for (Rid rid in offerMediaObject.rids ?? []) {
              if (rid.direction != 'send') {
                continue;
              }

              _mediaObject.rids.add(Rid(
                id: rid.id,
                direction: 'recv',
              ));
            }
          }

          _mediaObject.rtcpMux = 'rtcp-mux';
          _mediaObject.rtcpRsize = 'rtcp-rsize';

          if (_planB && _mediaObject.type == 'video') {
            _mediaObject.xGoogleFlag = 'conference';
          }
          break;
        }

      case 'application':
        {
          // New spec.
          if (offerMediaObject.sctpPort is int) {
            _mediaObject.payloads = 'webrtc-datachannel';
            _mediaObject.sctpPort = sctpParameters.port;
            _mediaObject.maxMessageSize = sctpParameters.maxMessageSize;
          } else if (offerMediaObject.sctpmap != null) {
            // Old spec.
            _mediaObject.payloads = sctpParameters.port.toString();
            _mediaObject.sctpmap = Sctpmap(
              app: 'webrtc-datachannel',
              sctpmanNumber: sctpParameters.port,
              maxMessageSize: sctpParameters.maxMessageSize,
            );
          }

          break;
        }
    }
  }

  @override
  void setDtlsRole(DtlsRole role) {
    switch (role) {
      case DtlsRole.client:
        {
          _mediaObject.setup = 'active';
          break;
        }
      case DtlsRole.server:
        {
          _mediaObject.setup = 'passive';
          break;
        }
      case DtlsRole.auto:
        {
          _mediaObject.setup = 'actpass';
          break;
        }
    }
  }
}

class OfferMediaSection extends MediaSection {
  OfferMediaSection({
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    SctpParameters sctpParameters,
    PlainRtpParameters plainRtpParameters,
    bool planB,
    String mid,
    String kind,
    RtpParameters offerRtpParameters,
    String streamId,
    String trackId,
    bool oldDataChannelSpec = false,
  }) : super(
          planB: planB,
          dtlsParameters: dtlsParameters,
          iceCandidates: iceCandidates,
          iceParameters: iceParameters,
        ) {
    _mediaObject.mid = int.parse(mid);
    _mediaObject.type = kind;

    if (plainRtpParameters == null) {
      _mediaObject.connection = Connection(
        ip: '127.0.0.1',
        version: 4,
      );

      if (sctpParameters != null) {
        _mediaObject.protocol = 'UDP/TLS/RTP/SAVPF';
      } else {
        _mediaObject.protocol = 'UDP/DTLS/SCTP';
      }

      _mediaObject.port = 7;
    } else {
      _mediaObject.connection = Connection(
        ip: plainRtpParameters.ip,
        version: plainRtpParameters.ipVersion,
      );
      _mediaObject.protocol = 'RTP/AVP';
      _mediaObject.port = plainRtpParameters.port;
    }

    switch (kind) {
      case 'audio':
      case 'video':
        {
          _mediaObject.direction =
              RtpHeaderExtensionDirection.fromString('sendonly');
          _mediaObject.rtp = <Rtp>[];
          _mediaObject.rtcpFb = <RtcpFb>[];
          _mediaObject.fmtp = <Fmtp>[];

          if (!_planB) {
            _mediaObject.msid = '${streamId ?? '-'} $trackId';
          }

          for (RtpCodecParameters codec in offerRtpParameters.codecs) {
            Rtp rtp = Rtp(
              payload: codec.payloadType,
              codec: getCodecName(codec),
              rate: codec.clockRate,
            );

            if (codec.channels > 1) {
              rtp.encoding = codec.channels;
            }

            _mediaObject.rtp.add(rtp);

            Fmtp fmtp = Fmtp(
              payload: codec.payloadType,
              config: '',
            );

            for (String key in codec.parameters.keys) {
              if (fmtp.config != null && fmtp.config.isNotEmpty) {
                fmtp.config += ';';
              }

              fmtp.config += '$key=${codec.parameters[key]}';
            }

            if (fmtp.config != null && fmtp.config.isNotEmpty) {
              _mediaObject.fmtp.add(fmtp);
            }

            for (RtcpFeedback fb in codec.rtcpFeedback) {
              _mediaObject.rtcpFb.add(RtcpFb(
                  payload: codec.payloadType,
                  type: fb.type,
                  subtype: fb.parameter));
            }
          }

          _mediaObject.payloads = offerRtpParameters.codecs
              .map((RtpCodecParameters codec) => codec.payloadType)
              .toList()
              .join(' ');

          _mediaObject.ext = <Ext>[];

          for (RtpHeaderExtensionParameters ext
              in offerRtpParameters.headerExtensions) {
            _mediaObject.ext.add(Ext(
              uri: ext.uri,
              value: ext.id,
            ));
          }

          _mediaObject.rtcpMux = 'rtcp-mux';
          _mediaObject.rtcpRsize = 'rtcp-rsize';

          RtpEncodingParameters encoding = offerRtpParameters.encodings.first;
          int ssrc = encoding.ssrc;
          int rtxSsrc = (encoding.rtx != null && encoding.rtx.ssrc != null)
              ? encoding.rtx.ssrc
              : null;

          _mediaObject.ssrcs = <Ssrc>[];
          _mediaObject.ssrcGroups = [];

          if (offerRtpParameters.rtcp.cname != null &&
              offerRtpParameters.rtcp.cname.isNotEmpty) {
            _mediaObject.ssrcs.add(Ssrc(
              id: ssrc,
              attribute: 'cname',
              value: offerRtpParameters.rtcp.cname,
            ));
          }

          if (_planB) {
            _mediaObject.ssrcs.add(Ssrc(
              id: ssrc,
              attribute: 'msid',
              value: '${streamId ?? '-'} $trackId',
            ));
          }

          if (rtxSsrc != null) {
            if (offerRtpParameters.rtcp.cname != null &&
                offerRtpParameters.rtcp.cname.isNotEmpty) {
              _mediaObject.ssrcs.add(Ssrc(
                id: rtxSsrc,
                attribute: 'cname',
                value: offerRtpParameters.rtcp.cname,
              ));
            }

            if (_planB) {
              _mediaObject.ssrcs.add(Ssrc(
                id: rtxSsrc,
                attribute: 'msid',
                value: '${streamId ?? '-'} $trackId',
              ));
            }

            // Associate original and retransmission SSRCs.
            _mediaObject.ssrcGroups.add(SsrcGroup(
              semantics: 'FID',
              ssrcs: '$ssrc $rtxSsrc',
            ));
          }

          break;
        }

      case 'application':
        {
          // New spec.
          if (!oldDataChannelSpec) {
            _mediaObject.payloads = 'webrtc-datachannel';
            _mediaObject.sctpPort = sctpParameters.port;
            _mediaObject.maxMessageSize = sctpParameters.maxMessageSize;
          } else {
            _mediaObject.payloads = sctpParameters.port.toString();
            _mediaObject.sctpmap = Sctpmap(
              app: 'webrtc-datachannel',
              sctpmanNumber: sctpParameters.port,
              maxMessageSize: sctpParameters.maxMessageSize,
            );
          }

          break;
        }
    }
  }

  OfferMediaSection.fromMap(Map data) : super.fromMap(data);

  @override
  void setDtlsRole(DtlsRole role) {
    // Always 'actpass'. ╾━╤デ╦︻(▀̿Ĺ̯▀̿ ̿)
    _mediaObject.setup = 'actpass';
  }

  void planBReceive({
    RtpParameters offerRtpParameters,
    String streamId,
    String trackId,
  }) {
    RtpEncodingParameters encoding = offerRtpParameters.encodings.first;
    int ssrc = encoding.ssrc;
    int rtxSsrc = (encoding.rtx != null && encoding.rtx.ssrc != null)
        ? encoding.rtx.ssrc
        : null;

    if (offerRtpParameters.rtcp.cname != null) {
      _mediaObject.ssrcs.add(Ssrc(
        id: ssrc,
        attribute: 'cname',
        value: offerRtpParameters.rtcp.cname,
      ));
    }

    _mediaObject.ssrcs.add(Ssrc(
      id: ssrc,
      attribute: 'cname',
      value: offerRtpParameters.rtcp.cname,
    ));

    if (rtxSsrc != null) {
      if (offerRtpParameters.rtcp.cname != null &&
          offerRtpParameters.rtcp.cname.isNotEmpty) {
        _mediaObject.ssrcs.add(Ssrc(
          id: rtxSsrc,
          attribute: 'cname',
          value: offerRtpParameters.rtcp.cname,
        ));
      }

      _mediaObject.ssrcs.add(Ssrc(
        id: rtxSsrc,
        attribute: 'msid',
        value: '${streamId ?? '-'} $trackId',
      ));

      // Associate original and retransmission SSRCs.
      _mediaObject.ssrcGroups.add(SsrcGroup(
        semantics: 'FID',
        ssrcs: '$ssrc $rtxSsrc',
      ));
    }
  }

  void planBStopReceiving({
    RtpParameters offerRtpParameters,
  }) {
    RtpEncodingParameters encoding = offerRtpParameters.encodings.first;
    int ssrc = encoding.ssrc;
    int rtxSsrc = (encoding.rtx != null && encoding.rtx.ssrc != null)
        ? encoding.rtx.ssrc
        : null;

    _mediaObject.ssrcs = _mediaObject.ssrcs
        .where((Ssrc s) => s.id != ssrc && s.id != rtxSsrc)
        .toList();

    if (rtxSsrc != null) {
      _mediaObject.ssrcGroups = _mediaObject.ssrcGroups
          .where((SsrcGroup group) => group.ssrcs != '$ssrc $rtxSsrc')
          .toList();
    }
  }
}

String getCodecName(RtpCodecParameters codec) {
  RegExp mimeTypeRegex = RegExp(r"^(audio|video)/(.+)", caseSensitive: true);
  Iterable<RegExpMatch> mimeTypeMatch =
      mimeTypeRegex.allMatches(codec.mimeType);

  if (mimeTypeMatch == null) {
    throw ('invalid codec.mimeType');
  }

  return mimeTypeMatch.elementAt(0).group(2);
}
