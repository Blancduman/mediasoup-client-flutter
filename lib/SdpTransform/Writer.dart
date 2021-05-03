import './Grammer.dart' show grammer;

RegExp formatRegExp = RegExp(r'%d|%v|%s');

String format(formatStr, args) {
  int i = 0;
  return formatStr.replaceAllMapped(
    formatRegExp,
    (Match m) => args[i++].toString(),
  );
}

makeLine(type, obj, location) {
  String str;

  if (obj['format'] != null) {
    var format = obj['format'];
    if (format is Function) {
      str = format(obj['push'] != null ? location : location[obj['name']]);
    } else {
      str = obj['format'];
    }
  } else {
    try {
      str = location[obj['name']].toString();
    } catch (e) {
      print('SdpTransform: makeLine() error: ${e.toString()}');
    }
  }

  String formatStr = '$type=${str.toString()}';
  List args = [];

  if (obj['names'] != null) {
    for (int i = 0; i < obj['names'].length; i++) {
      var n = obj['names'][i];
      if (obj['name'] != null) {
        args.add(location[obj['name']][n].toString());
      } else {
        // for mLine and push attributes
        var arg = location[obj['names'][i]] ?? '';
        args.add(arg.toString());
      }
    }
  } else {
    args.add(location[obj['name']]);
  }

  return format(formatStr, args);
}

List<String> defaultOuterOrder = [
  'v',
  'o',
  's',
  'i',
  'u',
  'e',
  'p',
  'c',
  'b',
  't',
  'r',
  'z',
  'a',
];

List<String> defaultInnerOrder = ['i', 'c', 'b', 'a'];

String write(Map<String, dynamic> session, Map<String, dynamic> opts) {
  opts = opts ?? {
    'outerOrder': null,
    'innerOrder': null,
  };

  // ensure certain properties exist
  if (session['version'] == null) {
    session['version'] = 0; // 'v=0' must be there (only defined version atm)
  }
  if (session['name'] == null) {
    session['name'] = ' '; // 's= ' must be there if no meaningful name set
  }

  session['media'].forEach((mLine) {
    if (mLine == null ) {
      mLine = {};
    }
    if (mLine['payloads'] == null) {
      mLine['payloads'] = '';
    }
  });

  var outerOrder = opts['souterOrder'] ?? defaultOuterOrder;
  var innerOrder = opts['innerOrder'] ?? defaultInnerOrder;
  List sdp = [];

  // loop through outerOrder for matching properties on session
  outerOrder.forEach((type) {
    grammer[type].forEach((obj) {
      if (obj['name'] != null && session[obj['name']] != null) {
        sdp.add(makeLine(type, obj, session));
      } else if (obj['push'] != null && session[obj['push']] != null) {
        session[obj['push']].forEach((el) {
          sdp.add(makeLine(type, obj, el));
        });
      }
    });
  });

  // then for each media line, follow the innerOrder
  session['media'].forEach((mLine) {
    sdp.add(makeLine('m', grammer['m'][0], mLine));
    innerOrder.forEach((type) {
      grammer[type].forEach((obj) {
        if (obj['name'] != null && mLine[obj['name']] != null) {
          sdp.add(makeLine(type, obj, mLine));
        } else if (obj['push'] != null && mLine[obj['push']] != null) {
          mLine[obj['push']].forEach((el) {
            sdp.add(makeLine(type, obj, el));
          });
        }
      });
    });
  });

  return '${sdp.join('\r\n')}\r\n';
}