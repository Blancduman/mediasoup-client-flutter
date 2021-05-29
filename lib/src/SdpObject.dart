import 'package:mediasoup_client_flutter/src/handlers/sdp/MediaSection.dart';

class Origin {
  String username;
  int sessionId;
  int sessionVersion;
  String netType;
  int ipVer;
  String address;

  Origin({
    this.username,
    this.sessionId,
    this.sessionVersion = 0,
    this.netType,
    this.ipVer,
    this.address,
  });

  Origin.fromMap(Map data) {
    username = data['username'];
    sessionId = data['sessionId'];
    sessionVersion = data['sessionVersion'] ?? 0;
    netType = data['netType'];
    ipVer = data['ipVer'];
    address = data['address'];
  }

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
  String value;

  Invalid({
    this.value,
  });

  Invalid.fromMap(Map data) {
    value = data['value'];
  }

  Map<String, String> toMap() {
    return {
      'value': value,
    };
  }
}

class Timing {
  int start;
  int stop;

  Timing({
    this.start,
    this.stop,
  });

  Timing.fromMap(Map data) {
    start = data['start'];
    stop = data['stop'];
  }

  Map<String, int> toMap() {
    return {
      'start': start,
      'stop': stop,
    };
  }
}

class Group {
  String type;
  String mids;

  Group({
    this.type,
    this.mids,
  });

  Group.fromMap(Map data) {
    type = data['type'];
    mids = data['mids'].toString();
  }

  Map<String, String> toMap() {
    return {
      'type': type,
      'mids': mids,
    };
  }
}

class MsidSemantic {
  String semantic;
  String token;

  MsidSemantic({
    this.semantic,
    this.token,
  });

  MsidSemantic.fromMap(Map data) {
    semantic = data['semantic'];
    token = data['token'];
  }

  Map<String, String> toMap() {
    return {
      'semantic': semantic,
      'token': token,
    };
  }
}

class SdpObject {
  int version;
  Origin origin;
  String name;
  List<Invalid> invalid;
  String description;
  Timing timing;
  Connection connection;
  String iceUfrag;
  String icePwd;
  Fingerprint fingerprint;
  List<MediaObject> media;
  List<Group> groups;
  MsidSemantic msidSemantic;
  String icelite;

  SdpObject({
    this.version,
    this.origin,
    this.name,
    this.invalid,
    this.description,
    this.timing,
    this.connection,
    this.iceUfrag,
    this.icePwd,
    this.fingerprint,
    this.media,
    this.groups,
    this.msidSemantic,
    this.icelite,
  });

  SdpObject.fromMap(Map<String, dynamic> data) {
    version = data['version'];
    origin = Origin.fromMap(data['origin']);
    name = data['name'];
    invalid = List<Invalid>.from((data['invalid'] ?? [])
        .map((inval) => Invalid.fromMap(inval))
        .toList());
    if (data['timing'] != null) {
      timing = Timing.fromMap(data['timing']);
    }
    if (data['connection'] != null) {
      connection = Connection.fromMap(data['connection']);
    }
    iceUfrag = data['iceUfrag'];
    icePwd = data['icePwd'];
    if (data['fingerprint'] != null) {
      fingerprint = Fingerprint.fromMap(data['fingerprint']);
    }
    if (data['msidSemantic'] != null) {
      msidSemantic = MsidSemantic.fromMap(data['msidSemantic']);
    }
    media =
        List<MediaObject>.from((data['media'] ?? []).map((m) => MediaObject.fromMap(m)).toList());
    groups = List<Group>.from((data['groups'] ?? []).map((g) => Group.fromMap(g)).toList());
    icelite = data['icelite'];
    description = data['description'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = <String, dynamic>{};
    if (version != null) {
      result['version'] = version.toString();
    }
    if (origin != null) {
      result['origin'] = origin.toMap();
    }
    if (name != null) {
      result['name'] = name;
    }
    if (invalid != null) {
      result['invalid'] = invalid.map((Invalid i) => i.toMap()).toList();
    }
    if (description != null) {
      result['description'] = description;
    }
    if (timing != null) {
      result['timing'] = timing.toMap();
    }
    if (connection != null) {
      result['connection'] = connection.toMap();
    }
    if (iceUfrag != null) {
      result['iceUfrag'] = iceUfrag;
    }
    if (icePwd != null) {
      result['icePwd'] = icePwd;
    }
    if (fingerprint != null) {
      result['fingerprint'] = fingerprint.toMap();
    }
    if (media != null) {
      result['media'] = media.map((MediaObject m) => m.toMap()).toList();
    }
    if (groups != null) {
      result['groups'] = groups.map((Group g) => g.toMap()).toList();
    }
    if (msidSemantic != null) {
      result['msidSemantic'] = msidSemantic.toMap();
    }
    if (icelite != null) {
      result['icelite'] = icelite;
    }

    return result;
  }
}
