import 'dart:core';
import "package:test/test.dart";

void main() {
  test("basictest", basictest);
  test("basictest2", basictest2);
  test("basictest3", basictest3);
  test("basictest4", basictest4);
}

basictest() {
  RegExp exp = new RegExp(r"(\w+)");
  String str = "Parse my string";
  Iterable<Match> matches = exp.allMatches(str);
  matches.forEach((m) {
    String match = m.group(0);
    print('value = ' + match);
  });
}

basictest2() {
  RegExp exp = new RegExp(r'^(\S*) (\d*) (\d*) (\S*) IP(\d) (\S*)$');
  String str = "o=- 20518 0 IN IP4 203.0.113.1";
  Iterable<Match> matches = exp.allMatches(str);
  matches.forEach((m) {
    print('group(0) = ' + m.group(0));
    for (var i = 0; i < m.groupCount; i++)
      print('group(' + (1 + i).toString() + ') = ' + m.group(i + 1));
  });
}

basictest3() {
  RegExp exp = new RegExp(
      r'^a=candidate:(\S*) (\d*) (\S*) (\d*) (\S*) (\d*) typ (\S*)(?: raddr (\S*) rport (\d*))?(?: tcptype (\S*))?(?: generation (\d*))?(?: network-id (\d*))?(?: network-cost (\d*))?');
  String str =
      "a=candidate:3289912957 2 tcp 1845501695 193.84.77.194 60017 typ srflx raddr 192.168.34.75 rport 60017 tcptype passive generation 0 network-id 3 network-cost 10";
  var names = [
    'foundation',
    'component',
    'transport',
    'priority',
    'ip',
    'port',
    'type',
    'raddr',
    'rport',
    'tcptype',
    'generation',
    'network-id',
    'network-cost'
  ];
  Iterable<Match> matches = exp.allMatches(str);
  matches.forEach((m) {
    print('group(0) = ' + m.group(0));
    for (var i = 0; i < m.groupCount; i++)
      if (m.group(i + 1) != null)
        print('group(' +
            (1 + i).toString() +
            ') ' +
            names[i] +
            ' = ' +
            m.group(i + 1));
  });
}

basictest4() {
  RegExp exp = new RegExp(
      r'^a=candidate:(\S*) (\d*) (\S*) (\d*) (\S*) (\d*) typ (\S*)(?: raddr (\S*) rport (\d*))?(?: tcptype (\S*))?(?: generation (\d*))?(?: network-id (\d*))?(?: network-cost (\d*))?');
  String str = "a=candidate:0 1 UDP 2113667327 203.0.113.1 54400 typ host";
  var names = [
    'foundation',
    'component',
    'transport',
    'priority',
    'ip',
    'port',
    'type',
    'raddr',
    'rport',
    'tcptype',
    'generation',
    'network-id',
    'network-cost'
  ];
  Iterable<Match> matches = exp.allMatches(str);
  matches.forEach((m) {
    print('group(0) = ' +
        m.group(0) +
        ", groupCount = " +
        m.groupCount.toString());
    for (var i = 0; i < m.groupCount; i++)
      if (m.group(i + 1) != null)
        print('group(' +
            (1 + i).toString() +
            ') ' +
            names[i] +
            ' = ' +
            m.group(i + 1));
  });
}
