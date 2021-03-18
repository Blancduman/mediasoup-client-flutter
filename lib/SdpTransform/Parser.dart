import 'Grammer.dart' show grammar;
import 'dart:convert';

int tryToParseInt(String testNumber) {
  return int.tryParse(testNumber) ?? null;
}

void attachProperties(Iterable<RegExpMatch> matchs, Map<String, dynamic> location, names, String rawName) {
  if ((rawName != null && rawName.isNotEmpty) && (names == null || names.isEmpty)) {
    matchs.forEach((match) {
      location[rawName] = tryToParseInt(match.groupCount == 0 ? match.input : match.group(1));
    });
  } else {
    matchs.forEach((match) {
      for (int i = 0; i < match.groupCount; i++) {
        location[names[i].toString()] = tryToParseInt(match.group(i + 1));
      }
    });
  }
}

void parseReg(Map<String, dynamic> obj, Map<String, dynamic> location, String content) {
  final bool needsBlank = obj['name'] != null && obj['names'] != null;
  if (obj['push'] != null && location[obj['push']] == null) {
    location[obj['push']] = [];
  } else if (needsBlank && location[obj['name']] == null) {
    location[obj['name']] = <String, dynamic>{};
  }

  var keyLocation;
  if (obj['push'] != null) {
    keyLocation = <String, dynamic>{};
  } else if (needsBlank) {
    keyLocation = location[obj['name']];
  } else {
    keyLocation = location;
  }

  if (obj['reg'] is RegExp) {
    attachProperties(obj['reg'].allMatches(content), keyLocation, obj['names'], obj['name']);
  } else {
    attachProperties(RegExp(obj['reg']).allMatches(content), keyLocation, obj['names'], obj['name']);
  }
}