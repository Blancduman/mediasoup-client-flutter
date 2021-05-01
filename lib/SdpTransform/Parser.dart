import 'dart:convert';

import 'Grammer.dart' show grammer;

dynamic tryToParseInt(String testNumber) {
  if (testNumber is String && testNumber.isNotEmpty) {
    return int.tryParse(testNumber) ?? testNumber;
  }
  return null;
}

void attachProperties(Iterable<RegExpMatch> matchs,
    Map<String, dynamic> location, names, String rawName) {
  if ((rawName != null && rawName.isNotEmpty) &&
      (names == null || names.isEmpty)) {
    matchs.forEach((match) {
      location[rawName] =
          tryToParseInt(match.groupCount == 0 ? match.input : match.group(1));
    });
  } else {
    matchs.forEach((match) {
      for (int i = 0; i < match.groupCount; i++) {
        location[names[i].toString()] = tryToParseInt(match.group(i + 1));
      }
    });
  }
}

void parseReg(
    Map<String, dynamic> obj, Map<String, dynamic> location, String content) {
  final bool needsBlank = obj['name'] != null && obj['names'] != null;
  if (obj['push'] != null && location[obj['push']] == null) {
    location[obj['push']] = [];
  } else if (needsBlank && location[obj['name']] == null) {
    location[obj['name']] = <String, dynamic>{};
  }

  var keyLocation;
  if (obj['push'] != null) {
    keyLocation = <String, dynamic>{};
  } else {
    if (needsBlank) {
      keyLocation = location[obj['name']];
    } else {
      keyLocation = location;
    }
  }

  if (obj['reg'] is RegExp) {
    attachProperties(
        obj['reg'].allMatches(content), keyLocation, obj['names'], obj['name']);
  } else {
    attachProperties(RegExp(obj['reg']).allMatches(content), keyLocation,
        obj['names'], obj['name']);
  }

  if (obj['push'] != null) {
    location[obj['push']].add(keyLocation);
  }
}

Map<String, dynamic> parse(String sdp) {
  Map<String, dynamic> session = <String, dynamic>{};
  var medias = [];

  var location =
      session; // points at where properties go under (one of the above)

  LineSplitter().convert(sdp).forEach((line) {
    if (line != '') {
      var type = line[0];
      var content = line.substring(2);

      if (type == 'm') {
        Map<String, dynamic> media = <String, dynamic>{};
        media['rtp'] = [];
        media['fmtp'] = [];
        location = media; // point at latest media line
        medias.add(media);
      }
      if (grammer[type] != null) {
        for (int j = 0; j < grammer[type].length; j++) {
          var obj = grammer[type][j];
          if (obj['reg'] == null) {
            if (obj['name'] != null) {
              location[obj['name']] = content;
            } else {
              print('SdpTransform: trying to add null key');
            }
            continue;
          }

          if (obj['reg'] is RegExp) {
            if ((obj['reg'] as RegExp).hasMatch(content)) {
              parseReg(obj, location, content);
              return;
            }
          } else if (RegExp(obj['reg']).hasMatch(content)) {
            parseReg(obj, location, content);
            return;
          }
        }
        if (location['invalid'] == null) {
          location['invalid'] = [];
        }

        Map<String, dynamic> tmp = <String, dynamic>{};
        tmp['value'] = content;
        location['invalid'].add(tmp);
      } else {
        print('SdpTransform: Error: unknown grammer type $type');
      }
    }
  });

  session['media'] = medias; // link it up
  return session;
}

Map<dynamic, dynamic> parseParams(String str) {
  Map<dynamic, dynamic> params = <dynamic, dynamic>{};
  str.split(RegExp(r';').pattern).forEach((line) {
    // only split at the first '=' as there may be an '=' in the value as well
    int index = line.indexOf('=');
    String key;
    String value = '';
    if (index == -1) {
      key = line;
    } else {
      key = line.substring(0, index).trim();
      value = line.substring(index + 1, line.length).trim();
    }

    params[key] = tryToParseInt(value);
  });

  return params;
}

List<String> parsePayloads(str) => str.split(' ');

List<String> parseRemoteCandidates(String str) {
  var candidates = [];
  List<String> parts = [];

  str.split(' ').forEach((dynamic v) {
    dynamic value = tryToParseInt(v);
    if (value != null) {
      parts.add(value);
    }
  });

  for (int i = 0; i < parts.length; i += 3) {
    candidates.add({
      'component': parts[i],
      'ip': parts[i + 1],
      'port': parts[i + 2],
    });
  }

  return candidates;
}

List<Map<String, dynamic>> parseImageAttributes(String str) {
  List<Map<String, dynamic>> attributes = [];
  str.split(' ').forEach((item) {
    Map<String, dynamic> params = <String, dynamic>{};
    item.substring(1, item.length - 1).split(',').forEach((attr) {
      List<String> kv = attr.split(RegExp(r'=').pattern);
      assert(kv[0] != null);
      params[kv[0]] = tryToParseInt(kv[1]);
    });
    attributes.add(params);
  });

  return attributes;
}

List<dynamic> parseSimulcastStreamList(String str) {
  List<dynamic> attributes = [];
  str.split(';').forEach((stream) {
    List scids = [];
    stream.split(',').forEach((format) {
      var scid;
      bool paused = false;
      if (format[0] != '~') {
        scid = tryToParseInt(format);
      } else {
        scid = tryToParseInt(format.substring(1, format.length));
        paused = true;
      }

      Map<String, dynamic> data = <String, dynamic>{};
      data['scid'] = scid;
      data['paused'] = paused;
      scids.add(data);
    });
    attributes.add(scids);
  });

  return attributes;
}
