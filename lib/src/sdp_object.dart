import 'package:mediasoup_client_flutter/src/handlers/sdp/media_section.dart';

class Origin {
  final String username;
  final int sessionId;
  int sessionVersion;
  final String netType;
  int ipVer;
  String address;

  Origin({
    required this.username,
    required this.sessionId,
    this.sessionVersion = 0,
    required this.netType,
    required this.ipVer,
    required this.address,
  });

  Origin.fromMap(Map data)
      : username = data['username'],
        sessionId = data['sessionId'],
        sessionVersion = data['sessionVersion'] ?? 0,
        netType = data['netType'],
        ipVer = data['ipVer'],
        address = data['address'];

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'sessionId': sessionId,
      'sessionVersion': sessionVersion,
      'netType': netType,
      'ipVer': ipVer,
      'address': address,
    };
  }
}

class Invalid {
  final String value;

  Invalid({
    required this.value,
  });

  Invalid.fromMap(Map data) : value = data['value'];

  Map<String, String> toMap() {
    return {
      'value': value,
    };
  }
}

class Timing {
  final int start;
  final int stop;

  Timing({
    required this.start,
    required this.stop,
  });

  Timing.fromMap(Map data)
      : start = data['start'],
        stop = data['stop'];

  Map<String, int> toMap() {
    return {
      'start': start,
      'stop': stop,
    };
  }
}

class Group {
  final String type;
  String mids;

  Group({
    required this.type,
    required this.mids,
  });

  Group.fromMap(Map data)
      : type = data['type'],
        mids = data['mids'].toString();

  Map<String, String> toMap() {
    return {
      'type': type,
      'mids': mids,
    };
  }
}

class MsidSemantic {
  final String semantic;
  final String token;

  MsidSemantic({
    required this.semantic,
    required this.token,
  });

  MsidSemantic.fromMap(Map data)
      : semantic = data['semantic'],
        token = data['token'];

  Map<String, String> toMap() {
    return {
      'semantic': semantic,
      'token': token,
    };
  }
}

class SdpObject {
  final int version;
  final Origin origin;
  final String name;
  final List<Invalid> invalid;
  final String? description;
  final Timing? timing;
  final Connection? connection;
  final String? iceUfrag;
  final String? icePwd;
  Fingerprint? fingerprint;
  final List<MediaObject> media;
  List<Group> groups;
  MsidSemantic? msidSemantic;
  String? icelite;

  SdpObject({
    required this.version,
    required this.origin,
    required this.name,
    this.invalid = const [],
    this.description,
    this.timing,
    this.connection,
    this.iceUfrag,
    this.icePwd,
    this.fingerprint,
    this.media = const [],
    this.groups = const [],
    this.msidSemantic,
    this.icelite,
  });

  SdpObject.fromMap(Map<String, dynamic> data) :
    version = data['version'],
    origin = Origin.fromMap(data['origin']),
    name = data['name'],
    invalid = List<Invalid>.from((data['invalid'] ?? [])
        .map((inval) => Invalid.fromMap(inval))
        .toList()),
      timing = data['timing'] != null ? Timing.fromMap(data['timing']) : null,
      connection = data['connection'] != null ? Connection.fromMap(data['connection']) : null,
    iceUfrag = data['iceUfrag'],
    icePwd = data['icePwd'],
      fingerprint = data['fingerprint'] != null ? Fingerprint.fromMap(data['fingerprint']) : null,
      msidSemantic = data['msidSemantic'] != null ? MsidSemantic.fromMap(data['msidSemantic']) : null,
    media = List<MediaObject>.from(
        (data['media'] ?? []).map((m) => MediaObject.fromMap(m)).toList()),
    groups = List<Group>.from(
        (data['groups'] ?? []).map((g) => Group.fromMap(g)).toList()),
    icelite = data['icelite'],
    description = data['description'];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = <String, dynamic>{};
    result['version'] = version.toString();
    result['origin'] = origin.toMap();
    result['name'] = name;
    result['invalid'] = invalid.map((Invalid i) => i.toMap()).toList();
    result['description'] = description;
    if (timing != null) {
      result['timing'] = timing?.toMap();
    }
    if (connection != null) {
      result['connection'] = connection?.toMap();
    }
    result['iceUfrag'] = iceUfrag;
    result['icePwd'] = icePwd;
    if (fingerprint != null) {
      result['fingerprint'] = fingerprint?.toMap();
    }
    result['media'] = media.map((MediaObject m) => m.toMap()).toList();
    result['groups'] = groups.map((Group g) => g.toMap()).toList();
    if (msidSemantic != null) {
      result['msidSemantic'] = msidSemantic?.toMap();
    }
    result['icelite'] = icelite;

    return result;
  }
}
