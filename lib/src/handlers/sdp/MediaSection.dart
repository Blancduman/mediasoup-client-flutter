import 'package:mediasoup_client_flutter/src/Producer.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/SdpObject.dart';
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
  String encryptUri;

  Ext({
    this.value,
    this.direction,
    this.uri,
    this.config,
    this.encryptUri,
  });

  Ext.fromMap(Map data) {
    value = data['value'];
    direction = data['direction'];
    uri = data['uri'];
    config = data['config'];
    encryptUri = data['encrypt-uri'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {
      if (value != null)
      'value': value,
      if (direction != null)
      'direction': direction,
      if (uri != null)
      'uri': uri,
      if (config != null)
      'config': config,
    };
    if (encryptUri != null && encryptUri.isNotEmpty) {
      result['encrypt-uri'] = encryptUri;
    }
    return result;
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
  int id;
  String direction;
  String params;

  Rid({
    this.id,
    this.direction,
    this.params,
  });

  Rid.fromMap(Map data) {
    id = data['id'];
    direction = data['direction'];
    params = data['params'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'direction': direction,
      'params': params,
    };
  }
}

class Simulcast {
  String dir1;
  String list1;
  String dir2;
  String list2;

  Simulcast({
    this.dir1,
    this.list1,
    this.dir2,
    this.list2,
  });

  Simulcast.fromMap(Map data) {
    dir1 = data['dir1'];
    list1 = data['list1'];
    dir2 = data['dir2'];
    list2 = data['list2'];
  }

  Map<String, String> toMap() {
    return {
      'dir1': dir1,
      'list1': list1,
      'dir2': dir2,
      'list2': list2,
    };
  }
}

class Simulcast_03 {
  String value;

  Simulcast_03({this.value});

  Simulcast_03.fromMap(Map data) {
    value = data['value'];
  }

  Map<String, String> toMap() {
    return {
      'value': value,
    };
  }
}

class RtcpFbTrrInt {
  int payload;
  int value;

  RtcpFbTrrInt({
    this.payload,
    this.value,
  });

  RtcpFbTrrInt.fromMap(Map data) {
    payload = data['payload'];
    value = data['value'];
  }

  Map<String, int> toMap() {
    return {
      'payload': payload,
      'value': value,
    };
  }
}

class Crypto {
  int id;
  String suite;
  String config;
  var sessionConfig;

  Crypto({
    this.id,
    this.suite,
    this.config,
    this.sessionConfig,
  });

  Crypto.fromMap(Map data) {
    id = data['id'];
    suite = data['suite'];
    config = data['config'];
    sessionConfig = data['sessionConfig'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'suite': suite,
      'config': config,
      'sessionConfig': sessionConfig,
    };
  }
}

class Bandwidth {
  String type;
  int limit;

  Bandwidth({this.type, this.limit,});

  Bandwidth.fromMap(Map data) {
    type = data['type'];
    limit = data['limit'];
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'limit': limit,
    };
  }
}

class Imageattrs {
  int pt;
  String dir1;
  String attrs1;
  String dir2;
  String attrs2;

  Imageattrs({
    this.pt,
    this.dir1,
    this.attrs1,
    this.dir2,
    this.attrs2,
  });

  Imageattrs.fromMap(Map data) {
    pt = data['pt'];
    dir1 = data['dir1'];
    attrs1 = data['attrs1'];
    dir2 = data['dir2'];
    attrs2 = data['attrs2'];
  }

  Map<String, dynamic> toMap() {
    return {
      'pt': pt,
      'dir1': dir1,
      'attrs1': attrs1,
      'dir2': dir2,
      'attrs2': attrs2,
    };
  }
}

class SourceFilter {
  String filterMode;
  String netType;
  String addressTypes;
  String destAddress;
  String srcList;

  SourceFilter({
    this.filterMode,
    this.netType,
    this.addressTypes,
    this.destAddress,
    this.srcList,
  });

  SourceFilter.fromMap(Map data) {
    this.filterMode = data['filterMode'];
    this.netType = data['netType'];
    this.addressTypes = data['addressTypes'];
    this.destAddress = data['destAddress'];
    this.srcList = data['srcList'];
  }

  Map<String, String> toMap() {
    return {
      'filterMode': filterMode,
      'netType': netType,
      'addressTypes': addressTypes,
      'destAddress': destAddress,
      'srcList': srcList,
    };
  }
}

class MediaObject {
  List<IceCandidate> candidates;
  String iceUfrag;
  String icePwd;
  String endOfCandidates;
  String iceOptions;

  /// Always 'actpass'.
  String setup;
  String mid;
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
  Fingerprint fingerprint;
  List<RtcpFbTrrInt> rtcpFbTrrInt;
  List<Crypto> crypto;
  List<Invalid> invalid;
  int ptime;
  int maxptime;
  int label;
  List<Bandwidth> bandwidth;
  String framerate;
  String bundleOnly;
  List<Imageattrs> imageattrs;
  SourceFilter sourceFilter;
  String description;

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
    this.fingerprint,
    this.rtcpFbTrrInt,
    this.invalid,
    this.ptime,
    this.maxptime,
    this.label,
    this.bandwidth,
    this.framerate,
    this.bundleOnly,
    this.imageattrs,
    this.sourceFilter,
    this.description,
  });

  MediaObject.fromMap(Map data) {
    if (data['candidates'] != null) {
      candidates = List<IceCandidate>.from((data['candidates'] ?? []).map((candidate) => IceCandidate.fromMap(candidate)).toList());
    }
    if (data['iceUfrag'] != null) {
      iceUfrag = data['iceUfrag'];
    }
    if (data['icePwd'] != null) {
      icePwd = data['icePwd'];
    }
    if (data['endOfCandidates'] != null) {
      endOfCandidates = data['endOfCandidates'];
    }
    if (data['iceOptions'] != null) {
      iceOptions = data['iceOptions'];
    }
    if (data['setup'] != null) {
      setup = data['setup'];
    }
    if (data['mid'] != null) {
      mid = data['mid'].toString();
    }
    if (data['port'] != null) {
      port = data['port'];
    }
    if (data['direction'] != null) {
      direction = RtpHeaderDirectionExtension.fromString(data['direction']);
    }
    if (data['rtp'] != null) {
      rtp = List<Rtp>.from((data['rtp'] ?? <Rtp>[]).map((r) => Rtp.fromMap(r)).toList());
    }
    if (data['fmtp'] != null) {
      fmtp = List<Fmtp>.from((data['fmtp'] ?? []).map((f) => Fmtp.fromMap(f)).toList());
    }
    if (data['type'] != null) {
      type = data['type'];
    }
    if (data['protocol'] != null) {
      protocol = data['protocol'];
    }
    if (data['payloads'] != null) {
      payloads = '${data['payloads']}';
    }
    if (data['connection'] != null) {
      connection = Connection.fromMap(data['connection']);
    }
    if (data['rtcp'] != null) {
      rtcp = Rtcp.fromMap(data['rtcp']);
    }
    if (data['ext'] != null) {
      ext = List<Ext>.from((data['ext'] ?? []).map((e) => Ext.fromMap(e)).toList());
    }
    if (data['msid'] != null) {
      msid = data['msid'];
    }
    if (data['rtcpMux'] != null) {
      rtcpMux = data['rtcpMux'];
    }
    if (data['rtcpFb'] != null) {
      rtcpFb = List<RtcpFb>.from((data['rtcpFb'] ?? []).map((r) => RtcpFb.fromMap(r)).toList());
    }
    if (data['ssrcs'] != null) {
      ssrcs = List<Ssrc>.from((data['ssrcs'] ?? []).map((ssrc) => Ssrc.fromMap(ssrc)).toList());
    }
    if (data['ssrcGroups'] != null) {
      ssrcGroups = List<SsrcGroup>.from((data['ssrcGroups'] ?? []).map((ssrcGroup) => SsrcGroup.fromMap(ssrcGroup)).toList());
    }
    if (data['simulcast'] != null) {
      simulcast = Simulcast.fromMap(data['simulcast']);
    }
    if (data['simulcast_03'] != null) {
      simulcast_03 = Simulcast_03.fromMap(data['simulcast_03']);
    }
    if (data['rids'] != null) {
      rids = List<Rid>.from((data['rids'] ?? []).map((r) => Rid.fromMap(r)).toList());
    }
    if (data['extmapAllowMixed'] != null) {
      extmapAllowMixed = data['extmapAllowMixed'];
    }
    if (data['rtcpRsize'] != null) {
      rtcpRsize = data['rtcpRsize'];
    }
    if (data['sctpPort'] != null) {
      sctpPort = data['sctpPort'];
    }
    if (data['maxMessageSize'] != null) {
      maxMessageSize = data['maxMessageSize'];
    }
    if (data['sctpmap'] != null) {
      sctpmap = Sctpmap.fromMap(data['sctpmap']);
    }
    if (data['xGoogleFlag'] != null) {
      xGoogleFlag = data['xGoogleFlag'];
    }
    if (data['fingerprint'] != null) {
      fingerprint = Fingerprint.fromMap(data['fingerprint']);
    }
    if (data['rtcpFbTrrInt'] != null) {
      rtcpFbTrrInt = List<RtcpFbTrrInt>.from((data['rtcpFbTrrInt'] ?? []).map((rFTI) => RtcpFbTrrInt.fromMap(data['rtcpFbTrrInt'])).toList());
    }
    if (data['crypto'] != null) {
      crypto = List<Crypto>.from((data['crypto'] ?? []).map((c) => Crypto.fromMap(c)).toList());
    }
    if (data['invalid'] != null) {
      invalid = List<Invalid>.from((data['invalid'] ?? []).map((i) => Invalid.fromMap(i)).toList());
    }
    if (data['ptime'] != null) {
      ptime = data['ptime'];
    }
    if (data['maxptime'] != null) {
      maxptime = data['maxptime'];
    }
    if (data['label'] != null) {
      label = data['label'];
    }
    if (data['bandwidth'] != null) {
      bandwidth = List<Bandwidth>.from((data['bandwidth'] ?? []).map((b) => Bandwidth.fromMap(b)).toList());
    }
    if (data['framerate'] != null) {
      framerate = data['framerate'];
    }
    if (data['bundleOnly'] != null) {
      bundleOnly = data['bundleOnly'];
    }
    if (data['imageattrs'] != null) {
      imageattrs = List<Imageattrs>.from((data['imageattrs'] ?? []).map((ia) => Imageattrs.fromMap(ia)).toList());
    }
    if (data['sourceFilter'] != null) {
      sourceFilter = SourceFilter.fromMap(data['sourceFilter']);
    }
    if (data['description'] != null) {
      description = data['description'];
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = <String, dynamic>{};
    if (candidates != null) {
      result['candidates'] = [candidates.map((IceCandidate c) => c.toMap()).toList().first];
    }
    if (iceUfrag != null) {
      result['iceUfrag'] = iceUfrag;
    }
    if (icePwd != null) {
      result['icePwd'] = icePwd;
    }
    if (endOfCandidates != null) {
      result['endOfCandidates'] = endOfCandidates;
    }
    if (iceOptions != null) {
      result['iceOptions'] = iceOptions;
    }
    if (setup != null) {
      result['setup'] = setup;
    }
    if (mid != null) {
      result['mid'] = mid;
    }
    if (port != null) {
      result['port'] = port;
    }
    if (direction != null) {
      result['direction'] = direction.value;
    }
    if (rtp != null) {
      result['rtp'] = rtp.map((Rtp r) => r.toMap()).toList();
    }
    if (fmtp != null) {
      result['fmtp'] = fmtp.map((Fmtp f) => f.toMap()).toList();
    }
    if (type != null) {
      result['type'] = type;
    }
    if (protocol != null) {
      result['protocol'] = protocol;
    }
    if (payloads != null) {
      result['payloads'] = payloads;
    }
    if (connection != null) {
      result['connection'] = connection.toMap();
    }
    if (rtcp != null) {
      result['rtcp'] = rtcp.toMap();
    }
    if (ext != null) {
      result['ext'] = ext.map((Ext e) => e.toMap()).toList();
    }
    if (msid != null) {
      result['msid'] = msid;
    }
    if (rtcpMux != null) {
      result['rtcpMux'] = rtcpMux;
    }
    if (rtcpFb != null) {
      result['rtcpFb'] = rtcpFb.map((RtcpFb rfb) => rfb.toMap()).toList();
    }
    if (ssrcs != null) {
      result['ssrcs'] = ssrcs.map((Ssrc s) => s.toMap()).toList();
    }
    if (ssrcGroups != null) {
      result['ssrcGroups'] = ssrcGroups.map((SsrcGroup sg) => sg.toMap()).toList();
    }
    if (simulcast != null) {
      result['simulcast'] = simulcast.toMap();
    }
    if (simulcast_03 != null) {
      result['simulcast_03'] = simulcast_03.toMap();
    }
    if (rids != null) {
      result['rids'] = rids.map((Rid r) => r.toMap()).toList();
    }
    if (extmapAllowMixed != null) {
      result['extmapAllowMixed'] = extmapAllowMixed;
    }
    if (rtcpRsize != null) {
      result['rtcpRsize'] = rtcpRsize;
    }
    if (sctpPort != null) {
      result['sctpPort'] = sctpPort;
    }
    if (maxMessageSize != null) {
      result['maxMessageSize'] = maxMessageSize;
    }
    if (sctpmap != null) {
      result['sctpmap'] = sctpmap.toMap();
    }
    if (xGoogleFlag != null) {
      result['xGoogleFlag'] = xGoogleFlag;
    }
    if (fingerprint != null) {
      result['fingerprint'] = fingerprint.toMap();
    }
    if (rtcpFbTrrInt != null) {
      result['rtcpFbTrrInt'] = rtcpFbTrrInt.map((RtcpFbTrrInt rFTI) => rFTI.toMap()).toList();
    }
    if (crypto != null) {
      result['crypto'] = crypto.map((Crypto c) => c.toMap()).toList();
    }
    if (invalid != null) {
      result['invalid'] = invalid.map((Invalid i) => i.toMap()).toList();
    }
    if (ptime != null) {
      result['ptime'] = ptime;
    }
    if (maxptime != null) {
      result['maxptime'] = maxptime;
    }
    if (label != null) {
      result['label'] = label;
    }
    if (bandwidth != null) {
      result['bandwidth'] = bandwidth.map((Bandwidth bw) => bw.toMap()).toList();
    }
    if (framerate != null) {
      result['framerate'] = framerate;
    }
    if (bundleOnly != null) {
      result['bundleOnly'] = bundleOnly;
    }
    if (imageattrs != null) {
      result['imageattrs'] = imageattrs.map((Imageattrs im) => im.toMap()).toList();
    }
    if (sourceFilter != null) {
      result['sourceFilter'] = sourceFilter.toMap();
    }
    if (description != null) {
      result['description'] = description;
    }

    return result;
  }
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

  String get mid => _mediaObject.mid != null ? _mediaObject.mid.toString() : null;

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
    _mediaObject.mid = offerMediaObject.mid;
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
              RtpHeaderDirectionExtension.fromString('recvonly');
          _mediaObject.rtp = <Rtp>[];
          _mediaObject.rtcpFb = <RtcpFb>[];
          _mediaObject.fmtp = <Fmtp>[];

          for (RtpCodecParameters codec in answerRtpParameters.codecs) {
            Rtp rtp = Rtp(
              payload: codec.payloadType,
              codec: getCodecName(codec),
              rate: codec.clockRate,
            );

            if (codec.channels != null && codec.channels > 1) {
              rtp.encoding = codec.channels;
            }

            _mediaObject.rtp.add(rtp);

            // CodecParameters codecParameters =
                // CodecParameters.copy(codec.parameters);
            Map<dynamic, dynamic> codecParameters =
                Map<dynamic, dynamic>.of(codec.parameters);

            if (codecOptions != null) {
              int opusStereo = codecOptions.opusStereo;
              int opusFec = codecOptions.opusFec;
              int opusDtx = codecOptions.opusDtx;
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

              switch (codec.mimeType.toLowerCase()) {
                case 'audio/opus':
                  {
                    if (opusStereo != null) {
                      // offerCodec.parameters['sprop-stereo'] = opusStereo ? 1 : 0;
                      offerCodec.parameters['sprop-stereo'] = opusStereo != null ? opusStereo : 0;
                      // codecParameters['stereo'] = opusStereo ? 1 : 0;
                      codecParameters['stereo'] = opusStereo != null ? opusStereo : 0;
                    }

                    if (opusFec != null) {
                      // offerCodec.parameters['useinbandfec'] = opusFec ? 1 : 0;
                      offerCodec.parameters['useinbandfec'] = opusFec != null ? opusFec : 0;
                      // codecParameters['useinbandfec'] = opusFec ? 1 : 0;
                      codecParameters['useinbandfec'] = opusFec != null ? opusFec : 0;
                    }

                    if (opusDtx != null) {
                      // offerCodec.parameters['usedtx'] = opusDtx ? 1 : 0;
                      offerCodec.parameters['usedtx'] = opusDtx != null ? opusDtx : 0;
                      // codecParameters['usedtx'] = opusDtx ? 1 : 0;
                      codecParameters['usedtx'] = opusDtx != null ? opusDtx : 0;
                    }

                    if (opusMaxPlaybackRate != null) {
                      codecParameters['maxplaybackrate'] = opusMaxPlaybackRate;
                    }

                    if (opusMaxAverageBitrate != null) {
                      codecParameters['maxaveragebitrate'] = opusMaxAverageBitrate;
                    }

                    if (opusPtime != null) {
                      offerCodec.parameters['ptime'] = opusPtime;
                      codecParameters['ptime'] = opusPtime;
                    }

                    break;
                  }

                case 'video/vp8':
                case 'video/vp9':
                case 'video/h264':
                case 'video/h265':
                  {
                    if (videoGoogleStartBitrate != null) {
                      codecParameters['x-google-start-bitrate'] =
                          videoGoogleStartBitrate;
                    }

                    if (videoGoogleMaxBitrate != null) {
                      codecParameters['x-google-max-bitrate'] = videoGoogleMaxBitrate;
                    }

                    if (videoGoogleMinBitrate != null) {
                      codecParameters['x-google-min-bitrate'] = videoGoogleMinBitrate;
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
    _mediaObject.mid = mid;
    _mediaObject.type = kind;

    if (plainRtpParameters == null) {
      _mediaObject.connection = Connection(
        ip: '127.0.0.1',
        version: 4,
      );

      if (sctpParameters == null) {
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
              RtpHeaderDirectionExtension.fromString('sendonly');
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

            if (codec.channels  != null && codec.channels > 1) {
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
      attribute: 'msid',
      value: '${streamId ?? '-'} $trackId',
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
